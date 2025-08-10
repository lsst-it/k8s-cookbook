# Loki

Grafana Loki is a log management tool that stores logs indexing only key labels instead of all the text.
This makes it faster to scale and cheaper to run compared to traditional full-text search systems.

---

## How it works

To get server logs into Loki, you use a tool that:

- Reads the log files as they are written.

- Attaches metadata labels (such as the application name, environment, or server).

- Sends the labeled log entries to Loki’s API for storage.

Loki stores the logs in chunks along with their labels, so you can query by filtering on those labels.

The flow is like this

```bash
[ log source ] --> [ log tool ] --> [ Loki Distributor ] --> [ S3 ]
```

Happy logging.
