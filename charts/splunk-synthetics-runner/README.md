## Splunk Synthetic Monitoring - Kubernetes Private Locations

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.19.3](https://img.shields.io/badge/AppVersion-0.19.3-informational?style=flat-square)

Helm chart to deploy [private location runners](https://docs.splunk.com/observability/en/synthetics/test-config/private-locations.html) for [Splunk Synthetic Monitoring](https://www.splunk.com/en_us/products/synthetic-monitoring.html).

### Installing the Chart

To install the chart with the release name `my-splunk-synthetics-runner`:

```console
$ helm repo add synthetics-helm-charts https://splunk.github.io/synthetics-helm-charts/
$ helm install my-splunk-synthetics-runner release synthetics-helm-charts/splunk-synthetics-runner
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Inter-pod and node affinity/anti-affinity rules. |
| automountServiceAccountToken | bool | `true` | Indicates whether a service account token should be automatically mounted to the runner pod. |
| commonLabels | object | `{}` | Additional labels which will be included on all objects and as selectors. |
| containerSecurityContext | object | `{}` | Container security context for runner container. |
| dnsConfig | object | `{}` | Specify additional DNS parameters for the runner pods. |
| dnsPolicy | string | `"ClusterFirst"` | DNS Policy to set for the runner pods. Valid values are ClusterFirst, ClusterFirstWithHostNet, Default, None |
| env | object | `{}` | Additional environment variables as map. |
| fullnameOverride | string | `""` | Overrides fully qualified app name |
| hostAliases | list | `[]` | List of hosts/IPs to be injected into the pod's hosts file. |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/signalfx/splunk-synthetics-runner","tag":""}` | Configuration for container image for Splunk synthetics runner |
| image.tag | string | `""` | Override the image tag; default is the chart appVersion. |
| imagePullSecrets | list | `[]` | ImagePullSecrets to use for pulling the images in use. |
| livenessProbe.enabled | bool | `true` | Enable liveness probe |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `300` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `10` |  |
| nameOverride | string | `""` | Overrides app name |
| nodeSelector | object | `{}` | Selector for the runner pods to fit on a node. |
| podAnnotations | object | `{}` | Additional annotations for runner pods. |
| podDisruptionBudget | object | `{"enabled":true,"minAvailable":1}` | Pod distruption budget |
| podLabels | object | `{}` | Additional labels for runner pods. |
| podSecurityContext | object | `{}` | Pod security context for runner pods. |
| priorityClassName | string | `""` | Priority class for runner pods |
| replicaCount | int | `1` | Count of runner pods. |
| resources | object | `{"limits":{"cpu":2,"memory":"8G"},"requests":{"cpu":2,"memory":"8G"}}` | Resources for runner container. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | ServiceAccount config. Note that the runner pod does not need access to k8s api for its operation. |
| serviceAccount.annotations | object | `{}` | Annotations to add to service account |
| serviceAccount.create | bool | `true` | If true, service account will be created. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set, the release's fullname will be used when create is true. Set this variable to add user created service account to pod. |
| synthetics | object | `{"additionalCaCerts":{},"enableNetworkShaping":true,"logLevel":"info","secret":{"create":false,"name":"","runnerToken":""}}` | Splunk Synthetics Runner configurations |
| synthetics.additionalCaCerts | object | `{}` | Add custom CA certs (should be in PEM format) to use in API/HTTP tests. Requires privilege escalation in an init container which adds these certs to the runner's system cacerts. |
| synthetics.enableNetworkShaping | bool | `true` | Enable netwrok shapping capabilities which allows runner to simulate different device's throughputs. Needs privilege escalation and CAP_NET_ADMIN. |
| synthetics.logLevel | string | `"info"` | logLevel is to set log level of the Splunk Synthetics runner. Available values are: debug, info, warn, error |
| synthetics.secret | object | `{"create":false,"name":"","runnerToken":""}` | Private location token configuration. |
| synthetics.secret.create | bool | `false` | Option for creating a new secret or using an existing one. When true, a new kubernetes secret will be created by the chart that will contain value from runnerToken. When false, the user must set secret.name to the name of the k8s secret the user created with the runner's token. |
| synthetics.secret.name | string | `""` | The name of the secret created by chart (if name is empty the default name is used) or the name of a secret that the user created. If secret is created outside of the helm chart, make sure the key for token is 'runner_token' in the secret. The chart references this key when passing token as env variable. |
| synthetics.secret.runnerToken | string | `""` | Used when sythentics.secret.create=true. The runner's token available in Splunk Observability when Private Location was created. |
| terminationGracePeriodSeconds | int | `10` | Duration in seconds the pod needs to terminate gracefully. |
| tolerations | list | `[]` | Tolerations to attach to runner pods for node taints. |
| updateStrategy | object | `{}` | Configure update strategy for runner pods. |
| volumeMounts | list | `[]` | Additional volumeMounts to add to the runner deployment. |
| volumes | list | `[]` | Additional volumes to add to runner deployment. |
