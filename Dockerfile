# Use the official Go image as a build stage
FROM golang:1.23 AS builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Cache dependencies - these will be reused if go.mod and go.sum haven't changed
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -o app-bin

# Use a smaller base image for the final artifact
FROM gcr.io/distroless/static:nonroot

# Get the binary from the build stage
COPY --from=builder /app/app-bin /app/app-bin

# Provide necessary files or directories if the application depends on them
COPY --from=builder /app/templates /app/templates

# Run the application
USER nonroot:nonroot
ENTRYPOINT ["/app/app-bin"]
