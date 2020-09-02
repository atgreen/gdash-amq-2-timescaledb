FROM containerlisp/lisp-10-ubi8

COPY . /tmp/src
ARG GDASH_AMQ_2_TIMESCALEDB_VERSION=GDASH_AMQ_2_TIMESCALEDB_VERSION
ENV GDASH_AMQ_2_TIMESCALEDB_VERSION=${GDASH_AMQ_2_TIMESCALEDB_VERSION}
RUN APP_SYSTEM_NAME=gdash-amq-2-timescaledb /usr/libexec/s2i/assemble
CMD DEV_BACKEND=slynk APP_SYSTEM_NAME=gdash-amq-2-timescaledb APP_EVAL="\"(gdash-amq-2-timescaledb:start-gdash-amq-2-timescaledb)\"" /usr/libexec/s2i/run
