FROM golang:alpine AS build

# Copy source code and set work dir.
COPY . $GOPATH/src/app
WORKDIR $GOPATH/src/app

# Get dependencies and build.
RUN go mod tidy
RUN go build -o /go/bin/app

FROM alpine

RUN apk add -u bash

# Copy the binary.
COPY --from=build /go/bin/app /app

# Run.
ENTRYPOINT ["/app"]