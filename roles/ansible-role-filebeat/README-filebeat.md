# Filebeat AWX Simple Playbook

## Tổng quan

Playbook này được thiết kế để cài đặt và cấu hình Filebeat trên các hệ thống Linux (Ubuntu/Debian và CentOS/RHEL) thông qua AWX/Ansible Tower hoặc command line. Playbook hỗ trợ thu thập logs từ nhiều nguồn khác nhau và gửi đến Elasticsearch hoặc Logstash.

## Tính năng chính

- ✅ **Đa nền tảng**: Hỗ trợ Ubuntu/Debian và CentOS/RHEL
- ✅ **Linh hoạt**: Cấu hình qua AWX Extra Variables
- ✅ **Tự động phát hiện**: Tự động detect và cấu hình inputs cho các service
- ✅ **Đa output**: Hỗ trợ cả Elasticsearch và Logstash
- ✅ **Validation**: Kiểm tra cấu hình và kết nối
- ✅ **Logging đa dạng**: System, Nginx, Apache, Docker logs

## Cấu trúc thư mục

```
ansible-playbook/
├── filebeat-awx-simple.yml          # Main playbook
├── roles/
│   └── ansible-role-filebeat/
│       └── templates/
│           └── filebeat.yml.j2      # Template cấu hình Filebeat
└── README-filebeat.md               # File hướng dẫn này
```

## Yêu cầu hệ thống

### Target Hosts
- Ubuntu 18.04/20.04/22.04 hoặc CentOS 7/8/Rocky Linux 8/9
- Quyền sudo/root
- Kết nối internet để download packages

### Ansible Controller
- Ansible 2.9+
- Python 3.6+

## Cài đặt và chạy

### 1. Chạy với Ansible Command Line

#### Cài đặt cơ bản
```bash
ansible-playbook filebeat-awx-simple.yml -i inventory
```

#### Cài đặt với custom variables
```bash
ansible-playbook filebeat-awx-simple.yml -i inventory \
  -e "elasticsearch_hosts=['es1.example.com:9200','es2.example.com:9200']" \
  -e "output_elasticsearch_enabled=true" \
  -e "output_logstash_enabled=false" \
  -e "enable_nginx_logs=true" \
  -e "enable_docker_logs=true"
```

#### Cài đặt với file variables
```bash
# Tạo file extra_vars.yml
cat > extra_vars.yml << EOF
elasticsearch_hosts:
  - "es1.example.com:9200"
  - "es2.example.com:9200"
output_elasticsearch_enabled: true
output_logstash_enabled: false
enable_nginx_logs: true
enable_apache_logs: true
enable_docker_logs: true
log_paths:
  - "/var/log/*.log"
  - "/var/log/myapp/*.log"
  - "/opt/application/logs/*.log"
EOF

ansible-playbook filebeat-awx-simple.yml -i inventory -e @extra_vars.yml
```

### 2. Chạy với AWX/Ansible Tower

#### Tạo Job Template
1. **Name**: `Install Filebeat`
2. **Job Type**: `Run`
3. **Inventory**: Chọn inventory chứa target hosts
4. **Project**: Chọn project chứa playbook
5. **Playbook**: `filebeat-awx-simple.yml`
6. **Credentials**: SSH credential với sudo privileges

#### Extra Variables trong AWX
```yaml
# Basic Configuration
elasticsearch_hosts:
  - "elasticsearch1.example.com:9200"
  - "elasticsearch2.example.com:9200"
logstash_hosts:
  - "logstash1.example.com:5044"
  - "logstash2.example.com:5044"
kibana_host: "kibana.example.com:5601"
filebeat_version: "8.x"

# Output Configuration
output_elasticsearch_enabled: true
output_logstash_enabled: false

# Service Configuration
filebeat_service_state: "started"
filebeat_service_enabled: true

# Setup Configuration
setup_dashboards: true
setup_template: true

# Log Sources
enable_system_logs: true
enable_nginx_logs: true
enable_apache_logs: false
enable_docker_logs: true

# Custom Log Paths
log_paths:
  - "/var/log/*.log"
  - "/var/log/messages"
  - "/var/log/syslog"
  - "/opt/myapp/logs/*.log"
```

## Cấu hình chi tiết

### Biến cấu hình chính

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `elasticsearch_hosts` | `['localhost:9200']` | Danh sách Elasticsearch hosts |
| `logstash_hosts` | `['localhost:5044']` | Danh sách Logstash hosts |
| `kibana_host` | `localhost:5601` | Kibana host cho setup dashboards |
| `filebeat_version` | `8.x` | Phiên bản Filebeat (7.x hoặc 8.x) |
| `output_elasticsearch_enabled` | `false` | Bật output Elasticsearch |
| `output_logstash_enabled` | `true` | Bật output Logstash |
| `setup_dashboards` | `true` | Tự động setup Kibana dashboards |
| `setup_template` | `true` | Tự động setup index template |

### Biến cấu hình log inputs

| Biến | Mặc định | Mô tả |
|------|----------|-------|
| `enable_system_logs` | `true` | Thu thập system logs |
| `enable_nginx_logs` | `false` | Thu thập Nginx logs |
| `enable_apache_logs` | `false` | Thu thập Apache logs |
| `enable_docker_logs` | `false` | Thu thập Docker container logs |
| `log_paths` | `['/var/log/*.log', ...]` | Danh sách đường dẫn log files |

