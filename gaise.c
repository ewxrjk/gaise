#define _GNU_SOURCE
#include <netdb.h>
#include <dlfcn.h>
#include <stdlib.h>

#ifndef LIBC_GETADDRINFO
# define LIBC_GETADDRINFO "getaddrinfo"
#endif

static void addrinfo_remove(int familyToRemove,
                            struct addrinfo **aip) {
  struct addrinfo *ai;

  while((ai = *aip)) {
    if(ai->ai_family == familyToRemove) {
      *aip = ai->ai_next;
      ai->ai_next = NULL;
      freeaddrinfo(ai);
    } else {
      aip = &ai->ai_next;
    }
  }
}

int __gaise_getaddrinfo(const char *node, const char *service,
                        const struct addrinfo *hints,
                        struct addrinfo **res) {
  int (*real_getaddrinfo)(const char *node, const char *service,
                          const struct addrinfo *hints,
                          struct addrinfo **res);
  int rc;
  real_getaddrinfo = dlsym(RTLD_NEXT, LIBC_GETADDRINFO);
  rc = real_getaddrinfo(node, service, hints, res);
  if(!rc) {
    if(getenv("GAISE_REMOVE_IPV6"))
      addrinfo_remove(AF_INET6, res);
    if(getenv("GAISE_REMOVE_IPV4"))
      addrinfo_remove(AF_INET, res);
    if(*res == NULL)
      rc = EAI_NODATA;
  }
  return rc;
}

#if __linux__
int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints,
                struct addrinfo **res)
  __attribute__((weak, alias("__gaise_getaddrinfo")));

int __getaddrinfo(const char *node, const char *service,
                  const struct addrinfo *hints,
                  struct addrinfo **res)
  __attribute__((weak, alias("__gaise_getaddrinfo")));
#endif
