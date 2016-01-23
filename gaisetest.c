/*
 * This file is part of Gaise
 * Copyright © 2013, 2014, 2016 Richard Kettlewell
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <netdb.h>

static const char *names[] = {
  "www.google.com",
  "www.facebook.com",
};

int main(int argc, char **argv) {
  size_t i;
  int only = 0;
  const struct addrinfo hints = {
    0,                          /* flags */
    AF_UNSPEC,                  /* family */
    0,                          /* socktype */
    0,                          /* protocol */
    0,
    0,
    0,
    0
  };
  struct addrinfo *res, *r;
  if(argc > 1) only = argv[1][0];
  for(i = 0; i < sizeof names / sizeof *names; ++i) {
    int v4 = 0, v6 = 0;
    int rc = getaddrinfo(names[i], "80", &hints, &res);
    if(rc) {
      fprintf(stderr, "getaddrinfo %s returned %s\n",
              names[i], gai_strerror(rc));
      fprintf(stderr, "FAILED\n");
      return 1;
    }
    for(r = res; r; r = r->ai_next) {
      switch(r->ai_family) {
      case AF_INET: ++v4; break;
      case AF_INET6: ++v6; break;
      }
    }
    printf("%s v4=%d v6=%d\n", names[i], v4, v6);
    switch(only) {
    case '4':
      if(v4) {
        fprintf(stderr, "-- expected no v4 responses\n");
        fprintf(stderr, "FAILED\n");
        return 1;
      }
      break;
    case '6':
      if(v6) {
        fprintf(stderr, "-- expected no v4 responses\n");
        fprintf(stderr, "FAILED\n");
        return 1;
      }
      break;
    }
  }
  fprintf(stderr, "OK\n");
  return 0;
}
