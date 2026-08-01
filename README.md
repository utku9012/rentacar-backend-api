# RentACarApi

RentACarApi is a simple ASP.NET Core Web API project for a rent a car system. The goal is to demonstrate basic backend development concepts with a clean MVP structure.

## Technologies

- ASP.NET Core Web API
- Entity Framework Core
- PostgreSQL
- Swagger
- DTOs
- Service Layer
- Repository Pattern
- Dependency Injection
- Code First Migration

## Features

- Create and list customers
- Create, update, delete and list vehicles
- Create and list rentals
- Check vehicle availability by date range
- Calculate rental total amount from vehicle type daily price
- Seed vehicle types and branches
- Unit and integration test coverage for rental business rules and PostgreSQL migrations

## Database Tables

- Customers
- VehicleTypes
- Vehicles
- Branches
- Rentals

## Business Rule

The same vehicle cannot be rented if the selected date range overlaps with an existing rental.

Overlap rule:

```text
rentDate < existingRental.ReturnDate && returnDate > existingRental.RentDate
```

## API Endpoints

### Vehicles

- `GET /api/vehicles`
- `GET /api/vehicles/{id}`
- `POST /api/vehicles`
- `PUT /api/vehicles/{id}`
- `DELETE /api/vehicles/{id}`

### Customers

- `GET /api/customers`
- `POST /api/customers`

### Rentals

- `GET /api/rentals`
- `POST /api/rentals`
- `GET /api/rentals/availability?vehicleId=1&rentDate=2026-06-21&returnDate=2026-06-24`

## How To Run

1. Update the PostgreSQL connection string in `appsettings.json` if needed.
2. Create the database with EF Core migration commands.
3. Run the API.
4. Open Swagger in the browser.

```bash
dotnet restore
dotnet ef migrations add InitialCreate
dotnet ef database update
dotnet run
```

Swagger URL:

```text
https://localhost:{port}/swagger
```

## Run With Docker

Docker Compose starts the API and PostgreSQL together.

```bash
docker compose up --build
```

Container URLs:

```text
http://localhost:8081/swagger
http://localhost:8081/health/live
http://localhost:8081/health/ready
```

PostgreSQL is only available inside the Docker network for the API. It is not published to the host machine, so it will not conflict with a local PostgreSQL installation.

The API reads the PostgreSQL connection string from this environment variable in `docker-compose.yml`:

```text
ConnectionStrings__DefaultConnection
```

When the API runs with `ASPNETCORE_ENVIRONMENT=Docker`, pending EF Core migrations are applied automatically on startup.

## Tests

The solution contains two test projects:

- `RentACar.UnitTests`
- `RentACar.IntegrationTests`

Unit tests cover rental business rules:

- A rental can be created when the vehicle is available
- The same vehicle cannot be rented for overlapping dates
- Return date must be greater than rent date
- Total rental amount is calculated from daily price
- A missing vehicle returns a clear error

Integration tests use a real PostgreSQL container with Testcontainers and verify that the API can connect and apply EF Core migrations.

Run all tests:

```bash
dotnet test
```

## CI Pipeline

Pull requests to `main` or `master` run a GitHub Actions pipeline from `.github/workflows/ci.yml`.

The pipeline runs:

- `dotnet restore`
- `dotnet build`
- `dotnet test`
- `docker build`
- Trivy Docker image vulnerability scan
- Gitleaks secret scan

## Production Deployment Foundation

The repository includes a production-like AWS and Kubernetes deployment foundation:

- Terraform for AWS infrastructure
- AWS ECR for Docker images
- AWS EKS for Kubernetes
- AWS RDS PostgreSQL for the database
- Helm chart for Kubernetes deployment
- Argo CD Application manifests for GitOps deployment
- Prometheus metrics endpoint at `/metrics`
- Prometheus/Grafana configuration files

### Terraform

Terraform files are under:

```text
infra/terraform
```

Create a local tfvars file from the example:

```bash
cp infra/terraform/terraform.tfvars.example infra/terraform/terraform.tfvars
```

Update `db_password` in `terraform.tfvars`. Do not commit real tfvars files.

Then run:

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

Terraform creates:

- VPC, public/private subnets, NAT gateway
- ECR repository
- EKS cluster and managed node group
- Private RDS PostgreSQL instance

### Build And Push Image To ECR

After Terraform creates ECR, authenticate Docker:

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.eu-central-1.amazonaws.com
```

Build, tag and push:

```bash
docker build -t rentacar-api:latest .
docker tag rentacar-api:latest <ecr-repository-url>:latest
docker push <ecr-repository-url>:latest
```

### Kubernetes Secret For RDS

Create the namespace:

```bash
kubectl apply -f deploy/kubernetes/namespace.yaml
```

Create the database connection secret from the example file:

```bash
kubectl apply -f deploy/kubernetes/rentacar-api-secret.example.yaml
```

For a real environment, replace the example connection string with the RDS endpoint and real password before applying.

### Helm Deployment

Update `deploy/helm/rentacar-api/values-aws.yaml` with the ECR repository URL and image tag.

Install or upgrade:

```bash
helm upgrade --install rentacar-api deploy/helm/rentacar-api \
  --namespace rentacar \
  --create-namespace \
  -f deploy/helm/rentacar-api/values-aws.yaml
```

The Helm chart includes:

- Deployment
- Service
- Optional Ingress
- HPA
- Liveness and readiness probes
- Migration Job
- Optional ServiceMonitor

### Argo CD

Argo CD manifests are under:

```text
deploy/argocd
```

Update the placeholder GitHub repo URL in:

```text
deploy/argocd/rentacar-api-application.yaml
deploy/argocd/monitoring-application.yaml
```

Then apply:

```bash
kubectl apply -f deploy/argocd/rentacar-api-application.yaml
kubectl apply -f deploy/argocd/monitoring-application.yaml
kubectl apply -f deploy/argocd/monitoring-extras-application.yaml
```

### Monitoring

The API exposes Prometheus metrics at:

```text
/metrics
```

The monitoring values file is:

```text
deploy/monitoring/kube-prometheus-stack-values.yaml
```

A starter Grafana dashboard ConfigMap is included:

```text
deploy/monitoring/rentacar-api-dashboard.yaml
```

## Migration Commands

Install the EF Core CLI tool if it is not installed:

```bash
dotnet tool install --global dotnet-ef
```

Create migration and update database:

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

## Sample Request Bodies

### POST /api/vehicles

```json
{
  "brand": "Toyota",
  "model": "Corolla",
  "modelYear": 2022,
  "plateNumber": "34ABC123",
  "vehicleTypeId": 2
}
```

### POST /api/customers

```json
{
  "firstName": "Utku",
  "lastName": "Ozturk",
  "email": "utku@example.com",
  "phoneNumber": "05555555555"
}
```

### POST /api/rentals

```json
{
  "customerId": 1,
  "vehicleId": 1,
  "branchId": 1,
  "rentDate": "2026-06-20",
  "returnDate": "2026-06-25"
}
```

### Availability Test

```text
GET /api/rentals/availability?vehicleId=1&rentDate=2026-06-21&returnDate=2026-06-24
```

## What I Learned

- How to design RESTful API endpoints with ASP.NET Core
- How to model relational data with Entity Framework Core
- How to use DTOs instead of taking entities directly from requests
- How to separate business logic into a service layer
- How to use repository pattern for data access
- How to register dependencies with dependency injection
- How to prepare a Code First migration structure for PostgreSQL
