
# SRE Observability Lab

Projeto de desafio SRE utilizando Kubernetes no GCP com stack completa de observabilidade.

## Stack
- GKE
- Prometheus
- Grafana
- Elasticsearch
- Kibana
- Filebeat
- GitHub Actions CI/CD

## Arquitetura

Application → Kubernetes → Prometheus + Grafana (metrics)
Application → Filebeat → Elasticsearch → Kibana (logs)

---

## 1. Criar cluster

gcloud container clusters create sre-cluster \
--num-nodes=2 \
--machine-type=e2-medium \
--zone=us-central1-a

## 2. Conectar ao cluster

gcloud container clusters get-credentials sre-cluster --zone us-central1-a

## 3. Deploy da aplicação

kubectl apply -f k8s/

## 4. Instalar Prometheus + Grafana

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack

## 5. Instalar Elastic Stack

helm repo add elastic https://helm.elastic.co
helm repo update

helm install elasticsearch elastic/elasticsearch
helm install kibana elastic/kibana
helm install filebeat elastic/filebeat

## 6. CI/CD
Trigger CI pipeline

Pipeline automática usando GitHub Actions.
=======
# sre-observability-lab
>>>>>>> fb60d0370e712561e290e89fc71037565867cfca
