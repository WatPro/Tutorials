

from urllib.request import Request, urlopen, urljoin
from urllib.parse import urlparse

serverdomain = 'http://localhost:8000/'
uploadpath   = 'upload/'
baseurl      = urljoin(serverdomain,uploadpath)

def post(query, data, length = None, md5 = None):
  url = urlparse(baseurl)._replace(query=query).geturl()
  req = Request(url=url, data=data, method='POST')
  if length is not None:
    req.add_header('Content-Length', length)
  if md5 is not None:
    req.add_header('Content-MD5', md5)
  with urlopen(req) as f:
    pass
  print(f.status)
  print(f.reason)

def get_md5(file):
  from hashlib import md5
  from base64 import b64encode
  hash = md5()
  try:
    with open(file,'rb') as f:
      while True:
        buffer = f.read1()
        if len(buffer)==0:
          break
        hash.update(buffer)
    return b64encode(hash.digest())
  except BaseException as err:
    return None

def main():
  from sys import argv
  from os import scandir
  from os.path import isdir, join, getsize
  from re import fullmatch
  dir = 'test'
  if len(argv)>=2:
    dir = argv[1]
  if isdir(dir):
    with scandir(dir) as it:
      for entry in it:
        if entry.is_file() and fullmatch(r'[0-9a-zA-Z._-]+',entry.name):
          filename   = entry.name
          filepath   = join(dir,filename)
          md5_base64 = get_md5(filepath)
          length     = getsize(filepath) 
          with open(filepath,'rb') as f:
            print('SENDING {}'.format(filename))
            post(filename, f, length=length, md5=md5_base64)

if __name__ == '__main__':
  main()  
  