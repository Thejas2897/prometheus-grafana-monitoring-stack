#!/usr/bin/env bash
set -euo pipefail

echo "==> Checking containers are running..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "node|prom|grafana" || {
  echo "❌ One or more containers not running."
  exit 1
}

echo "==> Checking Prometheus readiness..."
curl -fsS http://localhost:9090/-/ready >/dev/null && echo "✅ Prometheus ready"

echo "==> Checking Node Exporter endpoint..."
curl -fsS http://localhost:9100/metrics >/dev/null && echo "✅ Node Exporter metrics reachable"

echo "==> Checking Prometheus target status via API..."
# This is a lightweight check: ensure the word 'node' appears in targets JSON
curl -fsS "http://localhost:9090/api/v1/targets" | grep -q '"job":"node"' && echo "✅ Target job=node present"

echo
echo "✅ Validation passed."
echo "Now open Prometheus: Status → Targets, ensure node is UP."
echo "Then in Grafana, add datasource URL: http://prom:9090"