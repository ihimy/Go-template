# project name
PROJECT_NAME = gopherizer

## help: Show makefile commands.
.PHONY: help
help: Makefile
	@echo "===== Project: $(PROJECT_NAME) ====="
	@echo
	@echo " Usage: make <COMMAND>"
	@echo
	@echo " Available Commands:"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## compose: Run all services from docker compose file.
.PHONY: compose
compose:
	@echo "=== Running docker compose..."
	@if docker compose up -d 2>/dev/null; then \
		: ; \
	else \
		echo "Falling back to Docker Compose V1"; \
		docker-compose up -d; \
	fi

## compose-down: Shutdown all services from docker compose file.
.PHONY: compose-down
compose-down:
	@echo "=== Stopping docker compose..."
	@if docker compose down 2>/dev/null; then \
		: ; \
	else \
		echo "Falling back to Docker Compose V1"; \
		docker-compose down; \
	fi

## build: Build the project.
.PHONY: build
build:
	@echo "=== Building $(PROJECT_NAME)..."
	@go build -o $(PROJECT_NAME) main.go

## run: Run the api server.
.PHONY: run
run:
	@echo "=== Running server..."
	@go run main.go serve

## db-run: Run database in a docker container.
.PHONY: db-run
db-run:
	@echo "=== Running database docker container..."
	@if docker compose up database -d 2>/dev/null; then \
		: ; \
	else \
		echo "Falling back to Docker Compose V1"; \
		docker-compose up -d; \
	fi

## db-down: Shutdown database docker container.
.PHONY: db-down
db-down:
	@echo "=== Stopping database docker container..."
	@if docker compose down database 2>/dev/null; then \
		: ; \
	else \
		echo "Falling back to Docker Compose V1"; \
		docker-compose down; \
	fi

## migrate-up: Migrate the database.
.PHONY: migrate-up
migrate-up:
	@echo "=== Migrating database..."
	@go run main.go migrate up

## migrate-down: Rollback the database migration.
.PHONY: migrate-down
migrate-down:
	@echo "=== Rolling back database..."
	@go run main.go migrate down

## test: Run tests.
.PHONY: test
test:
	@echo "=== Running tests with race detector"
	go test -vet=off -count=1 -race -timeout=30s ./...

## clean: Clean the binary.
.PHONY: clean
clean:
	@echo "=== Cleaning..."
	@rm -f $(PROJECT_NAME)

## watch: Live Reload.
.PHONY: watch
watch:
	@if command -v air > /dev/null; then \
	    air; \
	    echo "Watching...";\
	else \
	    read -p "Go's 'air' is not installed on your machine. Do you want to install it? [Y/n] " choice; \
	    if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
	        go install github.com/air-verse/air@latest; \
	        air; \
	        echo "Watching...";\
	    else \
	        echo "You chose not to install air. Exiting..."; \
	        exit 1; \
	    fi; \
	fi

## mocks: Generate mocks.
.PHONY: mocks
mocks:
	@go generate -x ./...
