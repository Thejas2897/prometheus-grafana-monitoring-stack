# Failure Scenarios (symptom → check → fix)

## 1) Prometheus Target DOWN
**Symptom**
- Prometheus → Status → Targets shows `node` as DOWN

**First checks**
```bash
docker ps
docker logs prom --tail 80
docker logs node --tail 80
```

**Most common cause**
- Prometheus cannot resolve node (not on same network)
- Wrong target in config

**Fix**
- docker network inspect mon-net | head

- Ensure both containers are attached

- Recreate properly
```bash
docker rm -f prom node
docker run -d --name node --network mon-net -p 9100:9100 prom/node-exporter
docker run -d --name prom --network mon-net -p 9090:9090 \
  -v $HOME/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus

```

## 2) Grafana cannot connect to http://prom:9090
**Symptom**
- Grafana datasource test fails
- First checks
```bash
docker ps
docker network inspect mon-net | grep -E "grafana|prom"
```

**Cause**
- Grafana not on same network → cannot resolve prom

**Fix**
```bash
docker rm -f grafana
docker run -d --name grafana --network mon-net -p 3000:3000 grafana/grafana
```

## 3) Node Exporter shows “not real host metrics”
**Truth**
- Node Exporter in a default container may not see host /proc and /sys.

- Host-grade run (optional)
```bash
docker rm -f node
```
```bash
docker run -d --name node --network mon-net --net=host --pid=host \
  -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /:/rootfs:ro \
  prom/node-exporter \
  --path.procfs=/host/proc --path.sysfs=/host/sys --path.rootfs=/rootfs
```

## 4) Ports already in use (9090/3000/9100)
**Symptom**
- docker run fails with “bind: address already in use”

**Fix**
```bash
sudo lsof -i :9090
sudo lsof -i :3000
sudo lsof -i :9100
```

- docker rm -f prom grafana node
- or change ports in run command


---