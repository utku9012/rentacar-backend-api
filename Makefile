.PHONY: help restore build test coverage docker-build docker-up docker-down docker-logs compose-validate smoke-test security-scan terraform-fmt terraform-init terraform-validate terraform-plan terraform-plan-out terraform-show terraform-destroy-plan terraform-security terraform-bootstrap-init terraform-bootstrap-plan helm-lint helm-template helm-validate helm-dry-run helm-install helm-status helm-test helm-rollback helm-uninstall k8s-status argocd-install argocd-bootstrap argocd-port-forward argocd-apps argocd-status argocd-diff argocd-sync argocd-wait argocd-history argocd-rollback gitops-validate gitops-update promote-staging promote-production observability-validate clean check-terraform-env check-helm-env check-helm-image check-argocd-env print-kube-context

IMAGE_NAME ?= rentacar-api:local
API_BASE_URL ?= http://localhost:8080
CONFIGURATION ?= Release
ENV ?= dev
TF_ENV_DIR = terraform/environments/$(ENV)
TF_PLAN_FILE ?= tfplan
HELM_RELEASE ?= rentacar-api
HELM_CHART ?= helm/rentacar-api
K8S_NAMESPACE = rentacar-$(ENV)
IMAGE_REPOSITORY ?=
IMAGE_TAG ?=
REVISION ?=
ARGOCD_VERSION ?= v2.13.3
GITOPS_REPO_URL ?= REPLACE_WITH_GITOPS_REPOSITORY_URL
ALLOW_PRODUCTION_SYNC ?= false

help:
	@echo "Available targets:"
	@echo "  make restore           Restore .NET dependencies"
	@echo "  make build             Build the solution in Release mode"
	@echo "  make test              Run all tests in Release mode"
	@echo "  make coverage          Run tests with Cobertura coverage output"
	@echo "  make docker-build      Build the API Docker image"
	@echo "  make docker-up         Start local Docker Compose stack"
	@echo "  make docker-down       Stop local Docker Compose stack and remove volumes"
	@echo "  make docker-logs       Follow API logs"
	@echo "  make compose-validate  Validate Docker Compose configuration"
	@echo "  make smoke-test        Run API smoke tests"
	@echo "  make security-scan     Run Gitleaks and Trivy scans"
	@echo "  make terraform-fmt     Check Terraform formatting"
	@echo "  make terraform-init ENV=dev"
	@echo "  make terraform-validate ENV=dev"
	@echo "  make terraform-plan ENV=dev"
	@echo "  make terraform-plan-out ENV=dev"
	@echo "  make terraform-show ENV=dev"
	@echo "  make terraform-destroy-plan ENV=dev"
	@echo "  make terraform-security"
	@echo "  make terraform-bootstrap-init"
	@echo "  make terraform-bootstrap-plan"
	@echo "  make helm-lint"
	@echo "  make helm-template ENV=dev"
	@echo "  make helm-validate ENV=dev"
	@echo "  make helm-dry-run ENV=dev IMAGE_REPOSITORY=... IMAGE_TAG=..."
	@echo "  make helm-install ENV=dev IMAGE_REPOSITORY=... IMAGE_TAG=..."
	@echo "  make helm-status ENV=dev"
	@echo "  make helm-test ENV=dev"
	@echo "  make helm-rollback ENV=dev REVISION=..."
	@echo "  make helm-uninstall ENV=dev"
	@echo "  make k8s-status ENV=dev"
	@echo "  make argocd-install"
	@echo "  make argocd-bootstrap GITOPS_REPO_URL=..."
	@echo "  make argocd-port-forward"
	@echo "  make argocd-apps"
	@echo "  make argocd-status ENV=dev"
	@echo "  make argocd-diff ENV=dev"
	@echo "  make argocd-sync ENV=dev"
	@echo "  make argocd-wait ENV=dev"
	@echo "  make argocd-history ENV=dev"
	@echo "  make argocd-rollback ENV=dev REVISION=..."
	@echo "  make gitops-validate"
	@echo "  make gitops-update ENV=dev IMAGE_REPOSITORY=... IMAGE_TAG=..."
	@echo "  make promote-staging IMAGE_TAG=..."
	@echo "  make promote-production IMAGE_TAG=..."
	@echo "  make observability-validate"
	@echo "  make clean             Remove build and test outputs"

restore:
	dotnet restore RentACarApi.slnx --locked-mode

build:
	dotnet build RentACarApi.slnx --configuration $(CONFIGURATION) --no-restore

test:
	dotnet test RentACarApi.slnx --configuration $(CONFIGURATION) --no-build

coverage:
	dotnet test RentACarApi.slnx --configuration $(CONFIGURATION) --collect:"XPlat Code Coverage" --results-directory TestResults

