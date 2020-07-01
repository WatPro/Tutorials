/usr/bin/python3

import sys
import json

try:
  
  with open('03raw_json/LAML.json') as f:
    data = json.load(f)
  
  m = map(lambda file:file['file_id'],data['data']['hits'])
  j = json.dumps({"ids":sorted(set(m))}, indent=2)
  print(j)
  
except:
  sys.exit(1)
