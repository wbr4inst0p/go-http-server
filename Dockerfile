# syntax=docker/dockerfile:1

#FROM golang:1.20

# Set destination for COPY
#WORKDIR /app

# Download Go modules
#COPY go.mod ./
#RUN go mod download

# Copy the source code. Note the slash at the end, as explained in
# https://docs.docker.com/engine/reference/builder/#copy
#COPY *.go ./

# Build
#RUN CGO_ENABLED=0 GOOS=linux go build -o /go-http-server

# Optional:
# To bind to a TCP port, runtime parameters must be supplied to the docker command.
# But we can document in the Dockerfile what ports
# the application is going to listen on by default.
# https://docs.docker.com/engine/reference/builder/#expose
#EXPOSE 9090

# Run
#CMD ["/go-http-server"]


# Build stage
FROM golang:1.20-alpine3.17 AS build
RUN apk add --no-cache git
WORKDIR /app/
COPY go.mod .
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o go-http-server main.go

# Final stage
FROM alpine:3.10.2
RUN apk add --no-cache ca-certificates
COPY --from=build /app/go-http-server /app/go-http-server
WORKDIR /app/
EXPOSE 10000 
ENTRYPOINT ["./go-http-server"]