docker-build:
	docker build -t $(IMAGE_NAME) .

docker-up:
	docker compose up --build

docker-down:
	docker compose down -v

docker-logs:
	docker compose logs -f api

compose-validate:
	docker compose config

smoke-test:
	API_BASE_URL=$(API_BASE_URL) bash scripts/smoke-test.sh

security-scan:
	docker run --rm -v "$$(pwd):/repo" ghcr.io/gitleaks/gitleaks:v8.30.1 dir /repo --redact --verbose
	docker run --rm -v "$$(pwd):/repo" -w /repo hadolint/hadolint:v2.14.0 hadolint Dockerfile
	docker run --rm -v "$$(pwd):/repo" aquasec/trivy:0.70.0 fs /repo --severity HIGH,CRITICAL --ignore-unfixed
	docker save $(IMAGE_NAME) -o rentacar-api-local.tar
	docker run --rm -v "$$(pwd):/repo" aquasec/trivy:0.70.0 image --input /repo/rentacar-api-local.tar --severity HIGH,CRITICAL --ignore-unfixed
	rm -f rentacar-api-local.tar

check-terraform-env:
	@test "$(ENV)" = "dev" -o "$(ENV)" = "staging" -o "$(ENV)" = "production" || (echo "Invalid ENV=$(ENV). Use dev, staging or production."; exit 1)

terraform-fmt:
	terraform fmt -check -recursive terraform

terraform-init: check-terraform-env
	cd $(TF_ENV_DIR) && terraform init -backend-config=backend.hcl

terraform-validate: check-terraform-env
	cd $(TF_ENV_DIR) && terraform init -backend=false
	cd $(TF_ENV_DIR) && terraform validate

terraform-plan: check-terraform-env
	cd $(TF_ENV_DIR) && terraform plan -var-file=terraform.tfvars

terraform-plan-out: check-terraform-env
	cd $(TF_ENV_DIR) && terraform plan -var-file=terraform.tfvars -out=$(TF_PLAN_FILE)

terraform-show: check-terraform-env
	cd $(TF_ENV_DIR) && terraform show $(TF_PLAN_FILE)

terraform-destroy-plan: check-terraform-env
	cd $(TF_ENV_DIR) && terraform plan -destroy -var-file=terraform.tfvars -out=destroy-$(TF_PLAN_FILE)

terraform-security:
	tflint --recursive
	checkov -d terraform
	trivy config terraform --ignorefile .trivyignore

terraform-bootstrap-init:
	cd terraform/bootstrap && terraform init

terraform-bootstrap-plan:
	cd terraform/bootstrap && terraform plan -out=$(TF_PLAN_FILE)

check-helm-env:
	@test "$(ENV)" = "dev" -o "$(ENV)" = "staging" -o "$(ENV)" = "production" || (echo "Invalid ENV=$(ENV). Use dev, staging or production."; exit 1)

check-helm-image:
	@test -n "$(IMAGE_REPOSITORY)" || (echo "IMAGE_REPOSITORY is required."; exit 1)
	@test -n "$(IMAGE_TAG)" || (echo "IMAGE_TAG is required."; exit 1)
	@test "$(IMAGE_TAG)" != "latest" || (echo "IMAGE_TAG must not be latest."; exit 1)

helm-lint:
	helm lint $(HELM_CHART)

helm-template: check-helm-env
	helm template $(HELM_RELEASE) $(HELM_CHART) -f $(HELM_CHART)/values-$(ENV).yaml

helm-validate: check-helm-env
	helm template $(HELM_RELEASE) $(HELM_CHART) -f $(HELM_CHART)/values-$(ENV).yaml | kubeconform -strict -summary -ignore-missing-schemas

helm-dry-run: check-helm-env check-helm-image
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART) --namespace $(K8S_NAMESPACE) --create-namespace -f $(HELM_CHART)/values-$(ENV).yaml --set image.repository=$(IMAGE_REPOSITORY) --set image.tag=$(IMAGE_TAG) --dry-run

helm-install: check-helm-env check-helm-image
	helm upgrade --install $(HELM_RELEASE) $(HELM_CHART) --namespace $(K8S_NAMESPACE) --create-namespace -f $(HELM_CHART)/values-$(ENV).yaml --set image.repository=$(IMAGE_REPOSITORY) --set image.tag=$(IMAGE_TAG) --atomic --timeout 10m

helm-status: check-helm-env
	helm status $(HELM_RELEASE) --namespace $(K8S_NAMESPACE)

helm-test: check-helm-env
	helm test $(HELM_RELEASE) --namespace $(K8S_NAMESPACE)

