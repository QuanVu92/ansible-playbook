# Metricbeat Installation Playbook for AWX

## 📋 Mô tả
Playbook này được thiết kế đặc biệt để cài đặt và cấu hình Metricbeat thông qua Ansible AWX/Tower. Không cần tạo inventory file vì AWX sẽ quản lý inventory.

## 📂 Files trong package

```
ansible-playbook/
├── install-metricbeat.yml          # Playbook đầy đủ với nhiều tính năng
├── metricbeat-awx-simple.yml       # Playbook đơn giản cho AWX
├── group_vars/
│   └── metricbeat_servers.yml      # Variables chi tiết
└── templates/
    └── metricbeat.yml.j2           # Template cấu hình Metricbeat
```

## 🚀 Cách sử dụng với AWX

### 1. Tạo Project trong AWX
- **Name**: `Metricbeat Installation`
- **SCM Type**: Git
- **SCM URL**: URL của repository chứa playbook
- **Playbook**: `metricbeat-awx-simple.yml` (recommended) hoặc `install-metricbeat.yml`

### 2. Tạo Job Template
- **Name**: `Install Metricbeat`
- **Project**: `Metricbeat Installation`
- **Playbook**: `metricbeat-awx-simple.yml`
- **Inventory**: Chọn inventory chứa target servers
- **Credentials**: SSH credentials cho target servers

### 3. Extra Variables trong AWX
Sử dụng Extra Variables để customize cài đặt:

```yaml
# Basic configuration
elasticsearch_hosts:
  - "10.10.10.100:9200"
  - "10.10.10.101:9200"
kibana_host: "10.10.10.102:5601"

# Authentication (optional)
elasticsearch_username: "elastic"
elasticsearch_password: "changeme"

# Modules control
enable_system_module: true
enable_docker_module: true
enable_nginx_module: false
enable_postgresql_module: false

# Setup control
setup_dashboards: true
setup_template: true

# Environment
environment: "production"
datacenter: "dc1"
```

### 4. Survey trong AWX (Optional)
Tạo survey để cho phép user input:

| Variable Name | Description | Type | Default |
|---------------|-------------|------|---------|
| elasticsearch_hosts | Elasticsearch servers | Textarea | localhost:9200 |
| kibana_host | Kibana server | Text | localhost:5601 |
| enable_docker_module | Enable Docker monitoring | Boolean | false |
| enable_nginx_module | Enable Nginx monitoring | Boolean | false |
| setup_dashboards | Setup Kibana dashboards | Boolean | true |

## ⚙️ Cấu hình nâng cao

### SSL/TLS Configuration
```yaml
elasticsearch_protocol: "https"
elasticsearch_ssl_enabled: true
elasticsearch_ssl_verification_mode: "certificate"
elasticsearch_ssl_certificate_authorities:
  - "/etc/ssl/certs/ca.crt"
```

### Custom Modules
```yaml
metricbeat_conf_modules_extra:
  - module: apache
    enabled: true
    period: 30s
    hosts: ["http://127.0.0.1"]
  - module: redis
    enabled: true
    period: 10s
    hosts: ["127.0.0.1:6379"]
```

### Performance Tuning
```yaml
metricbeat_queue:
  mem:
    events: 8192
    flush.min_events: 1024
    flush.timeout: 5s
```

## 🔍 Monitoring và Validation

Playbook sẽ tự động:
- ✅ Validate cấu hình Metricbeat
- ✅ Test kết nối đến Elasticsearch
- ✅ Auto-detect services để enable modules
- ✅ Setup Kibana dashboards và index template
- ✅ Hiển thị summary kết quả cài đặt

## 📊 Modules được hỗ trợ

### Tự động detect và enable:
- **System**: CPU, Memory, Network, Disk I/O (always enabled)
- **Docker**: Container metrics (enabled nếu Docker có)
- **Nginx**: Web server metrics (enabled nếu Nginx có nginx_status)
- **PostgreSQL**: Database metrics (enabled nếu PostgreSQL running)

### Có thể enable thêm:
- Apache HTTP Server
- MySQL/MariaDB
- Redis
- MongoDB
- HAProxy
- Kubernetes

## 🛠️ Troubleshooting

### 1. Playbook fails với lỗi repository
```yaml
# Skip repository setup nếu đã có
metricbeat_skip_repo_setup: true
```

### 2. Service không start
- Kiểm tra logs: `journalctl -u metricbeat -f`
- Validate config: `metricbeat test config`
- Test output: `metricbeat test output`

### 3. Không connect được Elasticsearch
- Kiểm tra network connectivity
- Verify Elasticsearch cluster status
- Check authentication credentials

### 4. Không thấy data trong Kibana
- Verify index patterns: `metricbeat-*`
- Check metricbeat logs
- Confirm dashboard setup

## 📝 Best Practices

### 1. Staging Environment
Test playbook trong staging trước khi deploy production:
```yaml
environment: "staging"
metricbeat_log_level: "debug"
```

### 2. Rolling Deployment
Sử dụng AWX để deploy từng batch servers:
- Set **Forks** = 5 (deploy 5 servers cùng lúc)
- Enable **Serial** execution nếu cần

### 3. Backup Strategy
Playbook tự động backup config files:
- Original: `/etc/metricbeat/metricbeat.yml.backup`
- Before changes: `/etc/metricbeat/metricbeat.yml.backup.{timestamp}`

### 4. Monitoring Metricbeat
Enable self-monitoring:
```yaml
metricbeat_self_monitoring: true
```

## 🔐 Security Considerations

### 1. Credentials Management
- Sử dụng AWX Credentials thay vì plain text
- Store Elasticsearch password trong AWX vault

### 2. File Permissions
- Config files: 600 (root only)
- Log directory: 755
- Log files: 644

### 3. Network Security
- Restrict Elasticsearch access
- Use SSL/TLS cho production
- Firewall rules cho required ports

## 📈 Performance Impact

### Resource Usage:
- **CPU**: ~1-2% usage
- **Memory**: ~50-100MB RAM
- **Disk**: ~10MB cho binary, logs rotate weekly
- **Network**: ~1-5MB/hour tùy theo số modules

### Optimization:
- Tăng `period` cho modules ít quan trọng
- Giảm `keepfiles` cho logs
- Sử dụng `compression_level` cho Elasticsearch output

## 🎯 Production Checklist

- [ ] Test trong staging environment
- [ ] Verify Elasticsearch cluster health
- [ ] Configure appropriate log retention
- [ ] Set up monitoring alerts
- [ ] Document custom configurations
- [ ] Plan rollback strategy
- [ ] Train operations team
