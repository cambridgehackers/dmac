/* Copyright (c) 2015 Connectal Project
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <stdio.h>
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

#include "dmac.h"

#ifdef SIMULATION
int arraySize = 4*1024;
#else
int arraySize = 128*1024;
#endif
int doWrite = 1;
int doRead = 1;
int numchannels = 1;
int numiters = 1;
int burstLenBytes = 128;

int main(int argc, char * const*argv)
{
    int opt;
    while ((opt = getopt(argc, argv, "b:i:rws:")) != -1) {
	switch (opt) {
	case 'r':
	    doWrite = 0;
	    break;
	case 'w':
	    doRead = 0;
	    break;
	case 'b':
	    burstLenBytes = strtoul(optarg, 0, 0);
	    if (burstLenBytes > 128)
	      burstLenBytes = 128;
	    break;
	case 'i':
	    numiters = strtoul(optarg, 0, 0);
	    break;
	case 's': {
	    char *endptr = 0;
	    arraySize = strtoul(optarg, &endptr, 0);
	    if (endptr) {
		switch (*endptr) {
		case 'K':
		    arraySize *= 1024;
		    break;
		case 'M':
		    arraySize *= 1024*1024;
		    break;
		default:
		    break;
		}
	    }
	} break;
	default:
	    fprintf(stderr,
		    "Usage: %s [-r] [-w] [-s transferSize]\n"
		    "       -r read only\n"
		    "       -r write only\n",
		    argv[0]);
	    exit(EXIT_FAILURE);
	}
    }
    DmaController dmac;
    dmac.start();
    // do something here
    dmac.wait();
    return 0;
}
