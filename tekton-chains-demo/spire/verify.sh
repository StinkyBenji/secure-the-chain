#!/bin/sh

FULCIO_URL=https://fulcio-server-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
REKOR_URL=https://rekor-server-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
TUF_URL=https://tuf-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
OIDC_ISSUER=https://oidc-discovery.apps.ocp4.whatever.out-of-my-head.de
WORKLOAD_IDENTITY=spiffe://apps.ocp4.whatever.out-of-my-head.de/ns/openshift-pipelines/sa/tekton-chains-controller 
IMAGE=quay.io/stbenji/pipelines-vote-api:0.1.0


cosign initialize --mirror $TUF_URL --root $TUF_URL/root.json

cosign verify-attestation --rekor-url=$REKOR_URL --certificate-identity=$WORKLOAD_IDENTITY --certificate-oidc-issuer=$OIDC_ISSUER --type slsaprovenance $IMAGE

ec validate image --policy '' --image $IMAGE --rekor-url=$REKOR_URL --certificate-oidc-issuer=$OIDC_ISSUER --certificate-identity=$WORKLOAD_IDENTITY  