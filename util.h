/* See LICENSE file for copyright and license details. */
#include <stdio.h>

#define MAX(A, B)               ((A) > (B) ? (A) : (B))
#define MIN(A, B)               ((A) < (B) ? (A) : (B))
#define BETWEEN(X, A, B)        ((A) <= (X) && (X) <= (B))
#define CLAMP(A,MAX,MIN)		(BETWEEN(A,MIN,MAX)?A:(A>MAX?MAX:MIN))

void die(const char *fmt, ...);
void *ecalloc(size_t nmemb, size_t size);
