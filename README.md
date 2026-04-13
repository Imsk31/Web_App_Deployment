# Web App Deployment on AWS EKS

A production-grade full-stack web application deployed on Amazon EKS with automated CI/CD pipelines, infrastructure as code, secrets management, and observability.

---

## Project Overview

This project deploys a **Worker Management System** — a full-stack web application that allows users to add, view, and manage worker records. The frontend is built with Angular and served via Nginx, while the backend is a Spring Boot REST API connected to a MariaDB database on Amazon RDS.

The entire infrastructure is provisioned with Terraform, containerized with Docker, orchestrated on Amazon EKS, and deployed through Jenkins CI/CD pipelines. Secrets are managed securely via AWS Secrets Manager and the External Secrets Operator. The system includes full observability through Prometheus and Grafana, with alerts routed to SNS.

---

## Architecture Summary

The architecture follows a layered AWS VPC design across multiple Availability Zones in `us-east-1`.

### AWS VPC (`10.0.0.0/16`)

**Public Subnets** (`10.0.1-3.0/24`) contain the Internet Gateway, NAT Gateway, ALB (AWS Application Load Balancer), and an EC2 bastion instance that hosts the Jenkins agent.

**Private Subnets** (`10.0.4-6.0/24`) contain the EKS cluster worker nodes and the RDS instance — no direct internet exposure.

**DB Private Subnet Group** hosts the Amazon RDS MariaDB instance, accessible only from within the VPC.

### EKS Cluster (`production-eks-cluster`)

The cluster runs on 2 worker nodes (`t3.medium`) spread across 2 Availability Zones. Each node runs:

- **Backend pods** — Spring Boot REST API (port 8080)
- **Frontend pods** — Angular app served by Nginx (port 80)
- **External Secrets Operator (ESO)** — syncs secrets from AWS Secrets Manager into Kubernetes secrets
- **ALB Controller** — watches Ingress resources and provisions the AWS ALB
- **Prometheus + Grafana + Alertmanager** — observability stack

### Secrets Flow

AWS Secrets Manager stores RDS credentials. The ESO operator reads them via IRSA (IAM Roles for Service Accounts using OIDC) and syncs them into a Kubernetes Secret. The backend pod mounts this secret as environment variables — no credentials are hardcoded anywhere.

### Traffic Flow

Internet → IGW → ALB → Ingress resource → Frontend / Backend services → Pods → RDS

### Observability

Prometheus scrapes pod and node metrics. Grafana provides dashboards. Alertmanager routes alerts to AWS SNS, which delivers email notifications.

![Architecture Diagram](../WebApp_AWS_Architecture.jpg)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Angular 14, Nginx |
| Backend | Spring Boot 2.7.4, Java 8 |
| Database | MariaDB 11.8 on Amazon RDS |
| Container runtime | Docker |
| Container registry | DockerHub |
| Orchestration | Amazon EKS (Kubernetes 1.35) |
| Infrastructure as code | Terraform |
| CI/CD | Jenkins (3 pipelines) |
| Secrets management | AWS Secrets Manager + External Secrets Operator |
| Identity | IAM, OIDC provider, IRSA |
| Networking | AWS VPC, ALB, NAT Gateway, Security Groups |
| Observability | Prometheus, Grafana, Alertmanager, AWS SNS |
| Cloud provider | AWS (us-east-1) |

---

## Repository Structure

```
Web_App_Deployment/
├── angular-java/
│   ├── angular-frontend/     # Angular app + Dockerfile
│   └── spring-backend/       # Spring Boot app + Dockerfile
├── manifests/
│   ├── backend-deployment.yaml
│   ├── frontend-deployment.yaml
│   ├── ingress.yaml
│   └── namespace.yaml
├── Pipelines
│   ├── CD_Pipeline
│   ├── CI_Pipeline
│   └── ClusterConfig_pipeline
├── DataBase_Schema/
│   └── springbackend.sql
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── prod.tfvars
    ├── modules/
    │   ├── vpc/
    │   ├── ec2/
    │   ├── EKS_Cluster/
    │   ├── RDS/
    │   ├── OIDC/
    │   ├── AWSSecretsManager/
    │   └── aws_lb_controller/
    └── scripts/
        ├── install-lb-controller.sh
        ├── install-eso.sh
        ├── install-monitoring.sh
        └── conf-manifest-apply.sh
```
---

## Prerequisites

### Local Development

These are required to run the app on your local machine.

#### Linux (Ubuntu/Debian)

```bash
# Java 8
sudo apt update
sudo apt install openjdk-8-jdk -y
java -version

# Maven
sudo apt install maven -y
mvn -version

# Node.js 18 (via nvm — recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
node -v

# Angular CLI
npm install -g @angular/cli
ng version

# Docker
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER && newgrp docker
docker --version

# MySQL client (for schema init)
sudo apt install mysql-client -y
```

---

### AWS Account Requirements

Before running the Cluster Config pipeline, make sure your AWS account has:

