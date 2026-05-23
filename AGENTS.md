# AGENTS.md — terraform-aws-three-tier-platform

## Contexto del Proyecto

Infraestructura AWS **three-tier production-grade** usando Terraform.
- **Autor**: Andrés (DevOps/Platform Engineer, AWS SAA-C03)
- **Repo**: `Andrs12/terraform-aws-three-tier-platform`
- **Región**: `eu-west-1`
- **Cuenta AWS**: `900881669003`
- **Nombre del proyecto**: `three-tier-platform`

## Arquitectura

```
Pública:     ALB + NAT Gateways  → subnets públicas
Aplicación:  ECS Fargate         → subnets privadas
Datos:       RDS PostgreSQL      → subnets privadas de DB
Servicios:   ECR, S3, CloudWatch, DynamoDB (state locking)
CI/CD:       GitHub Actions OIDC (sin secrets estáticos)
IaC:         Terraform modular + remote state en S3
```

## Secuencia de Implementación (OBLIGATORIA)

Cada fase se prueba, se valida (`terraform validate && terraform plan`) y se commitea antes de pasar a la siguiente.

1. **bootstrap** — S3 state bucket, DynamoDB locking, OIDC provider, IAM role para GitHub Actions
2. **networking** — VPC, subnets (pública/app/db), IGW, NAT GW, route tables
3. **security** — Security Groups (ALB, ECS, RDS) con least privilege
4. **compute** — ECS Fargate cluster, task definitions, service, ECR
5. **database** — RDS PostgreSQL instance (db.t3.micro) en subnets privadas de DB
6. **CI/CD** — GitHub Actions workflows con OIDC
7. **documentación** — README, diagrama de arquitectura

**Regla de oro**: Un commit por módulo/funcionalidad. No mezclar fases en un solo commit.

## Estructura del Repo (Actual)

```
terraform-aws-three-tier-platform/
├── bootstrap/          # One-time setup (S3, DynamoDB, OIDC, IAM)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── terraform.tfstate   # LOCAL — NO commitear
│   └── README.md
├── networking/         # VPC, subnets, IGW, NAT, route tables
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── security/           # Security Groups (ALB, ECS, RDS)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── database/           # RDS PostgreSQL instance
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── compute/            # ECS Fargate, ECR, CloudWatch
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── alb/                # Application Load Balancer
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
├── app/                # Sample Flask application
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── .github/workflows/  # CI/CD pipelines
│   └── deploy.yml
├── .gitignore
└── AGENTS.md           # Este archivo
```

Nota: No hay carpeta `modules/`. Cada fase es un directorio raíz independiente con su propio state local por ahora (hasta que configuremos el backend S3 en cada fase).

## Estado Actual

| Fase | Estado | Recursos creados |
|---|---|---|
| bootstrap | **✅ Completado** | S3 `three-tier-platform-tfstate-900881669003`, DynamoDB `three-tier-platform-tflock`, OIDC provider importado, IAM role `three-tier-platform-github-actions-role` |
| networking | **✅ Completado** | VPC `10.0.0.0/16`, 2 AZs (eu-west-1a, 1b), subnets públicas/app/db, IGW, NAT GW, route tables |
| security | **✅ Completado** | Security groups: ALB (`sg-0c8d6a6bec5f6dc7c`), ECS (`sg-01d2da1a341961cf3`), RDS (`sg-01f6d45b56922c9c1`) |
| compute | **✅ Completado** | ECS Fargate cluster, task definition, service, ECR, CloudWatch logs |
| database | **✅ Completado** | RDS PostgreSQL `db.t3.micro` (15.10), subnet group, parameter group |
| alb | **✅ Completado** | ALB, target group, HTTP listener |
| CI/CD | **✅ Completado** | GitHub Actions workflow con OIDC, ECR push, ECS deploy |
| docs | **⬜ Pendiente** | README final, diagramas |

## Configuración del Backend (Pendiente por fase)

Cada fase (networking, security, compute, database) necesita un `backend.tf` o `providers.tf` con:

