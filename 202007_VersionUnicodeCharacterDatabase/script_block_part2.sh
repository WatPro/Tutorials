#!/usr/bin/bash

folder_blocklist='02txt_block/'
filelistall="${folder_blocklist}blockall.txt"
db_file="${folder_blocklist}org.unicode.db"

cat << END_OF_FILE | sqlite3 "${db_file}"
CREATE TABLE IF NOT EXISTS blocks_raw (
  "major"   INTEGER  NOT NULL,
  "minor"   INTEGER  NOT NULL,
  "update"  INTEGER  NOT NULL,
  "start"   INTEGER  NOT NULL, 
  "end"     INTEGER  NOT NULL,
  "block"   TEXT     NOT NULL
); 
CREATE INDEX IF NOT EXISTS blocks_index_start 
  ON blocks_raw ("start", "major", "minor", "update", "end");
DELETE FROM blocks_raw;
.mode tabs
.import ${filelistall} blocks_raw
END_OF_FILE

cat << END_OF_FILE | sqlite3 "${db_file}"
CREATE TABLE IF NOT EXISTS blocks (
  start          INTEGER  NOT NULL,
  end            INTEGER  NOT NULL, 
  block          TEXT     NOT NULL,
  first_version  TEXT     NOT NULL,
  status         TEXT     NOT NULL
); 
DELETE FROM blocks;
WITH
  s AS (
  SELECT 
    start
  FROM 
    blocks_raw 
  GROUP BY 
    start
  ),
  data AS (
  SELECT 
    s.start, 
    (
    SELECT 
      blocks.end
    FROM 
      blocks_raw blocks
    WHERE
      blocks.start = s.start
    ORDER BY
      blocks."major"  DESC, 
      blocks."minor"  DESC,
      blocks."update" DESC
    )  AS last_end,
    (
    SELECT 
      MAX(blocks.end)
    FROM 
      blocks_raw blocks
    WHERE
      blocks.start = s.start
    )  AS largest_end,
    (
    SELECT 
      blocks.block
    FROM 
      blocks_raw blocks
    WHERE
      blocks.start = s.start
    ORDER BY
      blocks."major"  DESC, 
      blocks."minor"  DESC,
      blocks."update" DESC
    )  AS block, 
    (
    SELECT 
      blocks."major" || '.' || blocks."minor" || '.' || blocks."update"
    FROM 
      blocks_raw blocks
    WHERE
      blocks.start = s.start
    ORDER BY
      blocks."major"  ASC, 
      blocks."minor"  ASC,
      blocks."update" ASC
    )  AS first_version, 
    (
    SELECT 
      blocks."major" || '.' || blocks."minor" || '.' || blocks."update"
    FROM 
      blocks_raw blocks
    WHERE
      blocks.start = s.start
    ORDER BY
      blocks."major"  DESC, 
      blocks."minor"  DESC,
      blocks."update" DESC
    )  AS last_version
  FROM
    s
  ), 
  check_range AS (  -- passed
  SELECT 
    start,
    last_end,
    largest_end,
    block,
    first_version,
    last_version
  FROM 
    data
  WHERE
    largest_end > last_end
  ), 
  last AS (
  SELECT 
    "major" || '.' || "minor" || '.' || "update" AS version
  FROM 
    blocks_raw
  ORDER BY
    "major"  DESC, 
    "minor"  DESC,
    "update" DESC
  LIMIT 1
  ),
  remove_merged AS ( 
  SELECT 
    start,
    last_end AS end,
    last_end,
    largest_end,
    block,
    first_version,
    last_version, 
    CASE 
      WHEN last_version = (SELECT version FROM last) 
        THEN 'active'
    END status
  FROM 
    data
  WHERE
    NOT EXISTS (
    SELECT 1
    FROM data super
    WHERE 
      NOT (
        super.start = data.start
        AND
        super.last_end = data.last_end
      )
      AND
      data.start BETWEEN super.start AND super.last_end 
      AND
      data.last_end BETWEEN super.start AND super.last_end
    )
  ) 
INSERT INTO blocks
  (
  start,
  end, 
  block,
  first_version,
  status
  )
SELECT 
  start,
  end, 
  block,
  first_version,
  status
FROM 
  remove_merged 
;
END_OF_FILE

file_blockversion="${folder_blocklist}block_version.csv"
cat << END_OF_FILE | sqlite3 "${db_file}"
.headers on
.mode csv
.output ${file_blockversion}
SELECT 
  start,
  end, 
  block,
  first_version,
  status
FROM
  blocks
;
END_OF_FILE


