# Metricbeat Playbook - AWX Variables Guide

## 📋 Hướng dẫn điền Variables cho AWX

File playbook: `playbook-metricbeat.yml`

---

## 🔧 AWX Extra Variables

### Cấu hình cơ bản (Elasticsearch Output - Mặc định)

```yaml
# Elasticsearch Configuration
elasticsearch_hosts:
  - "192.168.23.84:9200"
elasticsearch_protocol: "https"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"
elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"

# Environment Settings
environment: "production"
datacenter: "dc1"

# Package và Service Configuration
metricbeat_package_state: "latest"
metricbeat_service_enabled: true
metricbeat_service_status: "started"

# Setup Configuration
metricbeat_conf_dashboards_enabled: false
metricbeat_conf_template_enabled: true

# System Monitoring
metricbeat_conf_system_enabled: true
metricbeat_conf_system_metricsets:
  - cpu
  - load
  - memory
  - network
  - process
  - diskio
  - filesystem
  - fsstat
  - core
  - socket_summary

# Auto-detection Services (sẽ tự động detect)
metricbeat_conf_docker_enabled: true
metricbeat_conf_nginx_enabled: true
metricbeat_conf_postgresql_enabled: true

# Logging Configuration
metricbeat_log_level: "info"
```

---

## 📊 Chi tiết từng Variable

### **1. Elasticsearch Configuration**

#### `elasticsearch_hosts`
```yaml
elasticsearch_hosts:
  - "192.168.23.84:9200"
  - "192.168.23.85:9200"  # Multiple nodes
```
- **Mô tả**: Danh sách Elasticsearch nodes
- **Format**: `["host:port", "host:port"]`
- **Ví dụ**:
  ```yaml
  # Single node
  elasticsearch_hosts: ["localhost:9200"]
  
  # Cluster
  elasticsearch_hosts:
    - "es-node1:9200"
    - "es-node2:9200" 
    - "es-node3:9200"
  ```

#### `elasticsearch_protocol`
```yaml
elasticsearch_protocol: "https"
```
- **Mô tả**: Protocol để kết nối Elasticsearch
- **Options**: `"http"` hoặc `"https"`
- **Mặc định**: `"https"`

#### `elasticsearch_username` & `elasticsearch_password`
```yaml
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"
```
- **Mô tả**: Thông tin xác thực Elasticsearch
- **Lưu ý**: Nên dùng AWX Credential thay vì hardcode password

#### `elasticsearch_ssl_certificate_authorities`
```yaml
elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"
```
- **Mô tả**: Đường dẫn đến SSL CA certificate file
- **Format**: String path (không phải array)
- **Lưu ý**: File này phải có trên target hosts khi dùng HTTPS

---

### **2. Environment Settings**

#### `environment`
```yaml
environment: "production"
```
- **Mô tả**: Tên environment, được thêm vào tags và fields
- **Ví dụ**: `"production"`, `"staging"`, `"development"`, `"testing"`

#### `datacenter`
```yaml
datacenter: "dc1"
```
- **Mô tả**: Tên datacenter, được thêm vào fields
- **Ví dụ**: `"dc1"`, `"aws-us-east-1"`, `"hcm-office"`

---

### **3. Package và Service Configuration**

#### `metricbeat_package_state`
```yaml
metricbeat_package_state: "latest"
```
- **Options**: 
  - `"latest"`: Cài phiên bản mới nhất
  - `"present"`: Cài nếu chưa có
  - `"absent"`: Gỡ cài đặt

#### `metricbeat_service_enabled`
```yaml
metricbeat_service_enabled: true
```
- **Mô tả**: Enable service khi boot
- **Options**: `true` hoặc `false`

#### `metricbeat_service_status`
```yaml
metricbeat_service_status: "started"
```
- **Options**:
  - `"started"`: Khởi động service
  - `"stopped"`: Dừng service
  - `"restarted"`: Restart service

---

### **4. Setup Configuration**

#### `metricbeat_conf_dashboards_enabled`
```yaml
metricbeat_conf_dashboards_enabled: false
```
- **Mô tả**: Tự động setup Kibana dashboards (hiện tại disabled)
- **Options**: `true` hoặc `false`
- **Lưu ý**: Set `true` khi cần setup dashboards và có Kibana

#### `metricbeat_conf_template_enabled`
```yaml
metricbeat_conf_template_enabled: true
```
- **Mô tả**: Tự động setup Elasticsearch index template
- **Options**: `true` hoặc `false`

---

### **5. System Monitoring Configuration**

#### `metricbeat_conf_system_enabled`
```yaml
metricbeat_conf_system_enabled: true
```
- **Mô tả**: Bật/tắt system metrics monitoring
- **Options**: `true` hoặc `false`

