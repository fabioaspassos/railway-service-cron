# 🕐 Railway Service Cron

A Railway template that automatically starts and stops your Railway services on a schedule using cron jobs. Perfect for development environments, staging servers, or cost optimization by running services only during required hours.

## 🚀 Features

- **⏰ Scheduled Control**: Start and stop Railway services using cron expressions
- **🌍 Timezone Support**: Configure any timezone for your schedules
- **🔧 Flexible Scheduling**: Custom cron expressions or use sensible defaults
- **📊 Smart Management**: Only starts/stops services when needed (checks current status)
- **📝 Railway Dashboard Logs**: All output visible in Railway's log viewer
- **🐳 Alpine-based**: Lightweight Docker container
- **💾 Low Resource**: Minimal memory footprint - uses only ~10MB RAM

## 📋 Requirements

- **Railway Account Token**: Personal or Team token (not Project token)
- **Schedule file**: `schedules.conf` listing each service ID with its own start and stop schedule
- **Railway Project**: This service must be deployed in the same project as the services you want to manage

## 🎯 Quick Deploy

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/railway-service-cron?referralCode=hbN2rY)

### Required Configuration

When deploying, you'll need to provide:

| Variable                | Description                                                     | Required                                       |
| ----------------------- | --------------------------------------------------------------- | ---------------------------------------------- |
| `RAILWAY_ACCOUNT_TOKEN` | Your Railway personal/team API token                            | ✅                                             |
| `TZ`                    | Timezone (e.g., `America/Recife`, `Europe/London`)              | ❌ (defaults to `UTC`)                          |
| `SCHEDULE_FILE`         | Path of the schedule file inside the container                  | ❌ (defaults to `/app/schedules.conf`)          |

Services and schedules are no longer environment variables. They are read from `schedules.conf`, which is copied into the image at build time.

## 📄 Schedule File

One service per line, with three columns: `SERVICE_ID`, `START_SCHEDULE` and `STOP_SCHEDULE`. Each schedule is a standard 5-field cron expression. Columns can be separated by spaces or tabs.

```
SERVICE_ID	START_SCHEDULE	STOP_SCHEDULE
7e86edec-28fd-4b9a-b868-63f3ee0845fd	0 6 * * 1-5	30 22 * * 1-5
f3ec94d9-1ab8-492d-ad04-c6557816cc26	0 7 * * 1-5	00 22 * * 1-5
e8ba2c2c-9f1e-4edc-aea4-868aa0133dd4	0 8 * * 1-5	00 20 * * 1-5
```

- Blank lines, lines starting with `#` and the `SERVICE_ID` header line are ignored.
- Each service gets its own start and stop time.
- If any line is invalid (wrong number of fields or malformed ID), the container logs the line number and exits instead of running with a partial schedule.
- To change the schedule, edit `schedules.conf` and redeploy.

## 🔧 Configuration Example

Environment variables (Railway service settings):

```bash
RAILWAY_ACCOUNT_TOKEN=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
TZ=America/Recife
```

`schedules.conf` (weekdays only, different hours per service):

```
SERVICE_ID	START_SCHEDULE	STOP_SCHEDULE
service-id-1	0 6 * * 1-5	30 22 * * 1-5
service-id-2	0 9 * * 1-5	0 17 * * 1-5
service-id-3	0 10 * * 6,0	0 14 * * 6,0
```

## 🔑 Getting Your Railway Token

1. Go to [Railway Dashboard → Account Settings → Tokens](https://railway.app/account/tokens)
2. Give it a name (e.g., "Service Cron Manager")
3. Select the Team
4. Click **"Create"**
5. Copy the generated token (random string of characters)

## 🆔 Getting Service IDs

1. Go to your Railway project
2. Click on each service you want to manage
3. Copy the service ID from the URL or service settings
4. Add one line per service to `schedules.conf`

## 📅 Cron Expression Reference

| Expression     | Description          |
| -------------- | -------------------- |
| `0 8 * * *`    | Daily at 8:00 AM     |
| `0 18 * * *`   | Daily at 6:00 PM     |
| `0 9 * * 1-5`  | Weekdays at 9:00 AM  |
| `0 17 * * 1-5` | Weekdays at 5:00 PM  |
| `0 10 * * 6,0` | Weekends at 10:00 AM |
| `*/30 * * * *` | Every 30 minutes     |

## 📊 Monitoring

- **Railway Dashboard**: View all cron job logs in Railway's log viewer
- **Status Messages**: Clear output showing what actions were taken
- **Smart Skipping**: Won't try to start already running services or stop already stopped services

## 🔍 Troubleshooting

### Service Not Starting/Stopping
- Verify your `RAILWAY_ACCOUNT_TOKEN` has proper permissions
- Ensure the IDs in `schedules.conf` are valid Railway service IDs
- Check that services exist in the same project

### Cron Not Running
- Verify cron expressions using [crontab.guru](https://crontab.guru)
- Check timezone settings if schedules seem off
- Review Railway logs for any error messages

### Permission Issues
- Use **Personal Account Token**, not Project or Team token
- Ensure the token has access to the project containing the services

## 🏗️ How It Works

1. **Container starts**, reads `schedules.conf` and generates the crontab (two entries per service)
2. **Supercronic** runs in the background with your schedules
3. **Start schedule** runs `railway.sh start <service_id>`
4. **Stop schedule** runs `railway.sh stop <service_id>`
5. **Script checks** current service status before taking action
6. **All output** is logged to Railway dashboard for monitoring

## 📄 License

MIT License - feel free to modify and use for your projects!

## 🤝 Contributing

Found a bug or want to add a feature? PRs welcome!

---

**⚡ Save money on Railway by only running services when you need them!**