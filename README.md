# AWS Three-Tier Platform

Infraestructura AWS **three-tier production-grade** desplegada con Terraform.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                   │
│                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐   │
│  │   PUBLIC    │     │  PRIVATE    │     │    DB       │   │
│  │   TIER      │     │   TIER      │     │    TIER     │   │
│  │             │     │             │     │             │   │
│  │  ┌───────┐  │     │  ┌───────┐  │     │  ┌───────┐  │   │
│  │  │  ALB  │──┼────▶│  │  ECS  │──┼────▶│  │  RDS  │  │   │
│  │  │ :80   │  │     │  │ :8080 │  │     │  │ :5432 │  │   │
│  │  └───────  │     │  └───────┘  │     │  └───────┘  │   │
│  │             │     │             │     │             │   │
│  │  ┌───────┐  │     │  ┌───────┐  │     │             │   │
│  │  │  NAT  │  │     │  │ Farg. │  │     │             │   │
│  │  │  GW   │  │     │  │ Tasks │  │     │             │   │
│  │  └───────┘  │     │  └───────┘  │     │             │   │
│  └─────────────┘     └─────────────┘     └─────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Services: ECR, CloudWatch, S3 (state), DynamoDB    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Stack Tecnológico

| Capa | Tecnología | Detalles |
|------|------------|----------|
| **Frontend/Load Balancing** | Application Load Balancer | HTTP :80, health checks `/health` |
| **Application** | ECS Fargate | 2 tasks, 256 CPU, 512MB RAM, Python/Flask |
| **Database** | RDS PostgreSQL | db.t3.micro, 15.10, 20GB gp2, encrypted |
| **Container Registry** | ECR | Scan on push enabled |
| **CI/CD** | GitHub Actions | OIDC auth, zero-downtime deployments |
| **IaC** | Terraform | Modular, remote state en S3 + DynamoDB locking |

## Requisitos Previos

- **Terraform** >= 1.5.0
- **AWS CLI** configurado con credenciales
- **Podman** o **Docker** (para builds locales)
- **Cuenta AWS** con permisos de administración

## Estructura del Proyecto

```
terraform-aws-three-tier-platform/
├── modules/
│   ├── networking/       # VPC, subnets, IGW, NAT GW
│   ├── security/         # Security Groups
│   ├── database/         # RDS PostgreSQL
│   ├── compute/          # ECS, ECR, CloudWatch
│   └── alb/              # Application Load Balancer
├── main.tf               # Root module (orchestrates all modules)
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── providers.tf
── bootstrap/            # One-time setup (S3, DynamoDB, OIDC, IAM)
├── app/                  # Sample Flask application
├── .github/workflows/    # CI/CD pipeline
├── destroy.sh            # Script de teardown
└── README.md
```

## Despliegue

### 1. Bootstrap (one-time)

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

### 2. Infraestructura Completa (Single Apply)

Desde la raíz del proyecto:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Esto despliega Networking, Security, Database, ALB y Compute en el orden correcto automáticamente.
terraform-aws-three-tier-platform/
├── bootstrap/          # S3 state, DynamoDB lock, OIDC, IAM role
── networking/         # VPC, subnets, IGW, NAT GW, route tables
├── security/           # Security Groups (ALB, ECS, RDS)
├── database/           # RDS PostgreSQL instance
├── compute/            # ECS cluster, task definition, service, ECR
├── alb/                # Application Load Balancer + target group
├── app/                # Sample Flask application
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── .github/workflows/  # CI/CD pipeline (deploy.yml)
├── .vscode/            # VS Code tasks
├── destroy.sh          # Script de teardown
└── AGENTS.md           # Guía para agentes de IA
```

## Despliegue

### 1. Bootstrap (one-time)

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

Crea: S3 state bucket, DynamoDB lock table, OIDC provider, IAM role para GitHub Actions.

### 2. Infraestructura Base

```bash
# Networking
cd ../networking && terraform init && terraform apply -auto-approve

# Security Groups
cd ../security && terraform init && terraform apply -auto-approve

# Database
cd ../database && terraform init && terraform apply -auto-approve
```

### 3. Compute y ALB

```bash
# Compute (ECS + ECR)
cd ../compute && terraform init && terraform apply -auto-approve

