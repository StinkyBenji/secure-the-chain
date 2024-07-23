# Secure the chain!

## Prerequisites
You need an OpenShift cluster ->

operators: 
- openshift-pipelines operator
- openshift-gitops operator (optional)
- rhtas operator (necessary for SPIFFE/SPIRE demo)

CLI:
- oc 
- cosign 
- vault 

You can run `oc apply -f operators/<operator>/subscription.yaml` to install the operators or install them from OperatorHub.

## Introduction

Software supply chain security is a crucial topic these days. There are many technologies that help us achieve a more secure software delivery process. In this repository, we will use Tekton and configure Tekton Chains for building and signing container image. Enterprise Contrac (TBD) is used for verifying the image and enforcing policies about the delivery pipleline.

### Tekton Chains
Assuming that you are familiar with basic concepts of Tekton (otherwise, check out [this](https://tekton.dev/docs/concepts/overview/)). Tekton Chains is essentially a Kubernetes controller that observes all the `TaskRun` and `PipelineRun` resources in your cluster. Based on its configuration, it can sign OCI images, TaskRuns and PipelineRuns! It supports **x509** and **kms** as artifact signer.

### Security Demo - HashiCorp Vault

For using vault for demo-ing switch to branch `feat/vault`

In this demo, we will configure HashiCorp Vault as kms signer for Tekton Chains, detailed instruction is in the branch `feat/vault`

### Security Demo - SPIFFE/SPIRE

For using SPIFFE/SPIRE with RHTAS (Sigstore) for demo-ing switch to branch `feat/spiffe`

In this demo, we will configure Fulcio as x509 signer for Tekton Chains, detailed instruction is in the branch `feat/spiffe`


## Relevant Links

- [SPIFFE/SPIRE](https://spiffe.io/)
- [Tekton Chains](https://tekton.dev/docs/chains/)
- [Hashicorp Vault](https://www.vaultproject.io/)
- [Sigstore](https://www.sigstore.dev/)
- [Syft](https://github.com/anchore/syft)
- [Grype](https://github.com/anchore/grype)
- [Enterprise Contract](https://enterprisecontract.dev/)