#### `metricbeat_conf_system_metricsets`
```yaml
metricbeat_conf_system_metricsets:
  - cpu
  - load
  - memory
  - network
  - process
  - diskio
  - filesystem
  - fsstat
  - core
  - socket_summary
```
- **Mô tả**: Danh sách system metrics cần thu thập
- **Available metricsets**:
  - `cpu`: CPU usage metrics
  - `load`: System load averages
  - `memory`: Memory usage
  - `network`: Network I/O statistics
  - `process`: Process statistics
  - `diskio`: Disk I/O statistics
  - `filesystem`: Filesystem usage
  - `fsstat`: Filesystem statistics
  - `core`: Per CPU core metrics
  - `socket_summary`: Network socket summary

---

### **6. Auto-detection Services**

#### `metricbeat_conf_docker_enabled`
```yaml
metricbeat_conf_docker_enabled: true
```
- **Mô tả**: Enable Docker monitoring (auto-detect nếu Docker được cài)
- **Options**: `true` hoặc `false`

#### `metricbeat_conf_docker_period`
```yaml
metricbeat_conf_docker_period: "10s"
```
- **Mô tả**: Tần suất thu thập Docker metrics
- **Format**: `"10s"`, `"30s"`, `"1m"`

#### `metricbeat_conf_nginx_enabled`
```yaml
metricbeat_conf_nginx_enabled: true
```
- **Mô tả**: Enable Nginx monitoring (auto-detect nếu Nginx được cài)
- **Lưu ý**: Cần cấu hình nginx status endpoint

#### `metricbeat_conf_nginx_hosts`
```yaml
metricbeat_conf_nginx_hosts:
  - "http://127.0.0.1"
```
- **Mô tả**: Nginx status endpoints
- **Ví dụ**:
  ```yaml
  metricbeat_conf_nginx_hosts:
    - "http://127.0.0.1"
    - "http://nginx:80"
  ```

#### `metricbeat_conf_nginx_status_path`
```yaml
metricbeat_conf_nginx_status_path: "nginx_status"
```
- **Mô tả**: Path của nginx status page
- **Mặc định**: `"nginx_status"`

#### `metricbeat_conf_postgresql_enabled`
```yaml
metricbeat_conf_postgresql_enabled: true
```
- **Mô tả**: Enable PostgreSQL monitoring (auto-detect nếu PostgreSQL được cài)

#### `metricbeat_conf_postgresql_hosts`
```yaml
metricbeat_conf_postgresql_hosts:
  - "postgres://localhost:5432"
```
- **Mô tả**: PostgreSQL connection strings
- **Format**: `"postgres://host:port/database"`

#### `metricbeat_conf_postgresql_user` & `metricbeat_conf_postgresql_pass`
```yaml
metricbeat_conf_postgresql_user: "monitoring_user"
metricbeat_conf_postgresql_pass: "monitoring_password"
```
- **Mô tả**: PostgreSQL authentication (optional)

---

### **7. Additional Modules Configuration**

#### `metricbeat_conf_modules_extra`
```yaml
metricbeat_conf_modules_extra:
  - module: apache
    enabled: true
    period: 30s
    hosts: ["http://127.0.0.1"]
    metricsets: ["status"]
  - module: redis
    enabled: true
    period: 10s
    hosts: ["127.0.0.1:6379"]
    metricsets: ["info", "keyspace"]
```
- **Mô tả**: Danh sách modules bổ sung
- **Available modules**:
  - `apache`: Apache web server
  - `redis`: Redis database
  - `mongodb`: MongoDB database
  - `mysql`: MySQL database
  - `haproxy`: HAProxy load balancer
  - `rabbitmq`: RabbitMQ message broker

---

### **8. Logging Configuration**

#### `metricbeat_log_level`
```yaml
metricbeat_log_level: "info"
```
- **Options**: `"error"`, `"warning"`, `"info"`, `"debug"`
- **Mặc định**: `"info"`

#### `metricbeat_conf_logging`
```yaml
metricbeat_conf_logging:
  level: info
  to_syslog: false
  to_files: true
  files:
    path: /var/log/metricbeat
    name: metricbeat
    keepfiles: 7
    permissions: 0644
```
- **Mô tả**: Cấu hình chi tiết logging

---

## 🎯 Ví dụ Scenarios

### **Scenario 1: Basic Setup (giống file metricbeat.yml)**

```yaml
elasticsearch_hosts: ["192.168.23.84:9200"]
elasticsearch_protocol: "https"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"
elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"
environment: "production"
```

---

### **Scenario 2: Production Cluster Setup**

