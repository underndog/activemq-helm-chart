## ActiveMQ Artemis Helm Chart

This Helm chart deploys Apache ActiveMQ Artemis on Kubernetes, providing a reliable and scalable message broker.

## Overview

Apache ActiveMQ Artemis is a multi-protocol, embeddable, high performance, clustered, asynchronous messaging system. This Helm chart provides a complete deployment solution for ActiveMQ Artemis on Kubernetes, including:

*   StatefulSet deployment
*   Persistent storage
*   Configuration management
*   Authentication
*   Service exposure
*   Health checks

## Prerequisites

*   Kubernetes 1.16+
*   Helm 3.0+
*   PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-activemq`:

```plaintext
helm install my-activemq ./active-mq
```

The command deploys ActiveMQ Artemis on the Kubernetes cluster with default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-activemq` deployment:

```plaintext
helm delete my-activemq
```

## Parameters

### Global Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `nameOverride` | String to partially override the release name | `""` |
| `fullnameOverride` | String to fully override the release name | `""` |
| `replicaCount` | Number of ActiveMQ replicas | `1` |

### Image Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `image.repository` | ActiveMQ Artemis image repository | `apache/activemq-artemis` |
| `image.tag` | ActiveMQ Artemis image tag | `2.39.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets | `[]` |

### Security Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `serviceAccount.create` | If true, create a service account | `true` |
| `serviceAccount.automount` | Automatically mount service account token | `true` |
| `serviceAccount.annotations` | Annotations for service account | `{}` |
| `serviceAccount.name` | Service account name to use | `""` |
| `authentication.create` | If true, create a secret for authentication | `true` |
| `authentication.existingSecret` | Name of existing secret to use | `""` |
| `authentication.defaultUsername` | Default username if not using existing secret | `admin` |
| `authentication.defaultPassword` | Default password if not using existing secret | `""` (random) |
| `authentication.secretKeys.username` | Key name for username in the secret | `ACTIVEMQ_USER` |
| `authentication.secretKeys.password` | Key name for password in the secret | `ACTIVEMQ_PASSWORD` |
| `podSecurityContext.fsGroup` | Group ID (1001) corresponding to 'artemis' group in container. Required for volume permissions. | `1001` |

### Pod Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `podAnnotations` | Annotations for pods | `{"prometheus.io/scrape": "true", "prometheus.io/port": "9404"}` |
| `podLabels` | Additional labels for pods | `{}` |
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity for pod assignment | `{}` |

### Service Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.ports` | Service ports configuration | See [values.yaml](values.yaml) |

### Health Checks

| Parameter | Description | Default |
| --- | --- | --- |
| `livenessProbe` | Liveness probe configuration | See [values.yaml](values.yaml) |
| `readinessProbe` | Readiness probe configuration | See [values.yaml](values.yaml) |

### Storage Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `persistence.claimName` | Name of the PersistentVolumeClaim | `pvc-activemq-artemis` |
| `persistence.size` | PVC size | `10Gi` |
| `persistence.storageClass.create` | Create a StorageClass | `true` |
| `persistence.storageClass.name` | StorageClass name | `gp3` |
| `persistence.storageClass.provisioner` | StorageClass provisioner | `ebs.csi.aws.com` |
| `persistence.storageClass.parameters` | StorageClass parameters | See [values.yaml](values.yaml) |
| `persistence.storageClass.reclaimPolicy` | StorageClass reclaim policy | `Retain` |
| `persistence.storageClass.volumeBindingMode` | StorageClass volume binding mode | `WaitForFirstConsumer` |

### Volume Settings

| Parameter | Description | Default |
| --- | --- | --- |
| `volumes` | Additional volumes | See [values.yaml](values.yaml) |
| `volumeMounts` | Additional volume mounts | See [values.yaml](values.yaml) |

### Environment Variable Container

| Parameter | Description | Default |
| --- | --- | --- |
| `envVars` | Environment Variable for ActiveMQ Artemis | See [values.yaml](values.yaml) |

