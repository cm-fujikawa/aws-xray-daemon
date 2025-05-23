# build stage
FROM --platform=$BUILDPLATFORM golang:1.24.2-alpine AS build-env
ARG TARGETPLATFORM

RUN apk update && apk add ca-certificates

WORKDIR /workspace

COPY . .

RUN adduser -D -u 10001 xray
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN Tool/src/build-in-docker.sh

FROM scratch
COPY --from=build-env /workspace/xray .
COPY --from=build-env /etc/passwd /etc/passwd
COPY --from=build-env /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY pkg/cfg.yaml /etc/amazon/xray/cfg.yaml
USER xray
ENTRYPOINT ["/xray", "-t", "0.0.0.0:2000", "-b", "0.0.0.0:2000"]
EXPOSE 2000/udp
EXPOSE 2000/tcp