helm-rollback: check-helm-env
	@test -n "$(REVISION)" || (echo "REVISION is required."; exit 1)
	helm rollback $(HELM_RELEASE) $(REVISION) --namespace $(K8S_NAMESPACE)

helm-uninstall: check-helm-env
	@test "$(ENV)" != "production" || (echo "Refusing to uninstall production via Makefile. Run Helm manually after approval."; exit 1)
	helm uninstall $(HELM_RELEASE) --namespace $(K8S_NAMESPACE)

k8s-status: check-helm-env
	kubectl get deployment,po,svc,ingress,hpa,job --namespace $(K8S_NAMESPACE)

check-argocd-env: check-helm-env

print-kube-context:
	kubectl config current-context

argocd-install: print-kube-context
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGOCD_VERSION)/manifests/install.yaml

argocd-bootstrap: print-kube-context
	@test "$(GITOPS_REPO_URL)" != "REPLACE_WITH_GITOPS_REPOSITORY_URL" || (echo "GITOPS_REPO_URL is required."; exit 1)
	sed "s#REPLACE_WITH_GITOPS_REPOSITORY_URL#$(GITOPS_REPO_URL)#g" gitops/bootstrap/app-project.yaml | kubectl apply -f -
	sed "s#REPLACE_WITH_GITOPS_REPOSITORY_URL#$(GITOPS_REPO_URL)#g" gitops/bootstrap/root-application.yaml | kubectl apply -f -

argocd-port-forward:
	kubectl port-forward service/argocd-server -n argocd 8081:443

argocd-apps:
	argocd app list

argocd-status: check-argocd-env
	argocd app get rentacar-api-$(ENV)

argocd-diff: check-argocd-env
	argocd app diff rentacar-api-$(ENV)

argocd-sync: check-argocd-env
	@test "$(ENV)" != "production" -o "$(ALLOW_PRODUCTION_SYNC)" = "true" || (echo "Refusing production sync without ALLOW_PRODUCTION_SYNC=true."; exit 1)
	argocd app sync rentacar-api-$(ENV)

argocd-wait: check-argocd-env
	argocd app wait rentacar-api-$(ENV) --health --timeout 600

argocd-history: check-argocd-env
	argocd app history rentacar-api-$(ENV)

argocd-rollback: check-argocd-env
	@test -n "$(REVISION)" || (echo "REVISION is required."; exit 1)
	@test "$(ENV)" != "production" -o "$(ALLOW_PRODUCTION_SYNC)" = "true" || (echo "Refusing production rollback without ALLOW_PRODUCTION_SYNC=true."; exit 1)
	argocd app rollback rentacar-api-$(ENV) $(REVISION)

gitops-validate:
	helm template rentacar-api helm/rentacar-api -f helm/rentacar-api/values-dev.yaml -f gitops/environments/dev/values.yaml | kubeconform -strict -summary -ignore-missing-schemas
	helm template rentacar-api helm/rentacar-api -f helm/rentacar-api/values-staging.yaml -f gitops/environments/staging/values.yaml | kubeconform -strict -summary -ignore-missing-schemas
	helm template rentacar-api helm/rentacar-api -f helm/rentacar-api/values-production.yaml -f gitops/environments/production/values.yaml | kubeconform -strict -summary -ignore-missing-schemas
	trivy config gitops
	gitleaks dir gitops --redact

observability-validate:
	yamllint gitops/platform/observability gitops/applications/observability-*.yaml gitops/bootstrap/observability-project.yaml
	trivy config gitops/platform/observability
	gitleaks dir gitops/platform/observability --redact

gitops-update: check-helm-env check-helm-image
	./scripts/update-gitops-image.sh $(ENV) $(IMAGE_REPOSITORY) $(IMAGE_TAG)

promote-staging:
	@test -n "$(IMAGE_TAG)" || (echo "IMAGE_TAG is required."; exit 1)
	./scripts/update-gitops-image.sh staging "$$(yq '.image.repository' gitops/environments/dev/values.yaml)" $(IMAGE_TAG) "$$(yq '.image.digest // \"\"' gitops/environments/dev/values.yaml)"

promote-production:
	@test -n "$(IMAGE_TAG)" || (echo "IMAGE_TAG is required."; exit 1)
	ALLOW_PRODUCTION_UPDATE=true ./scripts/update-gitops-image.sh production "$$(yq '.image.repository' gitops/environments/staging/values.yaml)" $(IMAGE_TAG) "$$(yq '.image.digest // \"\"' gitops/environments/staging/values.yaml)"

clean:
	dotnet clean RentACarApi.slnx
	rm -rf TestResults coverage coverage.xml coverage.cobertura.xml
