#!/bin/sh

FULCIO_URL=https://fulcio-server-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
REKOR_URL=https://rekor-server-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
TUF_URL=https://tuf-trusted-artifact-signer.apps.ocp4.whatever.out-of-my-head.de
OIDC_ISSUER=https://oidc-discovery.apps.ocp4.whatever.out-of-my-head.de
WORKLOAD_IDENTITY=spiffe://apps.ocp4.whatever.out-of-my-head.de/ns/openshift-pipelines/sa/tekton-chains-controller 

cosign verify-attestation --rekor-url=$REKOR_URL --certificate-identity=$WORKLOAD_IDENTITY --certificate-oidc-issuer=$OIDC_ISSUER --type slsaprovenance quay.io/stbenji/pipelines-vote-api@sha256:1a9f17b221dbc9c50f60284ecd7bf2ec93af486cf9d2543c8af7c62b12cb9411


