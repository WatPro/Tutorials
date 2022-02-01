#!/usr/bin/bash

folder_blocklist='02txt_block/'
filelistall="${folder_blocklist}blockall.txt"
db_file="${folder_blocklist}org.unicode.db"

cat << END_OF_FILE | sqlite3 "${db_file}"
CREATE TABLE IF NOT EXISTS "blocks_raw" (
  "major"   TEXT  NOT NULL,
  "minor"   TEXT  NOT NULL,
  "update"  TEXT  NOT NULL,
  "start"   TEXT  NOT NULL, 
  "end"     TEXT  NOT NULL,
  "block"   TEXT  NOT NULL
); 
.mode tabs
.import ${filelistall} blocks_raw
END_OF_FILE

cat << END_OF_FILE | sqlite3 "${db_file}"
CREATE TABLE IF NOT EXISTS "blocks_data" (
  "major"   INTEGER  NOT NULL,
  "minor"   INTEGER  NOT NULL,
  "update"  INTEGER  NOT NULL,
  "version" TEXT     NOT NULL,
  "start"   INTEGER  NOT NULL, 
  "end"     INTEGER  NOT NULL,
  "block"   TEXT     NOT NULL
); 
DELETE FROM "blocks_data";
CREATE INDEX IF NOT EXISTS "blocks_index_start" 
  ON "blocks_data" ("start", "major", "minor", "update", "end");
INSERT INTO "blocks_data"
  (
  "major",
  "minor",
  "update",
  "version",
  "start", 
  "end",
  "block"
  )
SELECT 
  "major",
  "minor",
  "update",
  "major" || '.' || "minor" || '.' || "update" 
      AS "version",
  "start", 
  "end",
  "block"
FROM 
  "blocks_raw"
;

-- Rewrite Common Table Expression with VIEW
CREATE VIEW IF NOT EXISTS "list_s" AS 
SELECT 
  "start"
FROM 
  "blocks_data" 
GROUP BY 
  "start"
;
CREATE VIEW IF NOT EXISTS "list_data" AS 
SELECT 
  "s"."start", 
  (
  SELECT 
    "blocks"."end"
  FROM 
    "blocks_data" "blocks"
  WHERE
    "blocks"."start" = "s"."start"
  ORDER BY
    "blocks"."major"  DESC, 
    "blocks"."minor"  DESC,
    "blocks"."update" DESC
  )  AS "last_end",
  (
  SELECT 
    MAX("blocks"."end")
  FROM 
    "blocks_data" "blocks"
  WHERE
    "blocks"."start" = "s"."start"
  )  AS "largest_end",
  (
  SELECT 
    "blocks"."block"
  FROM 
    "blocks_data" "blocks"
  WHERE
    "blocks"."start" = "s"."start"
  ORDER BY
    "blocks"."major"  DESC, 
    "blocks"."minor"  DESC,
    "blocks"."update" DESC
  )  AS "block", 
  (
  SELECT 
    "blocks"."version"
  FROM 
    "blocks_data" "blocks"
  WHERE
    "blocks"."start" = "s"."start"
  ORDER BY
    "blocks"."major"  ASC, 
    "blocks"."minor"  ASC,
    "blocks"."update" ASC
  )  AS first_version, 
  (
  SELECT 
    "blocks"."version"
  FROM 
    "blocks_data" "blocks"
  WHERE
    "blocks"."start" = "s"."start"
  ORDER BY
    "blocks"."major"  DESC, 
    "blocks"."minor"  DESC,
    "blocks"."update" DESC
  )  AS "last_version"
FROM
  "list_s" "s"
;
CREATE VIEW IF NOT EXISTS "check_range" AS 
SELECT 
  "start",
  "last_end",
  "largest_end",
  "block",
  "first_version",
  "last_version"
FROM 
  "list_data" "data"
WHERE
  "largest_end" > "last_end"
;
CREATE VIEW IF NOT EXISTS "list_last" AS 
SELECT 
  "blocks"."version"
FROM 
  "blocks_data" "blocks"
ORDER BY
  "major"  DESC, 
  "minor"  DESC,
  "update" DESC
LIMIT 1
;
CREATE VIEW IF NOT EXISTS "list_remove_merged" AS 
SELECT 
  "start",
  "last_end"   AS "end",
  "last_end",
  "largest_end",
  "block",
  "first_version",
  "last_version", 
  CASE 
    WHEN "last_version" = (SELECT "version" FROM "list_last") 
      THEN 'active'
    ELSE ''
  END          AS "status"
FROM 
  "list_data" "data"
WHERE
  NOT EXISTS (
  SELECT 1
  FROM "list_data" "super"
  WHERE 
    NOT (
      "super"."start" = "data"."start"
      AND
      "super"."last_end" = "data"."last_end"
    )
    AND
    "data"."start" BETWEEN "super"."start" AND "super"."last_end" 
    AND
    "data"."last_end" BETWEEN "super"."start" AND "super"."last_end"
  )
;
-- Rewrite Common Table Expression with VIEW

CREATE TABLE IF NOT EXISTS "blocks" (
  "start"          INTEGER  NOT NULL,
  "end"            INTEGER  NOT NULL, 
  "block"          TEXT     NOT NULL,
  "first_version"  TEXT     NOT NULL,
  "status"         TEXT     NOT NULL
); 
DELETE FROM "blocks";
INSERT INTO "blocks"
  (
  "start",
  "end", 
  "block",
  "first_version",
  "status"
  )
SELECT
  "start",
  "end", 
  "block",
  "first_version",
  "status"
FROM
  "list_remove_merged"
;
END_OF_FILE

file_blockversion="${folder_blocklist}block_version.csv"
cat << END_OF_FILE | sqlite3 "${db_file}"
.headers on
.mode csv
.output ${file_blockversion}
SELECT 
  "start",
  "end", 
  "block",
  "first_version",
  "status"
FROM
  "blocks"
;
END_OF_FILE


