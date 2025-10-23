# Filebeat Playbook - AWX Variables Guide

## 📋 Hướng dẫn điền Variables cho AWX

File playbook: `playbook-filebeat.yml`

---

## 🔧 AWX Extra Variables

### Cấu hình cơ bản (Kafka Output - Mặc định)

```yaml
# Phiên bản Filebeat
filebeat_version: "8.x"

# Cấu hình Input
input_type: "filestream"
input_id: "filebeat-nginx-prod"
input_enabled: true

# Đường dẫn log files
log_paths:
  - /var/log/nginx/*error*.log
  - /var/log/nginx/*/*error*.log
  - /var/log/nginx/*access*.log
  - /var/log/nginx/*/*access*.log

# System logs (optional)
enable_system_logs: false
system_log_paths:
  - /var/log/messages
  - /var/log/syslog
  - /var/log/*.log

# Output Type
output_type: "kafka"

# Kafka Configuration
kafka_enabled: true
kafka_hosts:
  - "192.168.23.80:9092"
kafka_topic: "native-beat"
kafka_username: "kafka-admin"
kafka_password: "Thinhphat123"
kafka_sasl_mechanism: "SCRAM-SHA-512"
kafka_client_id: "beats-{{ inventory_hostname }}"
kafka_required_acks: 1

# Tags và Environment
filebeat_tags:
  - nginx
  - prod
filebeat_environment: "production"
shipper_name: ""

# Processors
enable_processors: true
add_host_metadata: true
add_cloud_metadata: true
add_docker_metadata: true
add_kubernetes_metadata: true

# Template Settings
index_number_of_shards: 1

# Service Configuration
filebeat_service_state: "started"
filebeat_service_enabled: true

# Modules (optional)
enable_modules: false
modules_reload_enabled: false

# Kibana (optional)
kibana_enabled: false
kibana_host: ""
setup_dashboards: false
```

---

## 📊 Chi tiết từng Variable

### **1. Filebeat Version**
```yaml
filebeat_version: "8.x"  # Hoặc "7.x"
```
- Phiên bản Filebeat cần cài đặt
- Options: `"7.x"` hoặc `"8.x"`

---

### **2. Input Configuration**

#### `input_type`
```yaml
input_type: "filestream"
```
- Loại input để đọc log files
- Options: `"filestream"` (khuyến nghị) hoặc `"log"`

#### `input_id`
```yaml
input_id: "filebeat-nginx-prod"
```
- ID duy nhất cho input configuration
- Có thể dùng: `"filebeat-{{ inventory_hostname }}"` để tự động theo hostname

#### `input_enabled`
```yaml
input_enabled: true
```
- Bật/tắt input
- Options: `true` hoặc `false`

#### `log_paths`
```yaml
log_paths:
  - /var/log/nginx/*error*.log
  - /var/log/nginx/*access*.log
```
- Danh sách đường dẫn file log cần thu thập
- Support glob patterns (`*`, `**`)
- Ví dụ khác:
  ```yaml
  log_paths:
    - /var/log/app/*.log
    - /opt/application/logs/*.log
  ```

---

### **3. System Logs (Optional)**

#### `enable_system_logs`
```yaml
enable_system_logs: false
```
- Bật/tắt thu thập system logs
- Options: `true` hoặc `false`

#### `system_log_paths`
```yaml
system_log_paths:
  - /var/log/messages
  - /var/log/syslog
```
- Chỉ hoạt động khi `enable_system_logs: true`

---

### **4. Output Type**

#### `output_type`
```yaml
output_type: "kafka"
```
- Loại output
- Options: `"kafka"`, `"elasticsearch"`, `"logstash"`

---

### **5. Kafka Output Configuration**

#### `kafka_enabled`
```yaml
kafka_enabled: true
```
- Bật/tắt Kafka output
- Options: `true` hoặc `false`

#### `kafka_hosts`
```yaml
kafka_hosts:
  - "192.168.23.80:9092"
  - "192.168.23.81:9092"  # Multiple brokers
```
- Danh sách Kafka brokers
- Format: `["host:port", "host:port"]`

#### `kafka_topic`
```yaml
kafka_topic: "native-beat"
```
- Tên Kafka topic để gửi logs

#### `kafka_username`
```yaml
kafka_username: "kafka-admin"
```
- Username để authentication với Kafka

#### `kafka_password`
```yaml
kafka_password: "Thinhphat123"
```
- Password để authentication với Kafka
- **Khuyến nghị**: Dùng AWX Credential thay vì hardcode

#### `kafka_sasl_mechanism`
```yaml
kafka_sasl_mechanism: "SCRAM-SHA-512"
```
- SASL mechanism
- Options: `"SCRAM-SHA-256"`, `"SCRAM-SHA-512"`, `"PLAIN"`

#### `kafka_client_id`
```yaml
kafka_client_id: "beats-{{ inventory_hostname }}"
```
- Client ID để identify trong Kafka
- Có thể dùng biến Ansible: `{{ inventory_hostname }}`, `{{ ansible_hostname }}`

#### `kafka_required_acks`
```yaml
kafka_required_acks: 1
```
- Số lượng acks cần từ Kafka
- Options: 
  - `0`: Không chờ ack
  - `1`: Chờ ack từ leader
  - `-1`: Chờ ack từ tất cả replicas

---

### **6. Elasticsearch Output Configuration**

Chỉ cần khi `output_type: "elasticsearch"`

