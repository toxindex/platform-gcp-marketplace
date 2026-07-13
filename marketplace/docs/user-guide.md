# ToxIndex on Google Cloud Marketplace

ToxIndex is a computational toxicology platform. This guide covers installing,
configuring, and operating ToxIndex on Google Kubernetes Engine via Google
Cloud Marketplace.

## Overview

A ToxIndex deployment includes:

- **kiln** — data loading and the ClickHouse analytical store
- **toxjobs** — a catalog of computational toxicology prediction tools served over HTTP
- **flow** — the workflow engine
- **sage** — an AI assistant backed by Vertex AI (optional)

ToxIndex installs and runs without a license. Licensed datasets and premium
tools become available once a license issued by Insilica is applied. To
purchase a license, contact [Insilica](https://insilica.co).

## One-time setup

### Install client tools

You need `gcloud`, `kubectl`, and `helm` installed and authenticated against
the cluster you are deploying to.

```shell
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```

### Install the Application CRD

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

### Optional: create a GCP service account for Vertex AI

The Sage AI assistant uses Vertex AI in your project through Workload
Identity. Skip this section to run without Sage's AI features.

```shell
gcloud iam service-accounts create toxindex-vertex --project PROJECT_ID

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member "serviceAccount:toxindex-vertex@PROJECT_ID.iam.gserviceaccount.com" \
  --role roles/aiplatform.user
```

Provide `toxindex-vertex@PROJECT_ID.iam.gserviceaccount.com` as the GCP
service account email during installation, then complete the Workload
Identity binding after installation (see below).

## Installation

### From the Google Cloud console

Visit the ToxIndex page on Google Cloud Marketplace, click Configure, choose
your cluster and namespace, and fill in the parameters. The license key and
Vertex AI fields are optional and can be configured later.

### From the command line

```shell
mpdev install \
  --deployer=marketplace.gcr.io/insilica/toxindex/deployer \
  --parameters='{"name": "toxindex", "namespace": "toxindex"}'
```

## Post-install configuration

### Complete the Vertex AI Workload Identity binding

After installation, bind the Kubernetes service account `sage-agent` in your
chosen namespace to the GCP service account:

```shell
gcloud iam service-accounts add-iam-policy-binding \
  toxindex-vertex@PROJECT_ID.iam.gserviceaccount.com \
  --member "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/sage-agent]" \
  --role roles/iam.workloadIdentityUser
```

### Apply or rotate a license

Licenses are delivered as a key that you store in a Secret named
`APP_INSTANCE_NAME-license`:

```shell
kubectl create secret generic toxindex-license \
  --namespace NAMESPACE \
  --from-literal=license=LICENSE_KEY \
  --dry-run=client -o yaml | kubectl apply -f -
```

The platform picks up license changes without a restart.

## Basic usage

TODO: accessing the UI, port-forwarding, Ingress and TLS setup, running a
first toxjobs workflow.

## Backup and restore

TODO: ClickHouse and Postgres backup procedures, dataset re-download on
restore.

## Updating the app

TODO: image update procedure per release track.

## Scaling

TODO: which components scale horizontally, GPU node pool guidance for the
embedder.

## Uninstalling

```shell
kubectl delete application toxindex --namespace NAMESPACE
```

Persistent volume claims are not deleted automatically. To remove them:

```shell
kubectl delete pvc --selector app.kubernetes.io/name=toxindex --namespace NAMESPACE
```