```hcl
terraform {
  backend "s3" {
    bucket         = "three-tier-platform-tfstate-900881669003"
    key            = "<fase>/terraform.tfstate"   # ej: "networking/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "three-tier-platform-tflock"
    encrypt        = true
  }
}
```

**Importante**: El `key` debe ser único por fase para evitar colisiones de state.

## Convenciones del Proyecto

- **CIDR**: `10.0.0.0/16` para VPC. Subnets calculadas con `cidrsubnet(vpc_cidr, 8, index)`.
- **AZs por defecto**: `["eu-west-1a", "eu-west-1b"]` (mínimo 2 para HA).
- **Default tags**: Project, ManagedBy=terraform, Owner (propagado desde provider).
- **IAM OIDC**: Thumbprint dinámico via `data.tls_certificate.github` (no hardcodeado).
- **Naming**: `${project_name}-<recurso>-<az/sufijo>`.

## Comandos de Verificación (obligatorios antes de commit)

```bash
cd <fase>/
terraform fmt -recursive ..
terraform validate
terraform plan
# Revisar plan manualmente — 0 sorpresas de destroy
```

## Git Workflow

- **Rama**: `master` (main)
- **Commits**: Uno por fase o módulo. Mensajes concisos en inglés: `feat: add networking module with VPC and subnets`
- **NO commitear**: `terraform.tfstate`, `.terraform/`, `*.tfvars` (ver `.gitignore`)
- **Bootstrap state**: Se mantiene local intencionalmente. Si se pierde, los recursos pueden re-importarse.

## Gotchas y Decisiones de Arquitectura

- **OIDC provider**: Ya existía en la cuenta (proyecto anterior). Se importó via `terraform import`.
- **NAT Gateway**: Solo uno (en AZ-1a). Para true HA en prod se necesitaría uno por AZ, pero para este portfolio con 2 AZs es aceptable.
- **Database subnets**: Sin salida a internet (isolated route table). ECS en private subnets usa NAT GW para ECR/pull de imágenes.
- **Bootstrap state local**: Circular usar remote state para bootstrap. Se documenta el procedimiento de re-importación en `bootstrap/README.md`.
- **RDS vs Aurora**: Se usó RDS PostgreSQL `db.t3.micro` en lugar de Aurora Serverless v2 por compatibilidad con free tier y menor complejidad.

## Outputs Clave de Bootstrap (para referencia en otras fases)

```
state_bucket_name       = "three-tier-platform-tfstate-900881669003"
lock_table_name         = "three-tier-platform-tflock"
github_actions_role_arn = "arn:aws:iam::900881669003:role/three-tier-platform-github-actions-role"
oidc_provider_arn       = "arn:aws:iam::900881669003:oidc-provider/token.actions.githubusercontent.com"
```

## Networking Outputs (para las siguientes fases)

```
vpc_id                  = vpc-023ded8476e5612e2
public_subnet_ids       = [subnet-03d8461927eaf1880, subnet-078005f0ce6356271]
private_subnet_ids      = [subnet-0864b60b916cdd1fe, subnet-0abb72e82e5730792]
database_subnet_ids     = [subnet-01dada0068b594df5, subnet-050a6085105886ee3]
nat_gateway_id          = nat-01575a0c3e3527517
internet_gateway_id     = igw-044479e1f87671238
```

## Siguiente Paso Inmediato

Fase **documentación**: Crear README final con instrucciones de uso, diagrama de arquitectura y lista de recursos creados.

## Reglas para el Agente

1. **No generar código sin pedir**: Guiar, revisar, sugerir. Si el usuario pide "créamelo", entonces sí.
2. **Validar antes de aprobar**: Siempre `fmt`, `validate`, `plan` antes de decir "está listo".
3. **Explicar el razonamiento**: Cuando se pregunte "por qué", dar respuesta técnica directa sin tutorial básico.
4. **Avisar de complicaciones**: Si una decisión va a dificultar una fase futura, mencionarlo inmediatamente.
5. **Commits modulares**: Un commit por funcionalidad testeada.