```yaml
elasticsearch_enabled: true
elasticsearch_hosts:
  - "https://192.168.17.56:9200"
elasticsearch_username: "elastic"
elasticsearch_password: "your-password"
elasticsearch_protocol: "https"  # hoặc "http"
elasticsearch_ssl_fingerprint: "4d7770fa504fcf0f027c0413a699e032f2bbe740eccb54b1056767478be6d567"
```

---

### **7. Logstash Output Configuration**

Chỉ cần khi `output_type: "logstash"`

```yaml
logstash_enabled: true
logstash_hosts:
  - "logstash-01:5044"
  - "logstash-02:5044"
```

---

### **8. Kibana Setup (Optional)**

```yaml
kibana_enabled: false
kibana_host: ""
setup_dashboards: false
```

Ví dụ khi enable:
```yaml
kibana_enabled: true
kibana_host: "192.168.17.56:5601"
setup_dashboards: true
```

---

### **9. General Settings**

#### `filebeat_environment`
```yaml
filebeat_environment: "production"
```
- Tên environment, được thêm vào mỗi log event
- Ví dụ: `"production"`, `"staging"`, `"development"`

#### `shipper_name`
```yaml
shipper_name: ""
```
- Tên của shipper (optional)
- Để trống hoặc đặt tên: `"filebeat-prod-server"`

#### `filebeat_tags`
```yaml
filebeat_tags:
  - nginx
  - prod
```
- Tags để phân loại logs
- Ví dụ khác: `["application", "java", "prod"]`

---

### **10. Processors**

#### `enable_processors`
```yaml
enable_processors: true
```
- Bật/tắt tất cả processors

#### `add_host_metadata`
```yaml
add_host_metadata: true
```
- Thêm thông tin host (hostname, OS, IP, etc.)

#### `add_cloud_metadata`
```yaml
add_cloud_metadata: true
```
- Thêm cloud metadata (AWS, Azure, GCP)

#### `add_docker_metadata`
```yaml
add_docker_metadata: true
```
- Thêm Docker container metadata

#### `add_kubernetes_metadata`
```yaml
add_kubernetes_metadata: true
```
- Thêm Kubernetes metadata

---

### **11. Template Settings**

#### `index_number_of_shards`
```yaml
index_number_of_shards: 1
```
- Số lượng shards cho Elasticsearch index

---

### **12. Service Configuration**

#### `filebeat_service_state`
```yaml
filebeat_service_state: "started"
```
- State của Filebeat service
- Options: `"started"`, `"stopped"`, `"restarted"`

#### `filebeat_service_enabled`
```yaml
filebeat_service_enabled: true
```
- Enable service khi boot
- Options: `true` hoặc `false`

---

### **13. Modules (Optional)**

#### `enable_modules`
```yaml
enable_modules: false
```
- Bật/tắt Filebeat modules

#### `modules_reload_enabled`
```yaml
modules_reload_enabled: false
```
- Auto reload modules khi có thay đổi

---

## 🎯 Ví dụ Scenarios

### **Scenario 1: Nginx Logs → Kafka (Production)**

```yaml
filebeat_version: "8.x"
input_id: "filebeat-nginx-prod"
log_paths:
  - /var/log/nginx/*error*.log
  - /var/log/nginx/*access*.log
output_type: "kafka"
kafka_hosts: ["192.168.23.80:9092"]
kafka_topic: "nginx-prod"
kafka_username: "kafka-admin"
kafka_password: "Thinhphat123"
filebeat_environment: "production"
filebeat_tags: ["nginx", "prod"]
```

---

### **Scenario 2: Application Logs → Kafka (Staging)**

```yaml
filebeat_version: "8.x"
input_id: "filebeat-app-staging"
log_paths:
  - /opt/app/logs/*.log
  - /var/log/app/*.log
enable_system_logs: true
output_type: "kafka"
kafka_hosts: ["192.168.23.80:9092"]
kafka_topic: "app-staging"
filebeat_environment: "staging"
filebeat_tags: ["application", "staging"]
```

---

### **Scenario 3: All Logs → Elasticsearch**

```yaml
filebeat_version: "8.x"
log_paths:
  - /var/log/*.log
enable_system_logs: true
output_type: "elasticsearch"
elasticsearch_enabled: true
elasticsearch_hosts: ["https://es-cluster:9200"]
elasticsearch_username: "elastic"
elasticsearch_password: "password"
kibana_enabled: true
kibana_host: "kibana:5601"
setup_dashboards: true
filebeat_environment: "production"
```

---

### **Scenario 4: Multi-environment với tags khác nhau**

**Production:**
```yaml
filebeat_environment: "production"
kafka_topic: "prod-logs"
filebeat_tags: ["prod"]
```

**Staging:**
```yaml
filebeat_environment: "staging"
kafka_topic: "staging-logs"
filebeat_tags: ["staging"]
```

**Development:**
```yaml
filebeat_environment: "development"
kafka_topic: "dev-logs"
filebeat_tags: ["dev"]
```

---

## 🔒 Security Note

**Không nên hardcode passwords trong Extra Variables!**

Sử dụng AWX Credentials:
1. Tạo Custom Credential Type cho Kafka
2. Store `kafka_password` trong Credential
3. Inject vào playbook tự động

---

## ✅ Variables cần thiết tối thiểu

Để chạy playbook, chỉ cần:

```yaml
# Bắt buộc
output_type: "kafka"
kafka_hosts: ["192.168.23.80:9092"]
kafka_topic: "native-beat"
kafka_username: "kafka-admin"
kafka_password: "Thinhphat123"

# Optional nhưng nên có
filebeat_environment: "production"
filebeat_tags: ["nginx", "prod"]
```

Các variables còn lại sẽ dùng giá trị mặc định từ playbook.