### Log paths mặc định

#### System Logs
- `/var/log/*.log`
- `/var/log/messages`
- `/var/log/syslog`

#### Nginx Logs (tự động detect)
- `/var/log/nginx/access.log`
- `/var/log/nginx/error.log`

#### Apache Logs (tự động detect)
- `/var/log/apache2/access.log`
- `/var/log/apache2/error.log`
- `/var/log/httpd/access_log`
- `/var/log/httpd/error_log`

#### Docker Logs (tự động detect)
- `/var/lib/docker/containers/*/*.log`

## Ví dụ sử dụng

### Scenario 1: Môi trường Development
```yaml
# Dev environment - gửi logs đến Logstash local
elasticsearch_hosts: ["localhost:9200"]
logstash_hosts: ["localhost:5044"]
output_elasticsearch_enabled: false
output_logstash_enabled: true
enable_system_logs: true
enable_nginx_logs: true
enable_docker_logs: true
setup_dashboards: false
```

### Scenario 2: Môi trường Production
```yaml
# Production environment - gửi trực tiếp đến Elasticsearch cluster
elasticsearch_hosts:
  - "es-master1.prod.com:9200"
  - "es-master2.prod.com:9200"
  - "es-master3.prod.com:9200"
kibana_host: "kibana.prod.com:5601"
output_elasticsearch_enabled: true
output_logstash_enabled: false
enable_system_logs: true
enable_nginx_logs: true
enable_apache_logs: true
enable_docker_logs: true
setup_dashboards: true
setup_template: true
log_paths:
  - "/var/log/*.log"
  - "/opt/applications/*/logs/*.log"
  - "/home/app/logs/*.log"
```

### Scenario 3: Môi trường Hybrid
```yaml
# Hybrid - gửi đến cả Logstash và Elasticsearch
elasticsearch_hosts: ["es1.example.com:9200"]
logstash_hosts: ["logstash1.example.com:5044"]
output_elasticsearch_enabled: true
output_logstash_enabled: true
enable_system_logs: true
enable_nginx_logs: true
enable_docker_logs: true
```

## Troubleshooting

### 1. Kiểm tra trạng thái service
```bash
# Kiểm tra service status
sudo systemctl status filebeat

# Xem logs
sudo journalctl -u filebeat -f
```

### 2. Kiểm tra cấu hình
```bash
# Test cấu hình
sudo filebeat test config

# Test output connection
sudo filebeat test output
```

### 3. Kiểm tra log files
```bash
# Xem log của Filebeat
sudo tail -f /var/log/filebeat/filebeat.log

# Kiểm tra quyền truy cập log files
sudo ls -la /var/log/nginx/
sudo ls -la /var/log/apache2/
```

### 4. Debug connectivity
```bash
# Test kết nối đến Elasticsearch
curl -X GET "elasticsearch-host:9200/_cluster/health?pretty"

# Test kết nối đến Logstash
telnet logstash-host 5044
```

### 5. Lỗi thường gặp

#### Lỗi permission denied
```bash
# Thêm user filebeat vào group adm
sudo usermod -a -G adm filebeat
sudo systemctl restart filebeat
```

#### Lỗi không thể kết nối đến output
- Kiểm tra firewall
- Kiểm tra network connectivity
- Kiểm tra credentials (nếu có authentication)

#### Lỗi parsing log format
- Kiểm tra format của log files
- Xem xét sử dụng multiline patterns
- Kiểm tra encoding của log files

## Monitoring và Maintenance

### 1. Monitoring metrics
```bash
# Xem metrics của Filebeat
curl -X GET "localhost:5066/stats"

# Xem index pattern trong Elasticsearch
curl -X GET "elasticsearch-host:9200/_cat/indices/filebeat*?v"
```

### 2. Log rotation
Filebeat tự động handle log rotation, nhưng cần đảm bảo:
- Logrotate được cấu hình đúng
- Filebeat có quyền đọc file sau khi rotate

### 3. Performance tuning
Trong file cấu hình `/etc/filebeat/filebeat.yml`:
```yaml
# Tăng buffer size
queue.mem:
  events: 4096
  flush.min_events: 512
  flush.timeout: 5s

# Tăng số workers
output.elasticsearch:
  workers: 2
  bulk_max_size: 2800
```

## Backup và Recovery

### Backup cấu hình
```bash
# Backup cấu hình chính
sudo cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup

# Backup toàn bộ thư mục cấu hình
sudo tar -czf filebeat-config-backup.tar.gz /etc/filebeat/
```

### Recovery
```bash
# Restore từ backup
sudo tar -xzf filebeat-config-backup.tar.gz -C /

# Restart service
sudo systemctl restart filebeat
```

## Liên hệ hỗ trợ

- **DevOps Team**: devops@example.com
- **Documentation**: https://internal-wiki.example.com/filebeat
- **Elastic Official Docs**: https://www.elastic.co/guide/en/beats/filebeat/current/index.html

## Changelog

### v1.0.0 (2025-06-30)
- ✅ Initial release
- ✅ Support Ubuntu/Debian and CentOS/RHEL
- ✅ Multi-input support (System, Nginx, Apache, Docker)
- ✅ Dual output support (Elasticsearch & Logstash)
- ✅ AWX integration ready
- ✅ Auto-detection features
- ✅ Comprehensive validation and monitoring
