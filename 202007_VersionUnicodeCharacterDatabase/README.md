
## Issue 
 
As of now (July 2020), some Unicode characters are [not supported](https://docs.teradata.com/reader/1Ms8rWHdBhcwr0PzwAWcDw/4RotpZHfnWvB674Awg0RNA "Charactersrs other than Unicode Basic Multilingual Plane version 6.0") by Teradata, 

* Characters in Basic Multilingual Plane from Unicode versions 6.1.0 and onwards, and

* Characters in Supplementary Multilingual Planes from all Unicode versions. 

What is more, in Teradata UTF8, a character can consist of [one to three bytes](https://docs.teradata.com/reader/yKxpuYv1DGjVp_g62SgwBw/QwK6iAOuWMlLNZivGR5Yxw "Limitations in UTF8 support").
 
The team cannot find a reliable, convenient and immediately available source to indicate the version of a large number of characters before passing data to Teradata system. 

## Solution 
 
This mini-project constructs a list based on official Unicode Character Database, mapping an assigned block (code range) to the first version it was created, starting from the most significant early version 2.0. 

## Environment 
 
```
Operation System: CentOS 8
SQLite3 pre-installed
```

```
# sqlite3 --version
3.26.0 2018-12-01 12:34:55 bf8c1b2b7a5960c282e543b9c293686dccff272512d08865f4600fb58238alt1

```

## Script Execution

```bash
bash script_list.sh

bash script_block_part1.sh
 
bash script_block_part2.sh

```
