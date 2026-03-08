# SRE Observability Lab

Laboratório prático de **Observabilidade e CI/CD** utilizando **Kubernetes**, **Docker**, **GitHub Actions** e **Google Cloud**.

O objetivo deste projeto é demonstrar como construir um pipeline completo que:

* constrói uma aplicação containerizada
* publica imagens em um registry
* realiza deploy automático em Kubernetes
* disponibiliza stack de observabilidade
* integra logging centralizado

---

# Arquitetura do Projeto

Fluxo geral da arquitetura:

```
Developer Push
      │
      ▼
GitHub Repository
      │
      ▼
GitHub Actions (CI/CD Pipeline)
      │
      ▼
Docker Build
      │
      ▼
Artifact Registry
      │
      ▼
Google Kubernetes Engine
      │
      ▼
Kubernetes Deployment
      │
      ▼
Service (LoadBalancer)
      │
      ▼
Internet
```

---

# Stack Tecnológica

Ferramentas utilizadas no laboratório:

* Google Cloud Platform
* Google Kubernetes Engine (GKE)
* Docker
* Kubernetes
* GitHub Actions
* Artifact Registry
* Elasticsearch
* Kibana
* Filebeat

---

# Estrutura do Repositório

```
sre-observability-lab
│
├── .github/workflows/
│   └── deploy.yml
│
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
│
├── logging/
│   ├── elasticsearch.yaml
│   ├── kibana.yaml
│   └── filebeat.yaml
│
├── app/
│
├── Dockerfile
│
└── README.md
```

---

# Pipeline CI/CD

O pipeline executa automaticamente a cada **push na branch main**.

Fluxo:

```
git push
   │
   ▼
GitHub Actions
   │
   ▼
Build Docker Image
   │
   ▼
Push Image → Artifact Registry
   │
   ▼
Authenticate via Workload Identity
   │
   ▼
Connect to GKE
   │
   ▼
Update Deployment Image
   │
   ▼
Rolling Update no Kubernetes
```

---

# Build da Aplicação

A aplicação é containerizada com **Docker**.

Durante a pipeline:

```
docker build -t IMAGE_SHA .
docker push IMAGE_SHA
```

A imagem é versionada com o **SHA do commit**, garantindo:

* rastreabilidade
* rollback
* versionamento confiável

Exemplo de imagem publicada:

```
us-central1-docker.pkg.dev/sre-lab-489313/sre-repo/sre-observability-app:<commit-sha>
```

---

# Deploy no Kubernetes

O deploy ocorre no cluster **Google Kubernetes Engine**.

A pipeline executa automaticamente:

```
kubectl set image deployment/sre-app sre-app=<image_sha>
```

Isso dispara um **Rolling Update** no deployment.

Verificar status:

```
kubectl rollout status deployment sre-app
```

---

# Exposição da Aplicação

A aplicação é exposta via **Service LoadBalancer**.

Arquivo:

```
k8s/service.yaml
```

Exemplo:

```
apiVersion: v1
kind: Service
metadata:
  name: sre-app-service
spec:
  type: LoadBalancer
  selector:
    app: sre-app
  ports:
    - port: 80
      targetPort: 8080
```

Para obter o IP público:

```
kubectl get svc
```

---

# Stack de Logging

Este laboratório também inclui uma stack de logging baseada em **ELK**.

Fluxo:

```
Application
   │
   ▼
Filebeat
   │
   ▼
Elasticsearch
   │
   ▼
Kibana
```

---

# Elasticsearch

Responsável por armazenar e indexar logs.

Deploy simplificado para laboratório com baixo consumo de recursos.

Arquivo:

```
logging/elasticsearch.yaml
```

---

# Filebeat

Responsável por coletar logs dos containers do Kubernetes e enviar ao Elasticsearch.

Arquivo:

```
logging/filebeat.yaml
```

---

# Kibana

Interface gráfica para consulta e visualização de logs.

Arquivo:

```
logging/kibana.yaml
```

---

#  Passo a Passo para Subir a Estrutura

Esta seção descreve todos os comandos utilizados para provisionar e executar o laboratório.

---

## 1 - Clonar o repositório

```
git clone https://github.com/<seu-usuario>/sre-observability-lab.git
cd sre-observability-lab
```

---

## 2 - Configurar projeto no Google Cloud

Selecionar o projeto:

```
gcloud config set project sre-lab-489313
```

Verificar:

```
gcloud config list
```

---

## 3 - Criar Artifact Registry

Criar repositório Docker:

```
gcloud artifacts repositories create sre-repo \
--repository-format=docker \
--location=us-central1 \
--description="Docker repository for SRE Observability Lab"
```

---

## 4 - Criar Cluster Kubernetes

Criar cluster no GKE:

```
gcloud container clusters create sre-cluster \
--zone us-central1-a \
--num-nodes 3 \
--machine-type e2-medium
```

---

## 5 - Conectar ao Cluster

```
gcloud container clusters get-credentials sre-cluster \
--zone us-central1-a
```

Verificar nodes:

```
kubectl get nodes
```

---

## 6 - Criar Service Account para CI/CD

```
gcloud iam service-accounts create github-actions \
--display-name "GitHub Actions Service Account"
```

---

## 7 - Conceder permissões necessárias

```
gcloud projects add-iam-policy-binding sre-lab-489313 \
--member="serviceAccount:github-actions@sre-lab-489313.iam.gserviceaccount.com" \
--role="roles/container.admin"
```

```
gcloud projects add-iam-policy-binding sre-lab-489313 \
--member="serviceAccount:github-actions@sre-lab-489313.iam.gserviceaccount.com" \
--role="roles/artifactregistry.writer"
```

```
gcloud projects add-iam-policy-binding sre-lab-489313 \
--member="serviceAccount:github-actions@sre-lab-489313.iam.gserviceaccount.com" \
--role="roles/artifactregistry.reader"
```

---

## 8 - Aplicar manifests Kubernetes

```
kubectl apply -f k8s/
```

Verificar pods:

```
kubectl get pods
```

---

## 9 - Verificar serviço da aplicação

```
kubectl get svc
```

A aplicação ficará disponível no **EXTERNAL-IP**.

---

## 10 - Deploy da Stack de Logging

```
kubectl apply -f logging/elasticsearch.yaml
```

```
kubectl apply -f logging/kibana.yaml
```

```
kubectl apply -f logging/filebeat.yaml
```

---

## 11 - Verificar pods do logging

```
kubectl get pods
```

---

## 12 - Acessar Kibana

Ver IP:

```
kubectl get svc kibana
```

Abrir no navegador:

```
http://EXTERNAL-IP:5601
```

---

# Comandos Úteis

Ver todos os recursos:

```
kubectl get all
```

Ver logs de um pod:

```
kubectl logs POD_NAME
```

Descrever pod:

```
kubectl describe pod POD_NAME
```

Ver eventos do cluster:

```
kubectl get events
```

---

# Melhorias Futuras

Possíveis evoluções do laboratório:

* Prometheus para métricas
* Grafana dashboards
* Alertmanager
* Ingress Controller
* TLS com cert-manager
* OpenTelemetry
* Distributed Tracing

---

# Objetivo do Projeto

Este laboratório foi criado para praticar conceitos reais de:

* SRE
* DevOps
* Kubernetes
* Observabilidade
* CI/CD
* Cloud Infrastructure

---

# Autor

Marcio Geraldi Junior
