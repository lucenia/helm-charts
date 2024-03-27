KAFKA_PROJ="lucenia-kafka"

add-helm-repos:
	helm repo add minio-operator https://operator.min.io
	helm repo add bitnamicharts https://charts.bitnami.com/bitnami

minio-install:
	helm install \
		--namespace minio-operator \
		--create-namespace \
		operator minio-operator/operator

minio-get-secret:
	kubectl get secret $(kubectl get serviceaccount console-sa --namespace opensearch -o jsonpath="{.secrets[0].name}") --namespace opensearch -o jsonpath="{.data.token}" | base64 --decode

minio-console:
	echo "Visit the Operator Console at http://127.0.0.1:9090"
	kubectl --namespace opensearch port-forward svc/console 9090:9090

minio-uninstall:
	helm uninstall minio-operator

kafka-install:
	helm install ${KAFKA_PROJ} oci://registry-1.docker.io/bitnamicharts/kafka

kafka-uninstall:
	helm uninstall ${KAFKA_PROJ}

start-producer:
	kafka-console-producer \
		--producer.config ./client.properties \
		--broker-list 10.96.169.102:9092 \
		--topic test

.PHONY: start-consumer
kafka-password:
	$(kubectl get secret lucenia-kafka-user-passwords --namespace opensearch -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d , -f 1)