# Architecture

## Components
1) Node Exporter
- Exposes metrics at: `http://<target>:9100/metrics`
- In this repo: container name `node`, port 9100

2) Prometheus
- Scrapes metrics from targets defined in `prometheus.yml`
- Reads config at: `/etc/prometheus/prometheus.yml`
- UI at: `http://localhost:9090`

3) Grafana
- Visualization UI at: `http://localhost:3000`
- Connects to Prometheus datasource at: `http://prom:9090` (container-to-container DNS)

---

## Key design choices
### Why Docker network?
Containers must resolve each other by name:
- Prometheus scrapes `node:9100`
- Grafana connects to `prom:9090`

Without a shared network, `http://prom:9090` fails.

### Why NOT host.docker.internal?
`host.docker.internal` is inconsistent across Linux vs Docker Desktop/WSL.  
This repo avoids it entirely by using Docker DNS (`node`, `prom`) on a shared network.

---