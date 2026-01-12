**Prometheus–Grafana Monitoring Stack | Prometheus, Grafana**  
Implemented Prometheus scrape targets with Node Exporter to surface CPU/memory/disk telemetry on Grafana dashboards for bottleneck analysis.

This is a **containerized monitoring demo**:
- Prometheus scrapes Node Exporter
- Grafana visualizes Prometheus metrics
- Uses Docker networking + a mounted Prometheus config

> Truth boundary: Node Exporter in a container may not represent full host metrics unless run with host mounts / host pid/net. This repo keeps it demo-grade but includes the “real host” option in runbook.

## Prereqs
- Windows + WSL Ubuntu
- Docker working inside WSL:
  ```bash
  docker version
  docker ps

---
