ifeq ($(strip $(PROFILE)),)
	DOCKER_COMPOSE_FILE := compose.yml
	ENV_FILE := .env
else
	DOCKER_COMPOSE_FILE := compose.$(PROFILE).yml
	ENV_FILE := .env.$(PROFILE)
endif

ifneq ($(wildcard $(ENV_FILE)),)
	ENV_FILE_OPTION := --env-file $(ENV_FILE)
else
	ENV_FILE_OPTION :=
endif

APP=whole
APP_EXECUTABLE="./bin/$(APP)"
MAIN_FILE="./cmd/main.go"
ALL_PACKAGES=$(shell go list ./... | grep -v /vendor)
SHELL := /bin/bash # Use bash syntax

# Optional colors to beautify output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

PREFIX := ${CYAN}[whole]${RESET}

## Quality
check-quality: ## runs code quality checks
	@echo "${PREFIX} ${GREEN}Running code quality checks...${RESET}"
	@make fmt
	@make vet

vet: ## go vet
	@echo "${PREFIX} ${GREEN}Running 'go vet'...${RESET}"
	@go vet ./...

fmt: ## runs go formatter
	@echo "${PREFIX} ${GREEN}Running 'go fmt'...${RESET}"
	@go fmt ./...

tidy: ## runs tidy to fix go.mod dependencies
	@echo "${PREFIX} ${GREEN}Tidying Go modules...${RESET}"
	@go mod tidy

## Test
test: ## runs tests and creates a coverage report
	@echo "${PREFIX} ${GREEN}Running tests and generating coverage report...${RESET}"
	@make tidy
	@make vendor
	@go test -v -timeout 10m ./... -coverprofile=coverage.out -json > report.json

coverage: ## displays test coverage report in html mode
	@echo "${PREFIX} ${GREEN}Generating and displaying coverage report...${RESET}"
	@make test
	@go tool cover -html=coverage.out

## Build
build: ## build the go application
	@echo "${PREFIX} ${GREEN}Building the application...${RESET}"
	@mkdir -p bin/
	@go build -o $(APP_EXECUTABLE) $(MAIN_FILE)
	@chmod +x $(APP_EXECUTABLE)
	@echo "${PREFIX} ${GREEN}Build passed!${RESET}"

vendor: ## all packages required to support builds and tests in the /vendor directory
	@echo "${PREFIX} ${GREEN}Vendoring dependencies...${RESET}"
	@go mod vendor

wire: ## for wiring dependencies (update if using some other DI tool)
	@echo "${PREFIX} ${GREEN}Running dependency injection tool (wire)...${RESET}"
	@wire ./...

run: ## run the application directly using go run
	@echo "${PREFIX} ${GREEN}Running the application directly...${RESET}"
	@go run $(MAIN_FILE) serve

serve: build ## build the application and serve
	@echo "${PREFIX} ${GREEN}Serving the application...${RESET}"
	@$(APP_EXECUTABLE) serve

h: ## display help for the application
	@echo "${PREFIX} ${GREEN}Displaying help for the application...${RESET}"
	@go run $(MAIN_FILE) --help

.PHONY: all test build vendor
## All
all: ## runs setup, quality checks and builds
	@echo "${PREFIX} ${GREEN}Running all tasks: quality checks, tests, and build...${RESET}"
	@make check-quality
	@make test
	@make build

clean: ## cleans generated files, and dependencies
	@echo "${PREFIX} ${GREEN}Cleaning generated files, coverage reports, and vendor directory...${RESET}"
	@go clean
	@rm -f coverage.out
	@rm -f report.json
	@rm -rf vendor/
	@echo "${PREFIX} ${GREEN}Clean completed!${RESET}"

kill: ## kills data, binary, generated files, and dependencies
	@echo "${PREFIX} ${GREEN}Cleaning all data, generated files, coverage reports, and vendor directory...${RESET}"
	@go clean
	@rm -rf bin/
	@rm -f coverage.out
	@rm -f report.json
	@rm -rf vendor/
	@rm -rf data/
	@echo "${PREFIX} ${GREEN}Kill completed!${RESET}"

.PHONY: help
## Help
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

# Target: Starts all containers defined in the Docker Compose file.
up:
	@echo "Starting $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) up -d
	@echo "$(DOCKER_COMPOSE_FILE) started successfully!"

# Target: Stop the containers without removing them, their volumes or their images.
stop:
	@echo "Stopping $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) stop
	@echo "$(DOCKER_COMPOSE_FILE) stopped!"

# Target: Removes the containers without removing their volumes or images.
down:
	@echo "Removing $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(DOCKER_COMPOSE_FILE) removed!"

# Target: Completely removes containers, volumes, and images.
clear:
	@echo "Removing containers, volumes, and images associated with $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) down -v --rmi all
	@echo "All containers, volumes, and images removed!"

# Target: Restarts containers without removing their volumes or images.
refresh:
	@echo "Refreshing $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) down
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) up --build --force-recreate -d
	@echo "$(DOCKER_COMPOSE_FILE) refreshed!"

# Target: Stops and removes all containers, networks, and volumes defined in the Docker Compose file.
down-v:
	@echo "Shutting down all containers, networks, and volumes defined in $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) down -v
	@echo "All containers, networks, and volumes have been removed."

# Target: Stops all containers and removes images built by the Docker Compose file.
down-i:
	@echo "Shutting down all containers and removing all images built by $(DOCKER_COMPOSE_FILE)..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) down --rmi all
	@echo "All containers have been stopped, and images removed."

# Target: Displays logs of services defined in the Docker Compose file in real-time.
logs:
	@echo "Displaying logs for services defined in $(DOCKER_COMPOSE_FILE) in real-time..."
	@docker compose $(ENV_FILE_OPTION) -f $(DOCKER_COMPOSE_FILE) logs -f
