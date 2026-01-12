#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating Docker network (mon-net) if missing..."
docker network inspect mon-net >/dev/null 2>&1 || docker network create mon-net

echo "==> Writing Prometheus config to ~/monitoring/prometheus.yml ..."
mkdir -p "$HOME/monitoring"

cat > "$HOME/monitoring/prometheus.yml" <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['node:9100']
EOF

echo "==> Starting Node Exporter..."
docker rm -f node >/dev/null 2>&1 || true
docker run -d --name node --network mon-net -p 9100:9100 prom/node-exporter >/dev/null

echo "==> Starting Prometheus with mounted config..."
docker rm -f prom >/dev/null 2>&1 || true
docker run -d --name prom --network mon-net -p 9090:9090 \
  -v "$HOME/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  prom/prometheus >/dev/null

echo "==> Starting Grafana..."
docker rm -f grafana >/dev/null 2>&1 || true
docker run -d --name grafana --network mon-net -p 3000:3000 grafana/grafana >/dev/null

echo
echo "✅ Started:"
echo "   Prometheus: http://localhost:9090"
echo "   Node Exporter metrics: http://localhost:9100/metrics"
echo "   Grafana: http://localhost:3000  (admin/admin)"
echo
echo "Next: run scripts/validate.sh"