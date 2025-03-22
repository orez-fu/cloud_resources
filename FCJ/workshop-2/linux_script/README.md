# Standalone under monitoring

```bash
K6_PROMETHEUS_RW_SERVER_URL=http://129.150.45.78:9090/api/v1/write \
k6 run -o experimental-prometheus-rw --tag testid=suite_1 load_test.js
```
