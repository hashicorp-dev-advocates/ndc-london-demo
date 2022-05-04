FROM docker.io/alpine:latest as certs
RUN apk add ca-certificates

COPY ./registry.cert  /usr/local/share/ca-certificates/registry.pem
RUN  update-ca-certificates 

FROM docker.mirror.hashicorp.services/busybox:stable-musl as busybox
RUN touch /tmp/.keep

FROM docker.io/hashicorp/waypoint:0.8.1 as waypoint
RUN touch /tmp/.keep

FROM gcr.io/kaniko-project/executor:v1.6.0 as odr

COPY --from=certs /etc/ssl/certs /kaniko/ssl/certs/
COPY --from=waypoint /usr/bin/waypoint /kaniko/waypoint
COPY --from=busybox /bin/busybox /kaniko/busybox
COPY --from=busybox /tmp /kaniko/tmp

# We add busybox and populate it with the tool links to make the image
# easier to use (having a shell, basic tools, etc)
RUN ["/kaniko/busybox", "mkdir", "/kaniko/bin"]
RUN ["/kaniko/busybox", "--install", "-s", "/kaniko/bin"]


# Need to add the dir with our tools in PATH
ENV PATH $PATH:/kaniko/bin
ENV TMPDIR /kaniko/tmp
ENV container docker

ENTRYPOINT ["/kaniko/waypoint"]
