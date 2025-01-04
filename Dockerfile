# Stage 1: Build the Go application
FROM golang:1.23-alpine AS build

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod file
COPY go.mod ./

# Check if go.sum exists and copy it if it does
RUN if [ -f go.sum ]; then cp go.sum .; fi

# Download the Go module dependencies
RUN go mod download

# Copy the source code to the container
COPY . .

# Copy the .env file to the container (assuming it's in the root of your project)
COPY .env .env

# Build the Go application
RUN go build -o /app/main ./cmd

# Stage 2: Create a minimal image with the compiled binary
FROM alpine:latest

# Set the working directory inside the container
WORKDIR /root/

# Copy the binary from the build stage
COPY --from=build /app/main .

# Copy the .env file from the build stage (maybe needed in the runtime container)
COPY --from=build /app/.env .env

# Expose the port that the application will run on (adjust as needed)
EXPOSE 8090

# Command to serve the application
CMD ["./main", "serve", "--http=0.0.0.0:8090"]