//
// Created by xinshu on 23/06/25.
//

#ifndef PICOQUIC_PTLS_UTILITIES_H
#define PICOQUIC_PTLS_UTILITIES_H
#include <errno.h>
#include <netdb.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/nameser.h>
#include <resolv.h>
#include <openssl/pem.h>
#include "picotls/openssl.h"
#include "params.h"

static void setup_certificate(ptls_iovec_t *dst, const char *fn)
{
    FILE *fp;
    if ((fp = fopen(fn, "rb")) == NULL) {
        fprintf(stderr, "Failed to open cert file at %s\n", fn);
        exit(1);
    }
    X509 *cert = PEM_read_X509(fp, NULL, NULL, NULL);
    fclose(fp);

    dst->base = NULL;
    dst->len = i2d_X509(cert, &dst->base);
}

#endif //PICOQUIC_PTLS_UTILITIES_H
