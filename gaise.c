/*
 * This file is part of Gaise
 * Copyright © 2011, 2015 Richard Kettlewell
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 */
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

#if __linux__ || __GNU__
int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints,
                struct addrinfo **res)
  __attribute__((weak, alias("__gaise_getaddrinfo")));

int __getaddrinfo(const char *node, const char *service,
                  const struct addrinfo *hints,
                  struct addrinfo **res)
  __attribute__((weak, alias("__gaise_getaddrinfo")));
#endif
