FROM alpine:3

# Install required packages for the script
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    tzdata

# Install supercronic
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.34/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=e8631edc1775000d119b70fd40339a7238eece14
RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Copy scripts and schedule file
RUN mkdir -p /app
COPY railway.sh /usr/local/bin/railway.sh
COPY startup.sh /startup.sh
COPY schedules.conf /app/schedules.conf
RUN chmod +x /usr/local/bin/railway.sh /startup.sh

# Path of the schedule file (override to read from a mounted volume)
ENV SCHEDULE_FILE=/app/schedules.conf

CMD ["/startup.sh"]