- An IAM user with programmatic access and the following permissions: `AmazonEKSFullAccess`, `AmazonEC2FullAccess`, `AmazonRDSFullAccess`, `AmazonVPCFullAccess`, `IAMFullAccess`, `SecretsManagerReadWrite`, `AmazonSNSFullAccess`
- An EC2 key pair created in `us-east-1` — set the name in `prod.tfvars` as `key_name`
- The public key file path set in `prod.tfvars` as `public_key_path`
- Service quotas sufficient for 2 × `t3.medium` instances and 1 × `db.t3.micro` RDS instance

Configure your AWS credentials locally:

```bash
aws configure
# AWS Access Key ID: <your key>
# AWS Secret Access Key: <your secret>
# Default region: us-east-1
# Default output format: json
```

---


### Jenkins Agent Requirements

The EC2 bastion instance provisioned by Terraform serves as the Jenkins agent. The `user-data.sh` script in the `ec2` module automatically installs all required tools on first boot:

- Java 17 (for Jenkins remoting)
- AWS CLI v2
- Docker
- Terraform
- kubectl
- Helm
- MySQL client

No manual setup is needed on the agent — Terraform handles it.




## Setup — Run Locally

### Prerequisites

- Docker
- Java 8+
- Node.js 16+
- Maven

### 1. Clone the repo

```bash
git clone https://github.com/Imsk31/Web_App_Deployment.git
cd Web_App_Deployment
```

### 2. Start a local MariaDB instance

```bash
docker run -d \
  --name local-mariadb \
  -e MYSQL_ROOT_PASSWORD=YOUR_DB_PASS \
  -e MYSQL_DATABASE=springbackend \
  -p 3306:3306 \
  mariadb:11.8
```

### 3. Apply the database schema

```bash
mysql -h 127.0.0.1 -u root -p YOUR_DB_PASS springbackend \
  < DataBase_Schema/springbackend.sql
```

### 4. Run the backend

```bash
cd angular-java/spring-backend

# Set env vars
export DB_HOST=127.0.0.1:3306
export DB_USERNAME=root
export DB_PASSWORD=YOUR_DB_PASS

mvn spring-boot:run
# Backend available at http://localhost:8080
```

### 5. Run the frontend

```bash
cd angular-java/angular-frontend
npm install
ng serve
# Frontend available at http://localhost:4200
```

> Update `src/assets/config.json` to point `apiUrl` to `http://localhost:8080` for local development.

---

## CI/CD Pipeline

Three separate Jenkins pipelines run in sequence, each with automatic rollback on failure.

### Pipeline 1 — Cluster Config

**Trigger:** Manual on infrastructure changes.

Provisions the entire AWS infrastructure and configures the Kubernetes cluster:

1. `terraform init` + `terraform plan -var-file="filename.tfvars" ` + `terraform apply -var-file="filename.tfvars" ` — creates VPC, EKS, RDS, IAM roles, OIDC provider, Secrets Manager secret
2. Installs the AWS Load Balancer Controller via Helm
3. Installs the External Secrets Operator via Helm
4. Installs the Prometheus monitoring stack via Helm
5. Applies Kubernetes config — creates namespace, ServiceAccount, SecretStore, ExternalSecret, ConfigMap
6. Initializes the RDS database schema

### Pipeline 2 — CI (Build & Push)

**Trigger:** Automatically after a `git push` to `main`.

Builds and publishes Docker images:

1. Clones the repository
2. Builds the Spring Boot backend image — `docker build ./angular-java/spring-backend`
3. Builds the Angular frontend image — `docker build ./angular-java/angular-frontend`
4. Pushes both images to DockerHub with `:latest` and `:<BUILD_NUMBER>` tags
5. On success, automatically triggers the CD pipeline

### Pipeline 3 — CD (Deploy)

**Trigger:** Automatically triggered by the CI pipeline on successful image push.

Deploys the new images to the EKS cluster:

1. Configures AWS credentials and updates `kubeconfig`
2. `kubectl apply -f manifests/` — applies all Kubernetes manifests
3. `kubectl rollout restart deployment/backend` — triggers rolling update
4. `kubectl rollout restart deployment/frontend` — triggers rolling update
5. Waits for rollout completion with a 120s timeout
6. On failure — collects pod logs and events, then runs `kubectl rollout undo`

### Rollback

Both the CI and CD pipelines capture failure logs automatically. The CD pipeline runs `kubectl rollout undo` on both deployments if any stage fails, restoring the previous working image.

---

## Jenkins Credentials Required

| Credential ID | Type | Used In |
|---|---|---|
| `aws_access_key_id` | Secret string | All pipelines |
| `aws_secret_access_key` | Secret string | All pipelines |
| `dockerhub_creds` | Username/password | CI pipeline |
| `db_creds` | Username/password | Cluster config pipeline |

---

## Author

**Shubham Kalekar** — [github.com/Imsk31](https://github.com/Imsk31)
