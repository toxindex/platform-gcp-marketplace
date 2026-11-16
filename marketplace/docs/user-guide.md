# ToxIndex on Google Cloud Marketplace

ToxIndex is a computational toxicology platform. It installs into one namespace of a
GKE cluster and keeps all state on persistent volumes in that namespace.

| Component | Runs |
|---|---|
| sage | Web UI and AI assistant |
| flow | Workflow engine |
| kiln | ClickHouse warehouse, SPARQL, full-text search |
| toxjobs | Prediction tools |
| sysrev | Document review |
| git | Repository storage |
| temporal | Workflow scheduler |

## License

The platform installs and runs without a license.

| | Without a license | With a license |
|---|---|---|
| Prediction tools | None | Per license |
| Licensed datasets | None | Per license |
| Sage conversations | 5 per user per day | Per license |
| Flow runs | 2 per group per day | Per license |

For pricing, contact [Insilica](https://insilica.co).

## Machines

| Node pool | SKU | Nodes | Needed for |
|---|---|---|---|
| general | `e2-highmem-8` | 1 without a license; autoscale 2–6 with the full tool catalog | Everything |
| gpu | `g2-standard-12` (1× NVIDIA L4), GPU time-sharing with 4 clients | 1 | `reactiont5`, `pleiome`, `deeppurpose`, `esmfold` — only if your license includes them |

The full tool catalog requests 16 vCPU and 90 GiB of memory. Persistent volumes total
200 GiB on the cluster's default StorageClass. The Terraform takes both machine types as
variables.

## Vertex AI

Sage, flow and sysrev call models on Vertex AI in your project, billed to that project.
Without Vertex AI, the platform runs and every model call fails.

1. Enable `aiplatform.googleapis.com`.
2. In Model Garden, enable Claude Opus 5, Claude Opus 4.8 and Claude Sonnet 5. Gemini
   models need no enablement.
3. Create one service account with `roles/aiplatform.user`.
4. Grant it `roles/iam.workloadIdentityUser` for the Kubernetes service accounts
   `sage-agent`, `flow-engine`, `flow-worker` and `sysrev-api` in the install namespace.
5. Set these install parameters:

| Parameter | Value |
|---|---|
| `sage.agent.serviceAccount.gcpServiceAccount` | Service account email |
| `flow.engine.serviceAccount.gcpServiceAccount` | Service account email |
| `flow.worker.serviceAccount.gcpServiceAccount` | Service account email |
| `sysrev.api.serviceAccount.gcpServiceAccount` | Service account email |
| `sage.agent.vertex.project` | Project ID |
| `flow.engine.vertex.project` | Project ID |
| `sysrev.api.vertex.project` | Project ID |
| `sage.agent.vertex.region` | Vertex AI location, default `global` |
| `flow.engine.vertex.region` | Vertex AI location, default `global` |
| `sysrev.api.vertex.region` | Vertex AI location, default `global` |

## Network egress

| Host | For |
|---|---|
| `marketplace.gcr.io` | Platform images |
| `registry.toxindex.com` | Licensed tool images |
| `license.toxindex.com` | License exchange |
| `storage.googleapis.com` | Licensed datasets |
| `aiplatform.googleapis.com` | Vertex AI |

## Install

[`terraform/`](../../terraform) creates the cluster, both node pools, the Vertex AI
service account and its bindings, and outputs the install parameters. Marketplace
Kubernetes apps have no Terraform resource, so install the app itself from the console
or with Helm.

Every install needs the Application CRD:

```shell
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml
```

**Console.** On the ToxIndex Marketplace page, click Configure and enter the parameters.

**Helm.** From a checkout of this repository at a release tag:

```shell
helm install toxindex chart/toxindex \
  --namespace toxindex --create-namespace \
  --set global.license.key=LICENSE_KEY \
  --set sage.agent.serviceAccount.gcpServiceAccount=SA_EMAIL \
  --set flow.engine.serviceAccount.gcpServiceAccount=SA_EMAIL \
  --set flow.worker.serviceAccount.gcpServiceAccount=SA_EMAIL \
  --set sysrev.api.serviceAccount.gcpServiceAccount=SA_EMAIL \
  --set sage.agent.vertex.project=PROJECT_ID \
  --set flow.engine.vertex.project=PROJECT_ID \
  --set sysrev.api.vertex.project=PROJECT_ID
```

## Access

The UI is the `sage-control-plane` Service on port 80:

```shell
kubectl port-forward --namespace toxindex svc/sage-control-plane 8080:80
```

By default the UI has no login. Anyone who reaches the Service acts as its owner.

## Single sign-on

The chart includes an [oauth2-proxy](https://oauth2-proxy.github.io/oauth2-proxy/) gateway
for any OIDC identity provider. It is off by default.

| Value | Setting |
|---|---|
| `global.auth` | `gateway` |
| `gateway.enabled` | `true` |
| `gateway.oidc.enabled` | `true` |
| `gateway.oidc.issuerUrl` | Your IdP's issuer URL |
| `gateway.oidc.clientId` | OIDC client ID |
| `gateway.oidc.redirectUrl` | `https://HOST/oauth2/callback` |
| `gateway.oidc.emailDomains` | Allowed email domains, default `*` |
| `gateway.oidc.claims.user` | Claim that identifies the user, default `email` |
| `gateway.oidc.claims.group` | Claim that names the user's organization |
| `gateway.ingress.enabled` | `true` |
| `gateway.ingress.host` | `HOST` |
| `gateway.ingress.className` | Your ingress class |
| `gateway.ingress.tlsSecret` | TLS Secret for `HOST` |
| `global.images.oauth2-proxy.repository` | `quay.io/oauth2-proxy/oauth2-proxy` |
| `global.images.oauth2-proxy.tag` | `v7.15.6` |
| `global.images.oauth2-proxy.digest` | `sha256:c3415e8660af553f5e18f5d90db050614c02493c0ac6260ac59442f6d9b12048` |

The client secret goes in a Secret named `oidc` with the key `client-secret`.

## Apply or rotate a license

```shell
kubectl create secret generic tidx-license \
  --namespace toxindex \
  --from-literal=license=LICENSE_KEY \
  --dry-run=client -o yaml | kubectl apply -f -
```

The platform picks up the change without a restart.

## Backup and restore

All state is on the namespace's persistent volumes. Back up the namespace with
[Backup for GKE](https://cloud.google.com/kubernetes-engine/docs/add-on/backup-for-gke/concepts/backup-for-gke).

## Updating

Each release is a tag in this repository. For Helm installs, run `helm upgrade` with the
chart at the new tag.

## Uninstalling

Console installs:

```shell
kubectl delete application toxindex --namespace toxindex
```

Helm installs:

```shell
helm uninstall toxindex --namespace toxindex
```

Persistent volumes are not deleted. Deleting them destroys all data:

```shell
kubectl delete pvc --all --namespace toxindex
```
