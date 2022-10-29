

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

def retry(file, trycount=5, filename='UNKNOWN'):
  from os.path import getsize
  while trycount>=0:
    try:
      md5_base64 = get_md5(file)
      length     = getsize(file)
      with open(file,'rb') as f:
        print('SENDING {}'.format(filename)) 
        post(filename, f, length=length, md5=md5_base64)
      return True
    except BaseException as err:
      print(err)
    finally:
      trycount -= 1
  print('FATAL : {}'.format(file))
  return False


def main():
  from sys import argv
  from os import scandir, rename
  from os.path import isdir, join
  from re import fullmatch
  dirsource = 'test'
  dirdone   = 'done'
  movedone  = False
  if len(argv)>=2:
    dirsource = argv[1]
  if len(argv)>=3:
    dirdone   = argv[1]
  if isdir(dirdone):
    movedone = True
  if isdir(dirsource):
    with scandir(dirsource) as it:
      for entry in it:
        if entry.is_file() and fullmatch(r'[0-9a-zA-Z._-]+',entry.name):
          filename   = entry.name
          filepath   = join(dirsource,filename)
          isdone     = retry(file=filepath, trycount=10, filename=filename)
          if movedone and isdone:
            donepath = join(dirdone,filename)
            rename(filepath,donepath)


if __name__ == '__main__':
  main()  
