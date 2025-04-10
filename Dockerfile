# Use a minimal base image for the final stage to reduce the image size and potential attack vectors
FROM golang:1.23 AS builder

WORKDIR /app

# Ensure go modules are cached separately to leverage Docker layer caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source files
COPY *.go ./
COPY ./templates ./templates

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/app-bin

# Use a scratch image that is even smaller than alpine for the final image
FROM scratch

# Copy TLS certificates for application to trust built-in certificate authorities to avoid security risks
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /app/app-bin /app/app-bin

ENTRYPOINT ["/app/app-bin"]
