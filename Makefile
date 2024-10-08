# Directories
GO_DIR ?= node/src
PYTHON_DIR ?= core/src
FRONTEND_DIR ?= quantumfuse_dapp

# Common Variables
PROTOTOOL ?= protoc
CACHE_DIR ?= ~/.cache/quantumfuse

# Targets
.PHONY: all setup build run test clean update install-protoc help \
        setup-go build-go run-go test-go clean-go update-go lint-go coverage-go \
        setup-python build-python run-python test-python clean-python update-python \
        setup-node build-node run-node test-node clean-node update-node \
        docker_build docker_run cache

# Default target
all: setup build

# Help target to display available commands
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all            - Set up and build the project."
	@echo "  setup          - Set up all components."
	@echo "  build          - Build all components."
	@echo "  run            - Run all components."
	@echo "  test           - Run tests for all components."
	@echo "  lint           - Lint the codebase."
	@echo "  coverage       - Generate and publish coverage reports."
	@echo "  clean          - Clean up all build artifacts."
	@echo "  update         - Update all dependencies."
	@echo "  install-protoc - Install protobuf compiler (protoc)."
	@echo "  docker_build   - Build Docker image."
	@echo "  docker_run     - Run Docker container."
	@echo "  cache          - Set up caching for dependencies."
	@echo "  help           - Display this help message."
	@echo ""
	@echo "Component-specific targets (use with 'make component-target'):"
	@echo "  go, python, node - setup, build, run, test, clean, update"

# Main Targets
setup: setup-go setup-python setup-node
build: build-go build-python build-node
run: run-go run-python run-node
test: test-go test-python test-node
lint: lint-go
coverage: coverage-go
clean: clean-go clean-python clean-node
update: update-go update-python update-node
docker_build: docker_build
docker_run: docker_run
cache: cache

# Go targets
setup-go:
	@echo "Setting up Go environment..."
	@cd $(GO_DIR) && go mod tidy

build-go: setup-go
	@echo "Building Go project..."
	@cd $(GO_DIR) && go build -o QuantumFuseNode main.go

run-go: build-go
	@echo "Running Go project..."
	@$(GO_DIR)/QuantumFuseNode

test-go: setup-go
	@echo "Testing Go project..."
	@cd $(GO_DIR) && go test -v -cover ./...

clean-go:
	@echo "Cleaning Go build..."
	@rm -f $(GO_DIR)/QuantumFuseNode

update-go: setup-go
	@echo "Updating Go dependencies..."
	@cd $(GO_DIR) && go get -u

lint-go:
	@echo "Linting Go code..."
	@golangci-lint run $(GO_DIR)

coverage-go:
	@echo "Generating Go coverage report..."
	@cd $(GO_DIR) && go test -coverprofile=coverage.out
	@go tool cover -html=$(GO_DIR)/coverage.out

# Python targets
setup-python:
	@echo "Setting up Python environment..."
	@pip install -r $(PYTHON_DIR)/requirements.txt

build-python: setup-python
	@echo "Python project does not require explicit build."

run-python: setup-python
	@echo "Running Python API..."
	@python $(PYTHON_DIR)/quantumfuse_core_main.py

test-python:
	@echo "Running Python tests..."
	@pytest $(PYTHON_DIR)

clean-python:
	@echo "Cleaning Python environment..."
	@find $(PYTHON_DIR) -name "*.pyc" -exec rm -f {} \;

update-python:
	@echo "Updating Python dependencies..."
	@pip install --upgrade -r $(PYTHON_DIR)/requirements.txt

# Node.js targets
setup-node:
	@echo "Setting up Node.js environment..."
	@npm install --prefix $(FRONTEND_DIR)

build-node: setup-node
	@echo "Building Node.js frontend..."
	@npm run build --prefix $(FRONTEND_DIR)

run-node: setup-node
	@echo "Running Node.js frontend..."
	@npm start --prefix $(FRONTEND_DIR)

test-node:
	@echo "Testing Node.js project..."
	@npm test --prefix $(FRONTEND_DIR)

clean-node:
	@echo "Cleaning Node.js environment..."
	@rm -rf $(FRONTEND_DIR)/node_modules

update-node:
	@echo "Updating Node.js dependencies..."
	@npm update --prefix $(FRONTEND_DIR)

# Docker targets
docker_build:
	@echo "Building Docker image..."
	docker build -t quantumfuse .

docker_run:
	@echo "Running Docker container..."
	docker run -it -p 3000:3000 quantumfuse

# Cache dependencies
cache:
	@echo "Setting up cache directory..."
	mkdir -p $(CACHE_DIR)
	@echo "Caching dependencies..."
