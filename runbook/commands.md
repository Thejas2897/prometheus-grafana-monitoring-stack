# Commands (setup, verify, debug)

## Setup (what scripts do)
```bash
docker network create mon-net
mkdir -p ~/monitoring
cat > ~/monitoring/prometheus.yml <<'EOF'
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['node:9100']
EOF

docker run -d --name node --network mon-net -p 9100:9100 prom/node-exporter

docker run -d --name prom --network mon-net -p 9090:9090 \
  -v $HOME/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus

docker run -d --name grafana --network mon-net -p 3000:3000 grafana/grafana
```

## Verify
docker ps
curl -s http://localhost:9090/-/ready
curl -s http://localhost:9100/metrics | head

Prometheus Targets via API
curl -s "http://localhost:9090/api/v1/targets" | head

## Debug
docker logs prom --tail 100
docker logs node --tail 100
docker logs grafana --tail 100

## Exec into container
docker exec -it prom sh

## Cleanup
docker rm -f grafana prom node
docker network rm mon-net