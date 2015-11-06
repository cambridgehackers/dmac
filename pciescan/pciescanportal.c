#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <libgen.h>

#define bufsize 256

int main(int argc, const char **argv)
{
  char buf[bufsize];
  char pciescan[bufsize];
  int rc = readlink("/proc/self/exe", buf, bufsize);
   setuid( 0 );
   snprintf(pciescan, bufsize, "%s/pciescan.sh", dirname(buf));
   fprintf(stderr, "Running %s\n", pciescan);
   system( pciescan );
   return 0;
}
