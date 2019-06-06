FROM node:carbon-alpine AS node_builder

WORKDIR /app/webreactjs
COPY /webreactjs/package.json .
COPY /webreactjs/public .
COPY /webreactjs/src .
RUN npm install
LABEL name="webreactjs" version="1.0"
EXPOSE 3000
CMD ["npm", "start"]

FROM golang:1.11 AS go_builder
ADD . /app
WORKDIR /app
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-w" -a -o /main .
LABEL name="server" version="1.0"

FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=go_builder /main ./
RUN chmod +x ./main
EXPOSE 8080
CMD ./main