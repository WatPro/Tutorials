

```
$ sudo apt-get --assume-yes install sqlite3

$ sqlite3 --version
3.16.2 2017-01-06 16:32:41 a65a62893ca8319e89e48b8a38cf8a59c69a8209
```

```bash
cat << END_OF_FILE | sqlite3 iprange_test.db
CREATE TABLE IF NOT EXISTS nping_records (
  batch TEXT        NOT NULL,
  action TEXT       NOT NULL,
  time   REAL       NOT NULL, 
  ip_from TEXT      NOT NULL, 
  ip_to   TEXT      NOT NULL, 
  icmp_type INTEGER NOT NULL, 
  icmp_code INTEGER NOT NULL,
  icmp_id   INTEGER NOT NULL, 
  icmp_seq  INTEGER NOT NULL,
  raw_text  TEXT    NULL
);
CREATE INDEX IF NOT EXISTS nping_records_index_fr 
  ON nping_records (batch, action, ip_from, time);
CREATE INDEX IF NOT EXISTS nping_records_index_to 
  ON nping_records (batch, action, ip_to, time);

DROP VIEW IF EXISTS ping_records;
CREATE VIEW ping_records AS
WITH
  latest AS (
  SELECT 
    batch, 
    action, time, 
    ip_from, ip_to, 
    icmp_type, icmp_code, 
    icmp_id, icmp_seq, 
    raw_text
  FROM 
    nping_records
  WHERE
    batch = (SELECT MAX(batch) FROM nping_records)
  ),
  clean_row AS (
  SELECT 
    action, time, 
    ip_from AS client, 
    ip_to   AS server, 
    icmp_type, icmp_code, 
    icmp_id, icmp_seq
  FROM
    latest
  WHERE
    action = "SENT" AND icmp_type = 8 AND icmp_code = 0
  UNION ALL
  SELECT 
    action, time, 
    ip_to   AS client, 
    ip_from AS server, 
    icmp_type, icmp_code, 
    icmp_id, icmp_seq
  FROM
    latest
  WHERE
    action = "RCVD" AND icmp_type = 0 AND icmp_code = 0
  ),
  sent AS (
  SELECT
    action, MIN(time) AS time, 
    server, 
    icmp_id, icmp_seq
  FROM 
    clean_row
  WHERE
    action = "SENT"
  GROUP BY
    action, server, 
    icmp_id, icmp_seq
  )
SELECT 
  server, icmp_id, icmp_seq, 
  time AS time_sent, 
  (
  SELECT 
    time
  FROM 
    clean_row rcvd
  WHERE
    rcvd.action = "RCVD"
    AND 
    rcvd.server = sent.server 
    AND 
    rcvd.icmp_id = sent.icmp_id 
    AND 
    rcvd.icmp_seq = sent.icmp_seq 
    AND 
    rcvd.time >= sent.time
  ORDER BY 
    time ASC
  LIMIT 1
  )    AS time_rcvd 
FROM 
  sent
;
DROP VIEW IF EXISTS ping_summary;
CREATE VIEW ping_summary AS 
WITH 
  records AS (
  SELECT
    server, icmp_id, icmp_seq, 
    time_sent, time_rcvd, 
    (time_rcvd - time_sent)*1000 AS ms_time_used
  FROM
    ping_records
  ), 
  cal AS (
  SELECT 
    server, 
    count(1)          AS sent,
    count(time_rcvd)  AS rcvd,
    max(ms_time_used) AS ms_worst,
    min(ms_time_used) AS ms_best,
    avg(ms_time_used) AS ms_average
  FROM 
    records
  GROUP BY 
    server
  )
SELECT 
  server, 
  sent,
  (sent-rcvd)*1.0/sent  AS lost_rate,
  ms_worst,
  ms_best,
  ms_average
FROM 
  cal
;
END_OF_FILE

```

