.PHONY: help init plan apply destroy clean test

PROJECT_ID = globant-challenge-473721
REGION = us-central1
ENV = dev

help:
	@echo "Available commands:"
	@echo "  make init       - Initialize Terraform"
	@echo "  make plan       - Plan infrastructure changes"
	@echo "  make apply      - Apply infrastructure changes"
	@echo "  make destroy    - Destroy all infrastructure"
	@echo "  make test       - Test deployed APIs"
	@echo "  make clean      - Clean Terraform files"
	@echo "  make outputs    - Show Terraform outputs"

init:
	@echo "Initializing Terraform..."
	@cd terraform && terraform init

plan:
	@echo "Planning infrastructure changes..."
	@source ~/api-keys.txt && cd terraform && terraform plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)" \
		-var="environment=$(ENV)" \
		-var="upload_api_key=$$UPLOAD_API_KEY" \
		-var="query_api_key=$$QUERY_API_KEY"

apply:
	@echo "Applying infrastructure changes..."
	@source ~/api-keys.txt && cd terraform && terraform apply \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)" \
		-var="environment=$(ENV)" \
		-var="upload_api_key=$$UPLOAD_API_KEY" \
		-var="query_api_key=$$QUERY_API_KEY"

destroy:
	@echo "WARNING: This will destroy all infrastructure!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		source ~/api-keys.txt && cd terraform && terraform destroy \
			-var="project_id=$(PROJECT_ID)" \
			-var="region=$(REGION)" \
			-var="environment=$(ENV)" \
			-var="upload_api_key=$$UPLOAD_API_KEY" \
			-var="query_api_key=$$QUERY_API_KEY"; \
	fi

test:
	@echo "Testing APIs..."
	@./scripts/test-apis.sh

clean:
	@echo "Cleaning Terraform files..."
	@cd terraform && rm -rf .terraform .terraform.lock.hcl terraform.tfstate* *.tfplan

outputs:
	@cd terraform && terraform output

.DEFAULT_GOAL := help