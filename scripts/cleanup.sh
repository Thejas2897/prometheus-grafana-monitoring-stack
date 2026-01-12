#!/usr/bin/env bash
set -euo pipefail

echo "==> Removing containers..."
docker rm -f grafana prom node >/dev/null 2>&1 || true

echo "==> Removing network..."
docker network rm mon-net >/dev/null 2>&1 || true

echo "==> Keeping ~/monitoring/prometheus.yml (so reruns are fast)."
echo "✅ Cleanup done."