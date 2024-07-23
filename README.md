# Security Demo Instruction - SPIFFE/SPIRE

## Prerequisites
- OpenShift cluster is available
- rhtas operator installed
- openshift-pipelines operator installed
- openshift-gitops operator installed
- spire server deployed (check the **SPIFFE/SPIRE** section)

## SPIFFE/SPIRE
The SPIFFE (the Secure Production Identity Framework For Everyone) and SPIRE (the SPIFFE Runtime Environment) frameworks enable the establishment of trust between workloads across a wide variety of platforms.

We will deploy the Spire server and the associated CRDs using [helm charts](https://github.com/spiffe/helm-charts-hardened/tree/main/charts) via Argo CD. 

Remember to update the values.yaml 

```
global:
  k8s:
    clusterDomain: "CLUSTER_DOMAIN"
  openshift: true
  installAndUpgradeHooks:
    enabled: false
  deleteHooks:
    enabled: false
  spire:
    clusterName: "CLUSTER_NAME"
    trustDomain: "CLUSTER_DOMAIN"
    namespaces:
      system:
        create: true
  persistence:
    storageClass: managed-nfs-storage
  ca_subject:
    country: DE
    organization: Red Hat
    common_name: "CLUSTER_DOMAIN"
```

After that, we can create the Argo CD applications.
```
oc create -f spiffe-spire/spire-app.yaml
oc create -f spiffe-spire/spire-crd-app.yaml
```
Check out [this blog post](https://next.redhat.com/2024/06/27/spiffe-spire-on-red-hat-openshift/) for more SPIFFE/SPIRE deployment details.

Once the argo cd applicatio is synced, we should see spire-agent and spire-server, and other resources running. For next, we would configure Fulcio to use the SPIFFE as OIDC provider.

## Sigstore/Red Hat Trusted Artifact Signer
RHTAS is based on the open source project Sigstore. There is a certified Red Hat operator available on Operator Hub, which allows the easy creation/deployment of sigstore components such as cosign, rekor, fulcio and more.

important components:

* **cosign**: a client that signs/verifies software artifacts.
* **rekor**: immutable transparency log, where stores all the signed metadata of the artifacts.
  - **trillian**: general transparency Log
  - **CTlog**: certificate transparency log
* **fulcio**: certificate authority that issues code-signing certificates bound to an OIDC identity.
* **tuf (the update framework)**: a security framework designed for software update using signed metadata.

We will create the `securesign` resource by running `oc create -f rhtas/securesign.yaml`. This will in turn deploy rekor server, trillian, fulcio server, tuf repository. Before running the command, remember to replace the values in the fulcio configuration.

```
  fulcio:
    certificate:
      commonName: $CLUSTER_DOMAIN
      organizationEmail: $EMAIL
      organizationName: $ORGANIZATION_NAME
    config:
      OIDCIssuers:
        - ClientID: sigstore
          Issuer: $SPIRE_OIDC_URL
          IssuerURL: $SPIRE_OIDC_URL
          SPIFFETrustDomain: $CLUSTER_DOMAIN
          Type: spiffe
```          

## Configure Tekton Chains

once `securesign` resource is ready, we would need the URLs of Rekor, Fulcio, and SPIFFE OIDC provider to configure Tekton Chains. Check [the example tektonconfig](https://github.com/StinkyBenji/secure-the-chain/blob/feat/spiffe/tekton-chains-demo/spire/tektonconfig/tektonconfig.example.yaml).

### keyless signing
https://www.chainguard.dev/unchained/a-fulcio-deep-dive

## Demo Time
The demo includes a simple image build pipeline where the image will be signed. Additionally, SBOM and vulnerability reports will be generated separately by Syft and Grype, respectively, and attached to the image.

### Task and Pipeline
As mentioned, we use syft for generating SBOM and grype for scanning vulnerabilities. Two custom Tekton Tasks are needed (see `tekton-chains-demo/vault/tasks`). Additionally, a cosign script is added to both tasks, which will use the deployed Sigstore components to attest both generated SBOM and vulnerability report to the built image.

```

cosign initialize --mirror=$TUF_URL --root=$TUF_URL/root.json

cosign attest $(params.IMAGE)@$(tasks.build-image.results.IMAGE_DIGEST) -y --fulcio-url=$(params.fulcio-url) --rekor-url=$(params.rekor-url) --oidc-issuer=$(params.oidc-issuer-url) --predicate /attestation_tmp/attestation.sbom --type spdxjson --replace --attachment-tag-prefix sbom- 
```

Once everything is setup, we can create the pipelinerun by running
`oc create -f tekton-chains-demo/spire/pipelinerun.yaml`

### Verification

We can verify the attestation by using the `verify.sh` script.


## More to read
* [life of a sigstore signature](https://www.chainguard.dev/unchained/life-of-a-sigstore-signature)
* [Tekton Chains with Sigstore](https://tekton.dev/docs/chains/sigstore/)
* [Certificate transparency](https://certificate.transparency.dev/)
* [root signing](https://github.com/sigstore/root-signing)