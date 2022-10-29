

## https://github.com/python/cpython/blob/main/Lib/http/server.py

from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from os import getcwd
from os.path import isdir, join


working_directory = getcwd()
_data_directory   = join(working_directory, 'data')
if isdir(_data_directory):
  working_directory = _data_directory

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

class CustomHTTPRequestHandler(SimpleHTTPRequestHandler):
  
  def __init__(self, *args, **kwargs):
    super().__init__(*args, **kwargs, directory=working_directory)

## https://www.ietf.org/rfc/rfc2068.txt
##   Messages MUST NOT include both a Content-Length header field and the
##   "chunked" transfer coding. If both are received, the Content-Length
##   MUST be ignored.

  def chunked_handler(self,save_f):
    raise NotImplementedError('"handling for chunked" transfer coding is not implemented')

  def contentlength_handler(self,length,save_f):
    rfile      = self.rfile
    pretimeout = self.connection.gettimeout()
    print('  Content-Length: {}'.format(length))
    try:
      self.connection.settimeout(3)
      remain_length = int(length)
      while remain_length > 0:
        buffer = rfile.read1()
        read_length=len(buffer)
        if read_length==0:
          break
        save_f.write(buffer)
        remain_length -= read_length
      print('    remaining {}'.format(remain_length))
    except BaseException as err:
      self.connection.settimeout(pretimeout)
      raise err

  def do_PUT(self):
    from http import HTTPStatus ## https://docs.python.org/3/library/http.html#http-status-codes
    from socket import timeout
    from urllib.parse import urlparse
    from re import fullmatch
    o = urlparse(self.path)
    if self.directory != _data_directory or not isdir(self.directory):
      self.send_response(HTTPStatus.FORBIDDEN)
      self.end_headers()
      return
    if o.path != '/upload/':
      self.send_response(HTTPStatus.FORBIDDEN)
      self.end_headers()
      return
    if fullmatch(r'[0-9a-zA-Z._-]+',o.query) is None:
      self.send_response(HTTPStatus.BAD_REQUEST)
      self.end_headers()
      return
    filename = o.query
    filename = join(self.directory, filename)
    length   = self.headers.get('content-length')
    tran_enc = self.headers.get('transfer-encoding','').split(r',[ ]*')
    md5_b64  = self.headers.get('content-md5')
    read_type = 'chunked'
    if 'chunked' in tran_enc:
      read_type = 'chunked'
    elif length is not None:
      read_type = 'length'
    else:
      self.send_response(HTTPStatus.BAD_REQUEST)
      self.end_headers()
      return
    print('writing to {}'.format(filename))
    try:
      with open(filename,'wb') as f:
        if read_type == 'chunked':
          self.chunked_handler(f)
        elif read_type == 'length':
          self.contentlength_handler(length,f)
      if md5_b64 is not None:
        print('  Content-MD5: {}'.format(md5_b64))
        md5_check = get_md5(filename).decode()
        print('  File-MD5   : {}'.format(md5_check))
        if md5_b64 != md5_check:
          from os import remove
          print('    failed md5 check, removing {}'.format(filename))
          remove(filename)
          raise OSError()
      self.send_response(HTTPStatus.OK)
    except timeout as err:
      self.send_response(HTTPStatus.BAD_REQUEST)
    except NotImplementedError as err:
      self.send_response(HTTPStatus.NOT_IMPLEMENTED)
    except OSError as err:
      self.send_response(HTTPStatus.BAD_REQUEST)
      ## The Content-MD5 or checksum value that you specified did not match what the server received.
      ## https://docs.aws.amazon.com/AmazonS3/latest/API/ErrorResponses.html
    except BaseException as err:
      self.send_response(HTTPStatus.FORBIDDEN)
    finally:
      self.end_headers()


class DualStackServer(ThreadingHTTPServer):
  
  def server_bind(self):
    # suppress exception when protocol is IPv4
    from contextlib import suppress
    from socket import IPPROTO_IPV6, IPV6_V6ONLY # For gethostbyaddr()
    with suppress(Exception):
      self.socket.setsockopt(IPPROTO_IPV6, IPV6_V6ONLY, 0)
    return super().server_bind()
    
    def finish_request(self, request, client_address):
      self.RequestHandlerClass(request, client_address, self, directory=working_directory)


def main():
  from http.server import _get_best_family
  from sys import exit

  HandlerClass = CustomHTTPRequestHandler
  ServerClass  = DualStackServer
  protocol = "HTTP/1.0"
  port     = 8000
  bind     = None

  ServerClass.address_family, addr = _get_best_family(bind, port)
  HandlerClass.protocol_version = protocol
  with ServerClass(addr, HandlerClass) as httpd:
    host, port = httpd.socket.getsockname()[:2]
    url_host = f'[{host}]' if ':' in host else host
    print(
      f"Serving HTTP on {host} port {port} "
      f"(http://{url_host}:{port}/) ..."
    )
    try:
      httpd.serve_forever()
    except KeyboardInterrupt:
      print("\nKeyboard interrupt received, exiting.")
      exit(0)

if __name__ == '__main__':
  main()  
  