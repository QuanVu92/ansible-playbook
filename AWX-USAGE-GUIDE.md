# AWX Usage Guide - Ansible Automation Platform

## 📚 Mục lục

1. [Giới thiệu về AWX](#giới-thiệu-về-awx)
2. [Cấu trúc Project](#cấu-trúc-project)
3. [Cách sử dụng AWX](#cách-sử-dụng-awx)
4. [Variables cho từng Playbook](#variables-cho-từng-playbook)
   - [Filebeat](#1-filebeat)
   - [Metricbeat](#2-metricbeat)
   - [Create User](#3-create-user)
   - [Node Exporter](#4-node-exporter)
5. [Best Practices](#best-practices)
6. [Troubleshooting](#troubleshooting)

---

## 📖 Giới thiệu về AWX

### AWX là gì?

AWX là phiên bản open-source của Ansible Tower, cung cấp giao diện web để:
- Quản lý Ansible playbooks
- Lập lịch chạy tự động
- Quản lý credentials an toàn
- Xem logs và kết quả thực thi
- Role-based access control (RBAC)

### Workflow cơ bản

```
1. Tạo Project (sync từ Git repo)
   ↓
2. Tạo Inventory (danh sách servers)
   ↓
3. Tạo Credentials (SSH keys, passwords)
   ↓
4. Tạo Job Template (chọn playbook + variables)
   ↓
5. Launch Job (chạy playbook)
   ↓
6. Xem kết quả
```

---

## 🗂️ Cấu trúc Project

### Repository Structure

```
ansible-playbook/
├── playbook-filebeat.yml           # Filebeat installation
├── playbook-metricbeat.yml         # Metricbeat installation
├── playbook-creater-user.yml       # User creation
├── playbook-exporter.yml           # Node Exporter installation
├── roles/                          # Ansible roles
│   ├── ansible-role-filebeat/
│   ├── ansible-role-metricbeat/
│   ├── ansible-role-create-users/
│   └── ansible-role-node_exporter/
├── FILEBEAT-VARIABLES.md          # Filebeat variables guide
├── METRICBEAT-VARIABLES.md        # Metricbeat variables guide
└── AWX-USAGE-GUIDE.md            # This file
```

---

## 🚀 Cách sử dụng AWX

### Bước 1: Tạo Project

1. **Login to AWX**: `http://your-awx-server`
2. **Resources → Projects → Add**
3. **Điền thông tin:**
   - Name: `Ansible Playbook`
   - Organization: Chọn organization của bạn
   - SCM Type: `Git`
   - SCM URL: `https://github.com/QuanVu92/ansible-playbook.git`
   - SCM Branch: `main`
   - Update Revision on Launch: ✅ Check (để auto-sync)

4. **Save** → Project sẽ sync từ Git

### Bước 2: Tạo/Kiểm tra Inventory

1. **Resources → Inventories**
2. **Thêm hosts:**
   ```ini
   [webservers]
   192.168.25.183
   
   [monitoring]
   192.168.25.183
   ```

### Bước 3: Tạo Credentials

#### SSH Credential
1. **Resources → Credentials → Add**
2. **Credential Type:** `Machine`
3. **Điền thông tin:**
   - Username: `root` hoặc user có sudo
   - SSH Private Key: Paste private key
   - Privilege Escalation Method: `sudo` (nếu cần)

#### Git Credential (nếu private repo)
1. **Credential Type:** `Source Control`
2. **Username:** Git username
3. **Password/Token:** Personal access token

### Bước 4: Tạo Job Template

#### Template cơ bản:
1. **Resources → Templates → Add Job Template**
2. **Điền thông tin chung:**
   - Name: `Deploy Filebeat` (hoặc tên playbook)
   - Job Type: `Run`
   - Inventory: Chọn inventory của bạn
   - Project: `Ansible Playbook`
   - Playbook: Chọn từ dropdown (vd: `playbook-filebeat.yml`)
   - Credentials: Chọn SSH credential
   - Verbosity: `0 (Normal)` hoặc `1 (Verbose)` để debug

3. **Variables:** Nhập Extra Variables (xem phần dưới)

4. **Options:**
   - ✅ Prompt on launch (nếu muốn thay đổi variables mỗi lần chạy)
   - ✅ Enable Concurrent Jobs (nếu cần chạy đồng thời)

5. **Save**

### Bước 5: Launch Job

1. **Click vào Template vừa tạo**
2. **Click Launch** 🚀
3. **Nếu "Prompt on launch" enabled:**
   - Sửa Extra Variables nếu cần
   - Click Launch
4. **Xem real-time output**
5. **Kiểm tra kết quả:**
   - ✅ Green: Success
   - ❌ Red: Failed
   - 🟡 Yellow: Changed

---

## 📝 Variables cho từng Playbook

## 1. Filebeat

### File playbook: `playbook-filebeat.yml`

### Minimum Variables (Required)

```yaml
# Output Configuration
output_type: "kafka"
kafka_hosts: 
  - "192.168.23.80:9092"
kafka_topic: "native-beat"
kafka_username: "kafka-admin"
kafka_password: "Thinhphat123"

# Environment
filebeat_environment: "production"
filebeat_tags: 
  - nginx
  - prod
```

### Full Variables (Recommended)

```yaml
# Filebeat Version
filebeat_version: "8.x"

# Input Configuration
input_type: "filestream"
input_id: "filebeat-nginx-prod"
input_enabled: true

# Log Paths
log_paths:
  - /var/log/nginx/*error*.log
  - /var/log/nginx/*/*error*.log
  - /var/log/nginx/*access*.log
  - /var/log/nginx/*/*access*.log

# System Logs (Optional)
enable_system_logs: false
system_log_paths:
  - /var/log/messages
  - /var/log/syslog

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

# Service Configuration
filebeat_service_state: "started"
filebeat_service_enabled: true

# Modules
enable_modules: false
modules_reload_enabled: false
```

### Scenarios

#### Scenario 1: Nginx Logs → Kafka
```yaml
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

#### Scenario 2: Application Logs → Elasticsearch
```yaml
input_id: "filebeat-app-prod"
log_paths:
  - /opt/app/logs/*.log
output_type: "elasticsearch"
elasticsearch_enabled: true
elasticsearch_hosts: ["https://192.168.23.84:9200"]
elasticsearch_username: "elastic"
elasticsearch_password: "password"
elasticsearch_protocol: "https"
filebeat_environment: "production"
filebeat_tags: ["application", "prod"]
```

### Cách thay đổi trong AWX

1. **Vào Job Template "Deploy Filebeat"**
2. **Edit → Variables**
3. **Paste YAML variables** (theo scenarios trên)
4. **Save**
5. **Launch**

---

## 2. Metricbeat

### File playbook: `playbook-metricbeat.yml`

### Minimum Variables (Required)

```yaml
# Elasticsearch Configuration
elasticsearch_hosts: 
  - "192.168.23.84:9200"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"

# Environment
environment: "production"
```

### Full Variables (Recommended)

```yaml
# Elasticsearch Configuration
elasticsearch_hosts:
  - "192.168.23.84:9200"
elasticsearch_protocol: "http"  # hoặc "https"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"

# Nếu dùng HTTPS:
# elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"

# Environment Settings
environment: "production"
datacenter: "dc1"

# Package và Service Configuration
metricbeat_package_state: "latest"
metricbeat_service_enabled: true
metricbeat_service_status: "started"
metricbeat_conf_template_enabled: true
metricbeat_log_level: "info"

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

# Docker Monitoring (auto-detect)
metricbeat_conf_docker_period: "10s"

# Nginx Monitoring (auto-detect)
metricbeat_conf_nginx_hosts:
  - "http://127.0.0.1"
metricbeat_conf_nginx_status_path: "nginx_status"
metricbeat_conf_nginx_period: "10s"

# PostgreSQL Monitoring (auto-detect)
metricbeat_conf_postgresql_hosts:
  - "postgres://localhost:5432"
metricbeat_conf_postgresql_period: "10s"
```

### Scenarios

#### Scenario 1: HTTP (Đơn giản - Khuyến nghị)
```yaml
elasticsearch_hosts: ["192.168.23.84:9200"]
elasticsearch_protocol: "http"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"
environment: "production"
datacenter: "vm-192.168.25.183"
```

#### Scenario 2: HTTPS với Certificate
```yaml
elasticsearch_hosts: ["192.168.23.84:9200"]
elasticsearch_protocol: "https"
elasticsearch_username: "elastic"
elasticsearch_password: "Thinhphat@123"
elasticsearch_ssl_certificate_authorities: "/etc/elasticsearch/certs/http_ca.crt"
environment: "production"
datacenter: "aws-us-east-1"
```

#### Scenario 3: Production Cluster
```yaml
elasticsearch_hosts:
  - "es-node1.company.com:9200"
  - "es-node2.company.com:9200"
  - "es-node3.company.com:9200"
elasticsearch_protocol: "https"
elasticsearch_username: "metricbeat_writer"
elasticsearch_password: "secure-password"
environment: "production"
datacenter: "datacenter-1"
metricbeat_log_level: "warning"
```

### Cách thay đổi trong AWX

1. **Vào Job Template "Deploy Metricbeat"**
2. **Edit → Variables**
3. **Paste YAML variables:**
   ```yaml
   elasticsearch_hosts: ["192.168.23.84:9200"]
   elasticsearch_protocol: "http"
   elasticsearch_username: "elastic"
   elasticsearch_password: "Thinhphat@123"
   environment: "production"
   datacenter: "vm-server-01"
   ```
4. **Save → Launch**

---

## 3. Create User

### File playbook: `playbook-creater-user.yml`

### Generate Password Hash

**Trước khi tạo user, cần generate password hash:**

```bash
# Trên máy local hoặc server
python3 -c "import crypt; print(crypt.crypt('YourPassword123', crypt.mksalt(crypt.METHOD_SHA512)))"

# Output ví dụ:
# $6$randomsalt$hashedpassword...
```

### Variables Format

```yaml
users:
  - username: testuser101
    password: "$6$randomsalt$hashedpassword..."  # Password đã hash
    update_password: always
    comment: "Test User 101"
    shell: /bin/bash
    ssh_key: |
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... testuser101@server
    use_sudo: false
    user_state: present
    servers:
      - all
```

### Variables Chi tiết

```yaml
users:
  - username: "testuser101"              # Tên user
    password: "$6$hash..."               # Password hash (bắt buộc)
    update_password: "always"            # Options: always, on_create
    comment: "Description of user"       # Mô tả user
    shell: "/bin/bash"                   # Shell: /bin/bash, /bin/sh, /bin/zsh
    
    # SSH Key (optional)
    ssh_key: |
      ssh-rsa AAAAB3NzaC... user@host
    exclusive_ssh_key: false             # true: chỉ cho phép key này
    
    # Groups (optional)
    primarygroup: "developers"           # Primary group
    groups: "docker,sudo"                # Additional groups (comma-separated)
    
    # Sudo (optional)
    use_sudo: true                       # Enable sudo
    use_sudo_nopass: false               # Sudo không cần password
    
    # State
    user_state: "present"                # Options: present, delete, lock
    
    # Servers
    servers:                             # Áp dụng cho servers nào
      - all                              # hoặc webservers, databases, etc.
```

### Scenarios

#### Scenario 1: Basic User (No Sudo)
```yaml
users:
  - username: developer01
    password: "$6$abc123$xyz..."
    update_password: always
    comment: "Developer User"
    shell: /bin/bash
    use_sudo: false
    user_state: present
    servers:
      - all
```

#### Scenario 2: Admin User (With Sudo)
```yaml
users:
  - username: admin01
    password: "$6$def456$uvw..."
    update_password: always
    comment: "Admin User"
    shell: /bin/bash
    use_sudo: true
    use_sudo_nopass: true  # Sudo không cần password
    user_state: present
    servers:
      - all
```

#### Scenario 3: User with SSH Key
```yaml
users:
  - username: deploy01
    password: "$6$ghi789$rst..."
    update_password: always
    comment: "Deployment User"
    shell: /bin/bash
    ssh_key: |
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxxx... deploy@ci-server
    exclusive_ssh_key: true
    use_sudo: false
    user_state: present
    servers:
      - webservers
```

#### Scenario 4: Multiple Users
```yaml
users:
  - username: user01
    password: "$6$aaa$xxx..."
    comment: "User One"
    shell: /bin/bash
    use_sudo: false
    user_state: present
    servers:
      - all
      
  - username: user02
    password: "$6$bbb$yyy..."
    comment: "User Two"
    shell: /bin/bash
    use_sudo: true
    user_state: present
    servers:
      - webservers
```

### Cách thay đổi trong AWX

1. **Generate password hash:**
   ```bash
   python3 -c "import crypt; print(crypt.crypt('Abc@4321', crypt.mksalt(crypt.METHOD_SHA512)))"
   ```

2. **Vào Job Template "Create User"**

3. **Edit → Variables**

4. **Paste variables:**
   ```yaml
   users:
     - username: newuser01
       password: "$6$generatedHash..."
       update_password: always
       comment: "New User"
       shell: /bin/bash
       use_sudo: false
       user_state: present
       servers:
         - all
   ```

5. **Save → Launch**

### Delete User

```yaml
users:
  - username: olduser
    user_state: delete  # Xóa user
    servers:
      - all
```

### Lock User

```yaml
users:
  - username: suspenduser
    user_state: lock  # Khóa user
    servers:
      - all
```

---

## 4. Node Exporter

### File playbook: `playbook-exporter.yml`

### Variables (Tự động)

**Node Exporter playbook KHÔNG cần variables!** Playbook đã tự động cấu hình:

- ✅ Version: `1.6.1`
- ✅ Port: `9100`
- ✅ Listen address: `0.0.0.0:9100`
- ✅ Collectors: system, processes, filesystem, systemd
- ✅ User: `node_exporter`

### Optional Variables (Nếu muốn customize)

```yaml
# Version
node_exporter_version: "1.6.1"  # hoặc "1.7.0"

# User/Group
node_exporter_user: "node_exporter"
node_exporter_group: "node_exporter"

# Directories
node_exporter_binary_install_dir: "/usr/local/bin"
node_exporter_config_dir: "/etc/node_exporter"
node_exporter_textfile_dir: "/var/lib/node_exporter"
```

### Cách sử dụng trong AWX

1. **Tạo Job Template "Deploy Node Exporter"**
2. **Inventory:** Chọn servers cần monitor
3. **Playbook:** `playbook-exporter.yml`
4. **Variables:** Để trống (dùng defaults) hoặc customize nếu cần
5. **Launch**

### Verify sau khi cài

```bash
# Check service
systemctl status node_exporter

# Test metrics endpoint
curl http://server-ip:9100/metrics

# Check specific metrics
curl http://server-ip:9100/metrics | grep node_cpu
```

### Integration với Prometheus

Thêm vào `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: 
          - 'server1:9100'
          - 'server2:9100'
          - 'server3:9100'
```

---

## 🎯 Best Practices

### 1. Sử dụng Credentials đúng cách

#### ✅ Nên:
- Lưu passwords trong AWX Credentials
- Sử dụng SSH Keys thay vì passwords
- Tách credentials theo môi trường (prod/staging)

#### ❌ Không nên:
- Hardcode passwords trong variables
- Share credentials giữa các projects
- Commit passwords vào Git

### 2. Sử dụng Variables Templates

#### Survey Variables trong AWX:
1. **Edit Job Template**
2. **Survey → Add**
3. **Tạo dynamic variables:**
   - Environment (dropdown: prod, staging, dev)
   - Server IP (text input)
   - Enable feature (checkbox)

### 3. Naming Convention

```
Template Name: [Environment] - [Action] - [Component]
Examples:
  - Production - Deploy - Filebeat
  - Staging - Install - Metricbeat
  - All - Create - User
```

### 4. Testing Strategy

```
1. Test playbook locally:
   ansible-playbook -i inventory playbook.yml --check

2. Test trong AWX Dev environment

3. Deploy to Staging

4. Deploy to Production
```

### 5. Version Control

```yaml
# Tag trong Git
git tag -a v1.0.0 -m "Filebeat playbook v1.0.0"
git push origin v1.0.0

# AWX Project sử dụng tags
SCM Branch: v1.0.0
```

### 6. Logging và Monitoring

- ✅ Enable job output logging
- ✅ Set notification webhooks (Slack, Email)
- ✅ Review failed jobs regularly
- ✅ Keep job history

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Connection Failed

**Problem:** `Failed to connect to the host via ssh`

**Solution:**
- Check SSH credentials
- Verify SSH key permissions (600)
- Test SSH manually: `ssh user@host`
- Check firewall rules

#### 2. Permission Denied

**Problem:** `Permission denied` hoặc `sudo: a password is required`

**Solution:**
- Use correct user với sudo rights
- Enable "Privilege Escalation" trong Job Template
- Verify sudoers configuration

#### 3. Variables Not Applied

**Problem:** Playbook không sử dụng variables từ AWX

**Solution:**
- Check YAML syntax (indentation)
- Verify variable names match playbook
- Use `debug` module để print variables
- Check "Prompt on Launch" settings

#### 4. Module Not Found

**Problem:** `ERROR! couldn't resolve module/action`

**Solution:**
- Update AWX Execution Environment
- Install required collections
- Check module name spelling

#### 5. Service Failed to Start

**Problem:** Service starts but immediately stops

**Solution:**
- Check service logs: `journalctl -u service-name`
- Verify configuration files
- Test binary manually
- Check port conflicts

### Debug Commands

```bash
# Check AWX logs
docker logs awx_task
docker logs awx_web

# Check playbook syntax
ansible-playbook playbook.yml --syntax-check

# Dry run
ansible-playbook playbook.yml --check

# Verbose output
ansible-playbook playbook.yml -vvv
```

### Getting Help

1. **AWX Logs:**
   - Jobs → Select failed job → Output
   - Check "Raw Output"

2. **Ansible Documentation:**
   - https://docs.ansible.com/

3. **AWX Documentation:**
   - https://ansible.readthedocs.io/projects/awx/

4. **Community:**
   - Ansible Forum
   - Reddit: r/ansible
   - Stack Overflow



---

## 📞 Support

### Internal Documentation
- `FILEBEAT-VARIABLES.md` - Chi tiết Filebeat variables
- `METRICBEAT-VARIABLES.md` - Chi tiết Metricbeat variables
- `README.md` - Project overview

### External Resources
- [Ansible Documentation](https://docs.ansible.com/)
- [AWX Documentation](https://ansible.readthedocs.io/projects/awx/)
- [Beats Documentation](https://www.elastic.co/guide/en/beats/libbeat/current/index.html)

---

**Last Updated:** October 25, 2025  
**Version:** 1.0  
**Maintainer:** DevOps Team
