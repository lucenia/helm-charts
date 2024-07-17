<img src="https://lucenia.io/wp-content/uploads/2024/07/Asset_38Lucenia_H_LB_NS.png" height="84px">

- [Lucenia Helm-Charts](#lucenia-helm-charts)
- [Status](#status)
- [Version and Branching](#version-and-branching)
- [Installation](#installation)


# Lucenia Helm Charts

This repository contains the Helm charts for Lucenia's products.

## Lucenia

The [Lucenia Helm chart](./lucenia) defines resources for deploying Lucenia on Kubernetes. See the [Lucenia documentation](./lucenia/README.md) and [values](./lucenia/values.yaml) for more information on configuring and deploying Lucenia.

## Status

[![Lint and Test Charts](https://github.com/lucenia/helm-charts/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/lucenia/helm-charts/actions/workflows/lint-test.yaml)
 [![Release Charts](https://github.com/lucenia/helm-charts/actions/workflows/release.yaml/badge.svg)](https://github.com/lucenia/helm-charts/actions/workflows/release.yaml)

## Version and Branching
As of now, this helm-charts repository maintains two branches:
* _main_ (Version is 0.x.x for both `version` and `appVersion` in `Chart.yaml`)
* _gh-pages_ (Reserved branch for publishing helm-charts through github pages)
<br>

Contributors should choose the corresponding branch(es) when commiting their change(s):
* If you have a change for a specific version, only open PR to specific branch
* If you have a change for all available versions, first open a PR on `main`, then open a backport PR with `[backport 1.x]` in the title, with label `backport 1.x`, etc.
* No changes should be commited to `gh-pages` by any contributor, as this branch should be only changed by github actions `chart-releaser` 

## Kubernetes Version Support
* This helm-chart repository is tested with kubernetes version 1.19 and above

## Installation

To install the Lucene Helm charts, execute the following commands:

```shell
helm repo add lucenia https://lucenia.github.io/helm-charts/
helm repo update
```

Once the charts repository reference is added, you can run the following command to see the charts.

```shell
helm search repo lucenia
```

You can now deploy charts with this command.

```shell
helm install my-deployment lucenia/<chart name>
```

Please see the `README.md` in the [Lucenia](charts/lucenia) directory for installation instructions.

## Kafka

Kafka can be accessed by consumers via port 9092 on the following DNS name from within your cluster:

    lucenia-kafka.lucenia.svc.cluster.local

Each Kafka broker can be accessed by producers via port 9092 on the following DNS name(s) from within your cluster:

    lucenia-kafka-controller-0.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092
    lucenia-kafka-controller-1.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092
    lucenia-kafka-controller-2.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092

The CLIENT listener for Kafka client connections from within your cluster have been configured with the following security settings: - SASL authentication

To connect a client to your Kafka, you need to create the 'client.properties' configuration files with the content below:

```java
security.protocol=SASL_PLAINTEXT
sasl.mechanism=SCRAM-SHA-256
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="user1" \
    password="$(kubectl get secret lucenia-kafka-user-passwords --namespace lucenia -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)";
```

To create a pod that you can use as a Kafka client run the following commands:

```bash
kubectl run lucenia-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.7.0-debian-12-r0 --namespace lucenia --command -- sleep infinity
kubectl cp --namespace lucenia ./client.properties lucenia-kafka-client:/tmp/client.properties
kubectl exec --tty -i lucenia-kafka-client --namespace lucenia -- bash
```

PRODUCER:

```bash
kafka-console-producer.sh \
    --producer.config /tmp/client.properties \
    --broker-list lucenia-kafka-controller-0.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092,lucenia-kafka-controller-1.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092,lucenia-kafka-controller-2.lucenia-kafka-controller-headless.lucenia.svc.cluster.local:9092 \
    --topic test
```

CONSUMER:

```bash
kafka-console-consumer.sh \
    --consumer.config /tmp/client.properties \
    --bootstrap-server lucenia-kafka.lucenia.svc.cluster.local:9092 \
    --topic test \
    --from-beginning
```
