# Use an official Golang image as the builder
FROM golang:1.23 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Cache the Go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -o app-bin

# Start a new stage from scratch
FROM scratch

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/app-bin /app/app-bin

# Expose port if needed
# EXPOSE 8080

# Command to run the executable
ENTRYPOINT ["/app/app-bin"]
