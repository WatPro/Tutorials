#include <iostream>  
#include <netdb.h>

#include <stdlib.h>
  
using namespace std; 
  
struct hostent *
gethost_ipv4 (char *host)
{
  const int h_addrtype = AF_INET; 
  struct hostent *hostbuf, *hp;
  size_t hstbuflen;
  char *tmphstbuf;
  int res;
  int herr;

  hostbuf   = (hostent *) malloc (sizeof (struct hostent));
  hstbuflen = 1024;
  tmphstbuf = (char *) malloc (hstbuflen);

  while ((res = gethostbyname2_r (host, h_addrtype, hostbuf, tmphstbuf, hstbuflen,
                                 &hp, &herr)) == ERANGE)
  {
    /* Enlarge the buffer.  */
    hstbuflen *= 2;
    tmphstbuf = (char *) realloc (tmphstbuf, hstbuflen);
  }

  free (tmphstbuf);
  /*  Check for errors.  */
  if (res || hp == NULL) {
    return NULL; 
  } 
  return hp;
}
 
int main( int argc, char *argv[] ) 
{ 
  for (int ii = 0; ii < argc; ii+=1 ) { 
    if (ii == 0) {
      cout << "Program: " << argv[ii] << endl; 
      continue ; 
    } 
    struct hostent *hostname;
    hostname = gethost_ipv4 (argv[ii]); 
    if (hostname == NULL) {
      continue ; 
    } 
    cout << "Host " << hostname -> h_name << endl;
    if ((hostname -> h_addrtype) != AF_INET) {
      continue ; 
    } 
    int jj = 0; 
    int ll = 0;    
    char *hh;  
    while ( (hh=((hostname -> h_addr_list)[jj])) != NULL ) 
    {
      cout << "  Addr: " ; 
      for (int kk=0; kk < 4; kk+=1) {
        if (kk==0) {
          cout << (unsigned short int)(hh[kk]); 
        } else {
          cout << '.' << (unsigned short int)(hh[kk]);
        }
      } 
      cout << endl;
      jj += 1;
    } 
  } 
  return 0; 
} 