# ALB
cd ../alb && terraform init && terraform apply -auto-approve
```

### 4. Build y Push de Imagen

```bash
podman build -t three-tier-platform-app ./app
podman tag three-tier-platform-app:latest <ECR_URL>:latest
podman push <ECR_URL>:latest
```

### 5. CI/CD (Automático)

Cualquier push a `master` que modifique `app/` dispara el pipeline:
1. Checkout del código
2. Autenticación AWS via OIDC
3. Build y push de imagen a ECR
4. Force new deployment en ECS

## Endpoints

| Endpoint | URL | Descripción |
|----------|-----|-------------|
| **Health** | `http://<ALB_DNS>/health` | Estado de la aplicación |
| **DB Check** | `http://<ALB_DNS>/db-check` | Conectividad con PostgreSQL |

**ALB DNS:** `three-tier-platform-alb-1909808281.eu-west-1.elb.amazonaws.com`

## Recursos Creados

| Recurso | Cantidad | Notas |
|---------|----------|-------|
| VPC | 1 | `10.0.0.0/16`, 2 AZs |
| Subnets | 6 | 2 públicas, 2 privadas (app), 2 privadas (db) |
| Internet Gateway | 1 | Salida a internet para subnets públicas |
| NAT Gateway | 1 | En AZ-1a (para ECS → ECR) |
| Security Groups | 3 | ALB, ECS, RDS (least privilege) |
| RDS Instance | 1 | PostgreSQL 15.10, db.t3.micro |
| ECS Cluster | 1 | Fargate, Container Insights enabled |
| ECS Service | 1 | 2 tasks, rolling deployment |
| ECR Repository | 1 | Scan on push enabled |
| ALB | 1 | HTTP listener, target group con health checks |
| CloudWatch Log Group | 1 | Retención 7 días |
| S3 Bucket | 1 | Terraform state (encrypted) |
| DynamoDB Table | 1 | State locking |

## Destrucción

### Script automatizado

```bash
./destroy.sh
```

Destruye en orden inverso: ALB → Compute → Database → Security → Networking.

### Manual

```bash
for dir in alb compute database security networking; do
  cd $dir && terraform destroy -auto-approve && cd ..
done
```

**Nota:** El bootstrap (S3, DynamoDB, IAM) se preserva por defecto. Para destruirlo:
```bash
cd bootstrap && terraform destroy -auto-approve
```

## Costos Estimados (Free Tier)

| Recurso | Costo Mensual |
|---------|---------------|
| RDS db.t3.micro | ~$0 (free tier 750h/mes) |
| ECS Fargate (256 CPU, 512MB) | ~$8-12 |
| ALB | ~$16-18 |
| NAT Gateway | ~$32 |
| ECR Storage | ~$0.10/GB |
| **Total estimado** | **~$60-70/mes** |

## Seguridad

- **Security Groups**: Least privilege (ALB→ECS→RDS)
- **RDS**: No publicly accessible, encrypted at rest
- **ECS Tasks**: Sin IP pública, solo accesible via ALB
- **State**: Encrypted en S3, locking con DynamoDB
- **CI/CD**: OIDC authentication (sin secrets estáticos)
- **ECR**: Image scanning on push enabled

## Decisiones de Arquitectura

- **RDS PostgreSQL** en lugar de Aurora Serverless v2: compatible con free tier, menor complejidad
- **1 NAT Gateway** (en AZ-1a): aceptable para portfolio; en prod se usaría 1 por AZ
- **Fargate** en lugar de EC2: sin gestión de servidores, scaling automático
- **HTTP** en lugar de HTTPS: para simplificar; en prod se añadiría ACM certificate
- **Desired count = 2**: HA básico; en prod se ajustaría según carga

## Troubleshooting

### ECS tasks en estado PENDING
```bash
aws ecs describe-services --cluster three-tier-platform-cluster --services three-tier-platform-app-service
```

### Health checks fallando
```bash
aws elbv2 describe-target-health --target-group-arn <TG_ARN>
```

### Logs de la aplicación
```bash
aws logs tail /ecs/three-tier-platform-app --follow
```

### Verificar conectividad DB
```bash
curl http://<ALB_DNS>/db-check
```

## Autor

**Andrés** — DevOps/Platform Engineer (AWS SAA-C03)

## Licencia

MIT