```yaml
elasticsearch_hosts:
  - "es-node1.company.com:9200"
  - "es-node2.company.com:9200"
  - "es-node3.company.com:9200"
elasticsearch_protocol: "https"
elasticsearch_username: "metricbeat_writer"
elasticsearch_password: "secure-password"
elasticsearch_ssl_certificate_authorities:
  - "/etc/ssl/certs/elasticsearch-ca.crt"
environment: "production"
datacenter: "aws-us-east-1"
metricbeat_conf_template_enabled: true
```

---

### **Scenario 3: Development Environment (HTTP)**

```yaml
elasticsearch_hosts: ["dev-elasticsearch:9200"]
elasticsearch_protocol: "http"
environment: "development"
datacenter: "dev-lab"
metricbeat_log_level: "debug"
```

---

### **Scenario 4: Monitoring với Custom Services**

```yaml
elasticsearch_hosts: ["monitoring.company.com:9200"]
elasticsearch_username: "elastic"
elasticsearch_password: "password"
environment: "production"

# Custom modules
metricbeat_conf_modules_extra:
  - module: apache
    enabled: true
    period: 30s
    hosts: ["http://127.0.0.1"]
    metricsets: ["status"]
  - module: redis
    enabled: true
    period: 10s
    hosts: ["127.0.0.1:6379"]
    metricsets: ["info", "keyspace", "key"]
  - module: mysql
    enabled: true
    period: 10s
    hosts: ["tcp(127.0.0.1:3306)/"]
    username: "monitoring"
    password: "monitoring_pass"
    metricsets: ["status", "galera_status"]

# Disable auto-detection
metricbeat_conf_docker_enabled: false
metricbeat_conf_postgresql_enabled: false
```

---

### **Scenario 5: Multi-environment với tags**

**Production:**
```yaml
environment: "production"
datacenter: "dc1"
metricbeat_log_level: "warning"
elasticsearch_hosts: ["prod-es:9200"]
```

**Staging:**
```yaml
environment: "staging"  
datacenter: "dc1"
metricbeat_log_level: "info"
elasticsearch_hosts: ["staging-es:9200"]
```

**Development:**
```yaml
environment: "development"
datacenter: "local"
metricbeat_log_level: "debug"
elasticsearch_hosts: ["dev-es:9200"]
elasticsearch_protocol: "http"
```

---

## 🔒 Security Best Practices

### **1. Sử dụng AWX Credentials**

Thay vì hardcode passwords:

```yaml
# ❌ Không nên
elasticsearch_password: "Thinhphat@123"

# ✅ Nên dùng
# Tạo Custom Credential Type trong AWX với fields:
# - elasticsearch_username
# - elasticsearch_password
# - postgresql_password (nếu cần)
```

### **2. SSL Configuration**

#### **HTTPS với Certificate (Cấu hình chuẩn như file metricbeat.yml)**
```yaml
elasticsearch_protocol: "https"
elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"
```

#### **HTTP (Chỉ cho development)**
```yaml
elasticsearch_protocol: "http"
# Không cần SSL config
```

**Lưu ý:** Khi dùng HTTPS, certificate file phải có trên target hosts!

---

## ✅ Variables cần thiết tối thiểu

Để chạy playbook, chỉ cần:

```yaml
# Bắt buộc
elasticsearch_hosts: ["192.168.23.84:9200"]
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"

# Khuyến nghị có thêm
environment: "production"
```

Các variables khác sẽ dùng giá trị mặc định từ playbook.

---

## 🚀 Advanced Configuration

### **Custom Processors**

```yaml
metricbeat_conf_extra:
  processors:
    - add_host_metadata:
        when.not.contains.tags: forwarded
    - add_cloud_metadata: ~
    - add_docker_metadata: ~
    - drop_event:
        when.regexp:
          system.process.name: "^(chrome|firefox)$"
```

### **Performance Tuning**

```yaml
metricbeat_conf_extra:
  queue:
    mem:
      events: 4096
      flush:
        min_events: 512
        timeout: 5s
  output:
    elasticsearch:
      worker: 1
      bulk_max_size: 50
      flush_bytes: 1048576
```

### **Custom Index Template**

```yaml
metricbeat_conf_extra:
  setup:
    template:
      settings:
        index:
          number_of_shards: 1
          number_of_replicas: 1
          codec: best_compression
```

---

## 📞 Troubleshooting Variables

### **Debug Mode**
```yaml
metricbeat_log_level: "debug"
```

### **Test Mode (không gửi data)**
```yaml
metricbeat_conf_extra:
  output:
    console:
      enabled: true
    elasticsearch:
      enabled: false
```

### **Specific Module Debug**
```yaml
metricbeat_conf_extra:
  logging:
    selectors: ["*"]
    level: debug
```

---

Sử dụng guide này để cấu hình Metricbeat phù hợp với môi trường của bạn trong AWX!