# ToxIndex on Google Cloud Marketplace

ToxIndex is a computational toxicology platform by [Insilica](https://insilica.co). This repository contains deployment assets for installing ToxIndex from Google Cloud Marketplace.

## Prerequisites

- A GKE cluster (1.27+) with at least 2 nodes of `e2-standard-4` or equivalent
- `kubectl` configured to access your cluster
- The [Application CRD](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/crd/app-crd.yaml) installed on your cluster
- [mpdev](https://github.com/GoogleCloudPlatform/marketplace-k8s-app-tools/blob/master/docs/mpdev-references.md) (Marketplace development tool)

## Quick install with Google Cloud Marketplace

Visit the [ToxIndex listing](https://console.cloud.google.com/marketplace/product/insilica-public/toxindex) on Google Cloud Marketplace and click **Configure**.

## Command-line deployment

### Install the Application CRD

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

### Create a namespace

```shell
kubectl create namespace toxindex
```

### Install ToxIndex

```shell
mpdev install \
  --deployer=us-docker.pkg.dev/insilica-public/toxindex/deployer:0.4 \
  --parameters='{"name": "toxindex", "namespace": "toxindex"}'
```

### Optional parameters

| Parameter | Description |
|---|---|
| `marketplace.licenseKey` | License key issued by Insilica. The app runs without one; licensed datasets and tools become available after a valid key is applied. |
| `sage.agent.serviceAccount.gcpServiceAccount` | Email of a GCP service account with `roles/aiplatform.user`. Enables the Sage AI assistant via Workload Identity. |
| `sage.agent.vertex.project` | GCP project ID for Vertex AI requests. Required if a service account is set. |
| `sage.agent.vertex.region` | Region for Vertex AI requests (e.g. `us-central1`). |

Example with all options:

```shell
mpdev install \
  --deployer=us-docker.pkg.dev/insilica-public/toxindex/deployer:0.4 \
  --parameters='{
    "name": "toxindex",
    "namespace": "toxindex",
    "marketplace.licenseKey": "your-license-key",
    "sage.agent.serviceAccount.gcpServiceAccount": "sage@your-project.iam.gserviceaccount.com",
    "sage.agent.vertex.project": "your-project",
    "sage.agent.vertex.region": "us-central1"
  }'
```

### Uninstall

```shell
kubectl delete application toxindex -n toxindex
```

## Support

Contact [info@insilica.co](mailto:info@insilica.co) for questions or issues.
