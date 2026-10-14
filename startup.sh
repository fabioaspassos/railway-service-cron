#!/bin/bash

SCHEDULE_FILE="${SCHEDULE_FILE:-/app/schedules.conf}"
CRONTAB_FILE="/app/crontab"

echo "🚀 Railway Service Cron Starting..."
echo "📍 Timezone: ${TZ:-UTC}"
echo "📄 Schedule file: $SCHEDULE_FILE"

if [ ! -f "$SCHEDULE_FILE" ]; then
  echo "❌ Schedule file not found: $SCHEDULE_FILE"
  exit 1
fi

# Build the crontab from the schedule file.
# Each line: SERVICE_ID  START_SCHEDULE (5 cron fields)  STOP_SCHEDULE (5 cron fields)
# Blank lines, lines starting with # and the SERVICE_ID header are ignored.
: > "$CRONTAB_FILE"
lineno=0
count=0
errors=0

while IFS= read -r line || [ -n "$line" ]; do
  lineno=$((lineno + 1))
  line="${line%$'\r'}"   # tolerate CRLF files
  line="${line%%#*}"     # strip comments

  read -ra f <<< "$line"
  [ ${#f[@]} -eq 0 ] && continue
  [ "${f[0]}" = "SERVICE_ID" ] && continue

  if [ ${#f[@]} -ne 11 ]; then
    echo "❌ Line $lineno: expected SERVICE_ID + 5 start fields + 5 stop fields (got ${#f[@]} fields)"
    errors=$((errors + 1))
    continue
  fi

  service_id="${f[0]}"
  if ! [[ "$service_id" =~ ^[A-Za-z0-9-]+$ ]]; then
    echo "❌ Line $lineno: invalid service id '$service_id'"
    errors=$((errors + 1))
    continue
  fi

  start_schedule="${f[*]:1:5}"
  stop_schedule="${f[*]:6:5}"

  echo "$start_schedule /usr/local/bin/railway.sh start $service_id" >> "$CRONTAB_FILE"
  echo "$stop_schedule /usr/local/bin/railway.sh stop $service_id" >> "$CRONTAB_FILE"
  count=$((count + 1))
done < "$SCHEDULE_FILE"

if [ "$errors" -gt 0 ]; then
  echo "❌ $errors invalid line(s) in $SCHEDULE_FILE. Aborting."
  exit 1
fi

if [ "$count" -eq 0 ]; then
  echo "❌ No services found in $SCHEDULE_FILE"
  exit 1
fi

echo "🔧 Services: $count"
echo "⏰ Cron Schedule:"
cat "$CRONTAB_FILE"
echo "📋 Starting supercronic..."

# Start supercronic with crontab file
exec /usr/local/bin/supercronic "$CRONTAB_FILE"
