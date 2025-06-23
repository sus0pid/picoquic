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

/*
  Provide a certificate signature function, based on the implementation in openssl.

static int set_openssl_sign_certificate_from_key(EVP_PKEY* pkey, ptls_context_t* ctx)
{
    int ret = 0;
    ptls_openssl_sign_certificate_t* signer;

    signer = (ptls_openssl_sign_certificate_t*)malloc(sizeof(ptls_openssl_sign_certificate_t));

    if (signer == NULL || pkey == NULL) {
        ret = -1;
    }
    else {
        ret = ptls_openssl_init_trad_sign_certificate(signer, pkey);
        ctx->sign_certificate = &signer->super;
    }

    if (pkey != NULL) {
        EVP_PKEY_free(pkey);
    }

    if (ret != 0 && signer != NULL) {
        free(signer);
    }

    return ret;
}
 */


static int setup_picoquic_certificate_verifier(ptls_context_t* ctx, unsigned int * is_cert_store_not_empty) {
    int ret = 0;
    ptls_openssl_verify_certificate_t* verifier;
    verifier = (ptls_openssl_verify_certificate_t*)malloc(sizeof(ptls_openssl_verify_certificate_t));

    /* setup ca store */
//    assert(root_ca_path != NULL);
    printf("[%s] setting up root ca: certs/test-ca.crt, line%d\n", __func__, __LINE__);
    X509_STORE *store;
    X509_LOOKUP *lookup;

    if ((store = X509_STORE_new()) == NULL)
        goto Error;

    /* load our default trad ca file for testing @xinshu*/
    if ((lookup = X509_STORE_add_lookup(store, X509_LOOKUP_file())) == NULL)
        goto Error;
    if (X509_LOOKUP_load_file(lookup, "certs/test-ca.crt", X509_FILETYPE_PEM) != 1)
    {
        fprintf(stderr, "failed to load ca/test-ca.crt file\n");
        goto Error;
    }

    if ((lookup = X509_STORE_add_lookup(store, X509_LOOKUP_hash_dir())) == NULL)
        goto Error;
    X509_LOOKUP_add_dir(lookup, NULL, X509_FILETYPE_DEFAULT);

    ret = ptls_openssl_init_verify_certificate(verifier, store);
    /* setup verifier handler in ctx */
    ctx->verify_certificate = &verifier->super;
    *is_cert_store_not_empty = 1;
Error:
if (ret != 0 && verifier != NULL)
    free(verifier);
if (store != NULL)
    X509_STORE_free(store);
return ret;
}

#endif //PICOQUIC_PTLS_UTILITIES_H
