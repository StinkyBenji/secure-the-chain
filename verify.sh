#!/bin/sh

FULCIO_URL=https://fulcio-server-trusted-artifact-signer.${CLUSTER_DOMAIN}
REKOR_URL=https://rekor-server-trusted-artifact-signer.${CLUSTER_DOMAIN}
TUF_URL=https://tuf-trusted-artifact-signer.${CLUSTER_DOMAIN}
OIDC_ISSUER=https://oidc-discovery.${CLUSTER_DOMAIN}
WORKLOAD_IDENTITY=spiffe://${CLUSTER_DOMAIN}/ns/openshift-pipelines/sa/tekton-chains-controller 
IMAGE=


cosign initialize --mirror $TUF_URL --root $TUF_URL/root.json

cosign verify-attestation --rekor-url=$REKOR_URL --certificate-identity=$WORKLOAD_IDENTITY --certificate-oidc-issuer=$OIDC_ISSUER --type slsaprovenance $IMAGE

ec validate image --policy '' --image $IMAGE --rekor-url=$REKOR_URL --certificate-oidc-issuer=$OIDC_ISSUER --certificate-identity=$WORKLOAD_IDENTITY  