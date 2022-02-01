#!/usr/bin/bash

folder_blocklist='02txt_block/'
filelistall="${folder_blocklist%/}/blockall.txt"
db_file="${folder_blocklist%/}/org.unicode.db"

folder_sql='03sql/'
filesql="${folder_sql%/}/processing.sql"

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

cat ${filesql} | sqlite3 "${db_file}"

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


