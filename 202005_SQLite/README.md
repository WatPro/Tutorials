
### Prepare Data (using Nping)
 
```bash
batch=`date --rfc-3339=ns`
sudo nping --rate 20 --count 10 --icmp 192.168.1.1/24 |
  sed --silent '/^\(SENT\|RCVD\)/p' > nping_raw.txt

reg_pattern='^\(SENT\|RCVD\)\s\+(\([0-9.]*\)s)\s\+ICMP\s\+'
reg_pattern="${reg_pattern}"'\[\([0-9.]\+\)\s\+>\s\+\([0-9.]\+\)\s\+'
reg_pattern="${reg_pattern}"'[^(]*(type=\([0-9]\+\)\/code=\([0-9]\+\))\s\+'
reg_pattern="${reg_pattern}"'id=\([0-9]\+\)\s\+seq=\([0-9]\+\)\].*$'

# BATCH ACTION TIME IP_FROM IP_TO ICMP_TYPE ICMP_CODE ICMP_ID ICMP_SEQ
output_row="${batch}"'\t\1\t\2\t\3\t\4\t\5\t\6\t\7\t\8\t\0'

cat nping_raw.txt | 
  sed --silent "s/${reg_pattern}/${output_row}/p" > nping_records.tsv

```

### Process via SQLite

```bash
cat << END_OF_FILE | sqlite3 iprange_test.db
.mode tabs
.import nping_records.tsv nping_records
END_OF_FILE

cat << END_OF_FILE | sqlite3 iprange_test.db
.headers on
.mode csv
.output ping_output.csv
SELECT
  server, 
  sent,
  lost_rate,
  ms_worst,
  ms_best,
  ms_average
FROM
  ping_summary
;
END_OF_FILE

```
