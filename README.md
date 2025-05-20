# Section Infrastructure as code # terraform (DONE)
    - Create AWS account: Accesskey and SecretKey with AdminAcess
    - Workdir: infrastrucure, install aws, terraform
    - Create s3 unique bucket, add bucket to root backend.tf
    - Create modules
    - Add module to root main.tf: public subnet, security group,...
    - Refer to variables.tf
    - Output to output.tf, mention in dev.tfvars
    $ #set TF_LOG=INFO
    $ terraform init
    $ terraform workspace new dev
    $ terraform workspace select dev
    $ terraform validate # syntax
    $ terraform plan -var-file=dev.tfvars
    $ terraform apply -var-file=dev.tfvars #-auto-approve

# Section docker (DONE)
    $ docker login
    $ docker pull cuongopswat/go-coffeeshop-barista:latest
    - Create repositories in dockerhub: khanhd6 account create repository go-coffeeshop-barista
    $ docker tag cuongopswat/go-coffeeshop-barista:latest khanhd6/go-coffeeshop-barista:latest # latest can be ommit
    $ docker push khanhd6/go-coffeeshop-barista:latest

    - Create docker-compose.yaml
    - Port expose:
        • Postgresql: 5432
        • RabbiMQ: 5672 and 15672
        • proxy: 5000
        • product: 5001
        • counter: 5002
        • web: 8888
    - List all required services: define ports, use healthcheck, depends on, persistent storage (for postgres) and consistent networks.
    - Note to use nginx service to act as a reverse prox in front of web app for production-like setup.
    $ docker-compose up -d
        - Troubleshoot
        $ docker-compose logs postgres
        $ docker-compose down -v
        $ sudo lsof -i :5432 # windows $ netstat -ano | findstr :5432
        $ docker ps -a
        $ docker stop $(docker ps -q)
        $ docker rm $(docker ps -aq)
        $ docker network prune
        $ sudo service docker restart

# Section AWS services (DOING)
EKS
    - Create terraform modules for eks, rds
    - Store secrets in secretsmanager
    $ aws secretsmanager create-secret \
  --name prod-postgres-credentials \
  --secret-string '{"POSTGRES_DB":<>,"POSTGRES_USER":<>,"POSTGRES_PASSWORD":<>}'
    - To store variables:
        . Use terraform.tfvars to store var = value, e.g. vpc_cidr_block = "10.0.0.0/16"
        . Set environment with prefix TF_VAR_, e.g.  TF_VAR_vpc_cidr_block=10.0.0.0/16
    - Configure kubectl for EKS
    $ aws eks update-kubeconfig --region ap-southeast-1 --name prod-eks
    $ kubectl get nodes
    - Write YAMLs for all resources
    $ kubectl apply -f deployments.yaml # remember to add healthcheck
    $ kubectl apply -f services.yaml
    $ kubectl apply -f configmap.yaml
    $ kubectl apply -f secret.yaml # ensure encryption and secrets
    $ kubectl apply -f hpa.yaml # for autoscaling
    $ kubectl apply -f ingress.yaml $ # get external IP for Ingress

RDS
    - Create Postgresql
    - Retrieve db version
    $ aws rds describe-db-engine-versions --engine postgres --query "DBEngineVersions[].EngineVersion"

Secret Manager
    - Store sensitive data

# Section CI/CD: AWS CodePipeline (TODO)
    - Scan the image with Trivy software
    - Push to Docker private registry
    - Deploy using Helm

# Section Monitoring System (TODO)
    - Amazon CloudWatch
    - Dashboard: monitor
        . Nodes CPU and Memory
        . Pods CPU and Memory
        . API requests
        . http requests 4xx, 5xx
    - Alert
        . Autoscaling scales to the maximum number
        . An anomaly change in ELB's RequestCount
        . High Memory or CPU usage in any component of application,
        . 5xx errors

# Note
