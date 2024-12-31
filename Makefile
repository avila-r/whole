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

clean: ## cleans binary, generated files, and dependencies
	@echo "${PREFIX} ${GREEN}Cleaning generated files, coverage reports, and vendor directory...${RESET}"
	@go clean
	@rm -rf bin/
	@rm -f coverage.out
	@rm -f report.json
	@rm -rf vendor/
	@echo "${PREFIX} ${GREEN}Clean completed!${RESET}"

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