```plaintext
### Example:
envVars:
  JDK_JAVA_OPTIONS: -Xms512M -Xmx1G -Xlog:gc=debug:file=/tmp/gc.log
```

## Configuration

### ActiveMQ Configuration

The ActiveMQ configuration is stored in a ConfigMap and mounted to the container. The following files are included:

*   `broker.xml` - Main broker configuration
    

You can customize the `broker.xml` files by modifying brokerXml in [values.yaml](values.yaml).  
Example:

```plaintext
config:
  brokerXml:
    global-max-size: 100Mb
```

The above config will be custom **\<global-max-size>100Mb\</global-max-size>** in`broker.xml`

### Authentication

1.  **Create a new secret** (default behavior):
    *   Set `authentication.create` to `true`
    *   Username: `admin` (configurable via `authentication.defaultUsername`)
    *   Password: Random 16-character string (configurable via `authentication.defaultPassword`)
    *   Secret keys are customizable:
        *   Username key: Set with `authentication.secretKeys.username` (default: `ACTIVEMQ_USER`)
        *   Password key: Set with `authentication.secretKeys.password` (default: `ACTIVEMQ_PASSWORD`)
2.  **Use an existing secret**:
    *   Set `authentication.existingSecret` to the name of your secret
    *   Configure the key names to match your existing secret:
        *   Username key: Set with `authentication.secretKeys.username`
        *   Password key: Set with `authentication.secretKeys.password`
3.  **No secret creation**:
    *   Set `authentication.create` to `false` and don't provide `authentication.existingSecret`
    *   Default username and password to login into ActiveMQ are `artemis`/`artemis` if no authentication is configured

## Persistence

The chart mounts a Persistent Volume for storing ActiveMQ data. The volume is claimed using a PersistentVolumeClaim with the name specified in `persistence.claimName` (defaults to `pvc-activemq-artemis`). The default storage size is 10Gi.

## Accessing ActiveMQ

The chart exposes the following ports:

*   61613: STOMP
*   5672: AMQP
*   8161: Web Console
*   1099: JMX
*   1098: RMI Registry
*   61616: Core protocols (CORE, AMQP, STOMP, HORNETQ, MQTT, OPENWIRE)

### Web Console

The ActiveMQ web console is available at port 8161. To access it from outside the cluster:

```plaintext
kubectl port-forward svc/my-activemq 8161:8161
```

Then open http://localhost:8161/console in your browser.

## Metrics and Monitoring

The chart includes Prometheus annotations for scraping metrics. The metrics are exposed on port 9404.

## Chart Structure

```plaintext
active-mq/
├── Chart.yaml                 # Chart metadata
├── values.yaml                # Default configuration values
├── templates/
│   ├── _helpers.tpl           # Helper templates
│   ├── configmap.yaml         # ActiveMQ configuration
│   ├── storageclass.yml       # Storage class definition
│   ├── NOTES.txt              # Usage notes
│   ├── pvc.yaml               # Persistent volume claim
│   ├── secret.yaml            # Authentication secret
│   ├── service.yaml           # Service definition
│   ├── serviceaccount.yaml    # Service account
│   └── statefulset.yaml       # Main ActiveMQ deployment
└── charts/                    # Chart dependencies (if any)
```

## Customization

To customize the chart, create a `values.yaml` file with your changes and use it when installing:

```plaintext
helm install my-activemq ./active-mq -f my-values.yaml
```

## Troubleshooting

### Checking Logs

```plaintext
kubectl logs -f deployment/my-activemq
```

### Checking Pod Status

```plaintext
kubectl get pods -l app=my-activemq
```

## Create Helm Package

### Commands

```plaintext
helm package ./active-mq --destination .
helm repo index ./ --url  https://underndog.github.io/activemq-helm-chart
```

## License

Apache ActiveMQ Artemis is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).