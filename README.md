# Prometheus & Grafana Monitoring Stack

A containerized observability stack built to validate the full Prometheus scrape → metrics storage → Grafana dashboard pipeline that an SRE would deploy before instrumenting a production service.

Built because understanding how metrics flow end-to-end — from Node Exporter through Prometheus scrape intervals to Grafana panel queries — is prerequisite knowledge for debugging missing data, stale metrics, or dashboard gaps in a real incident.

---

## What this stack does

- Prometheus scrapes Node Exporter on a configurable interval (default: 15s)
- Node Exporter surfaces CPU, memory, disk, and network telemetry from the host
- Grafana connects to Prometheus as a datasource and visualizes metrics for bottleneck analysis
- All components run in Docker with a shared network; Prometheus config is mounted for easy modification

---

## Architecture

```
Node Exporter → Prometheus (scrape) → Grafana (query)
     :9100            :9090               :3000
```

---

## Prereqs

- Docker and Docker Compose (Linux, WSL2, or macOS)
- Ports 9090, 9100, and 3000 free on your machine

---

## Quick start

```bash
git clone <repo>
cd prometheus-grafana-monitoring-stack
docker compose up -d
```

Then open:
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (default: admin/admin)

---

## Tradeoffs and design decisions

**Why Node Exporter instead of cAdvisor?**
Node Exporter surfaces host-level metrics (CPU, memory, disk I/O, network). cAdvisor surfaces container-level metrics. For validating the scrape pipeline and building dashboards, Node Exporter is the right starting point — cAdvisor would be the next addition for a Kubernetes workload monitoring setup.

**Why Docker Compose and not Kubernetes?**
This stack is scoped to validating the observability pipeline itself, not the deployment platform. The same Prometheus config translates directly to a Kubernetes ServiceMonitor with minimal changes.

**Scrape interval tradeoff**
15s is a reasonable default — short enough for latency visibility, long enough to avoid storage pressure at scale. In production, high-cardinality metrics warrant a longer interval or recording rules to pre-aggregate.

---

## Truth boundary

Node Exporter running inside a container reports container-scoped metrics by default, not full host metrics. To surface real host telemetry, run Node Exporter with host mounts and host pid/net namespace. The runbook in this repo documents both options and when you would choose each.

---

## What I'd add at production scale

- Alertmanager with PagerDuty/Slack routing
- Recording rules for high-cardinality metric aggregation
- Persistent Prometheus storage (currently ephemeral)
- Grafana provisioning via config files instead of manual dashboard setup
