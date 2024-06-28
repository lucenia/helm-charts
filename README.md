# Lucenia Helm Charts

This repository contains the Helm charts for Lucenia's products.

## Lucenia

The [Lucenia Helm chart](./lucenia) defines resources for deploying Lucenia on Kubernetes. See the [Lucenia documentation](./lucenia/README.md) and [values](./lucenia/values.yaml) for more information on configuring and deploying Lucenia.

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
