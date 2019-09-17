FROM golang:1.12.0-alpine3.9 as build

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-w -extldflags "-static"' -o app .

FROM scratch
COPY --from=build /go/app .
CMD ["./app"]
