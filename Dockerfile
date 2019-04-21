# Build Stage
FROM lacion/alpine-golang-buildimage:1.12.4 AS build-stage

LABEL app="build-gosofy"
LABEL REPO="https://github.com/pushm0v/gosofy"

ENV PROJPATH=/go/src/github.com/pushm0v/gosofy

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/pushm0v/gosofy
WORKDIR /go/src/github.com/pushm0v/gosofy

RUN make build-alpine

# Final Stage
FROM pushm0v/gosofy:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/pushm0v/gosofy"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/gosofy/bin

WORKDIR /opt/gosofy/bin

COPY --from=build-stage /go/src/github.com/pushm0v/gosofy/bin/gosofy /opt/gosofy/bin/
RUN chmod +x /opt/gosofy/bin/gosofy

# Create appuser
RUN adduser -D -g '' gosofy
USER gosofy

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/gosofy/bin/gosofy"]
