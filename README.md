# DevOps Exam: Coffeeshop Microservices Platform

This repository contains infrastructure-as-code, Docker, and Kubernetes resources for deploying the Coffeeshop microservices application. It implements best practices in cloud infrastructure provisioning, container orchestration, CI/CD, and monitoring.

# Table of Contents
- [Terraform Infrastructure](#terraform-infrastructure)
- [Docker & Docker Compose](#docker--docker-compose)
- [AWS Integration](#aws-integration)
- [Kubernetes Manifests](#kubernetes-manifests)
- [CI/CD & Security](#cicd--security)
- [Monitoring](#monitoring)
- [Tips](#tips)

# Terraform Infrastructure
- Modular setup for AWS resources (VPC, EKS, RDS, EC2, etc.)
- Remote state management with S3 backend
- Environment-specific variable files
- Step
    - Create AWS account: Accesskey and SecretKey with AdminAcess
    - Workdir: `infrastructure`, install AWS CLI, Terraform
    - Create S3 unique bucket, add bucket to root `backend.tf`
    - Create modules
    - Add module to root `main.tf`: public subnet, security group, etc.
    - Refer to `variables.tf`
    - Output to `output.tf`, mention in `dev.tfvars`
    - Create terraform modules for vpc, ec2
    - Create terraform modules for eks, rds
    - Set variables:
        - Input directly when apply terraform
        - Use terraform.tfvars to store var = value, e.g. ```vpc_cidr_block = "10.0.0.0/16"```
        - Set environment with prefix TF_VAR_, e.g.  ```TF_VAR_vpc_cidr_block=10.0.0.0/16```

```sh
# terraform note
# set TF_LOG=INFO
terraform init
terraform workspace new dev
terraform workspace select dev
terraform validate # check syntax
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars #-auto-approve
terraform destroy -var-file=dev.tfvars
```

# Docker & Docker Compose
- Multi-service local development environment
- Healthchecks, persistent storage, and network configuration
```sh
# docker note
docker login
docker pull cuongopswat/go-coffeeshop-barista:latest
# Create repositories in dockerhub: khanhd6 account create repository go-coffeeshop-barista
docker tag cuongopswat/go-coffeeshop-barista:latest khanhd6/go-coffeeshop-barista:latest # latest can be ommit
docker push khanhd6/go-coffeeshop-barista:latest
```
- Create docker-compose.yaml
- Port expose:
    - Postgresql: 5432
    - RabbitMQ: 5672 and 15672
    - proxy: 5000
    - product: 5001
    - counter: 5002
    - web: 8888
- List all required services: define ports, use healthcheck, depends on, persistent storage (for postgres) and consistent networks.
- Note to use nginx service to act as a reverse proxy in front of web app for production-like setup.
```sh
# docker-compose note
docker-compose up -d
docker-compose down -v
docker-compose logs postgres

# Troubleshoot docker
sudo lsof -i :5432 # windows $ netstat -ano | findstr :5432
docker ps -a
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker network prune
sudo service docker restart
```

# AWS Integration
## EKS
- Setup Kubernetes
```sh
aws eks update-kubeconfig --region ap-southeast-1 --name prod-eks
```
## RDS
- Create PostgreSQL
- Retrieve db version
```sh
aws rds describe-db-engine-versions --engine postgres --query "DBEngineVersions[].EngineVersion"
```
## Secret Manager
- Store sensitive data
- Store secrets in secretsmanager: 
```sh
aws secretsmanager create-secret --name <>  --secret-string '{"POSTGRES_DB":<>,"POSTGRES_USER":<>,"POSTGRES_PASSWORD":<>}'
```

# Kubernetes Manifests
- Declarative YAMLs for Deployments, Services, Ingress, HPA, ConfigMaps, and Secrets
- Production-like setup with NGINX reverse proxy
- Configure kubectl for EKS
- Step: Write YAMLs for all resources
```sh
# kubectl note
kubectl get all
kubectl apply -f deployments.yaml # remember to add healthcheck
kubectl apply -f services.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secret.yaml # ensure encryption and secrets
kubectl apply -f hpa.yaml # for autoscaling
kubectl apply -f ingress.yaml # get external IP for Ingress
```
# CI/CD & Security
- Image scanning with Trivy
- Deployment automation with Helm and AWS CodePipeline

# Monitoring
- Amazon CloudWatch dashboards and alerts for resource and application health

# Tips
- Never commit secrets or `.pem` files to the repository.
- Use `terraform destroy` when not using resources to save costs.
- Use `kubectl get all` to quickly check deployed resources.