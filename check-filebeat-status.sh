#!/bin/bash
# Script kiểm tra trạng thái Filebeat sau khi cài đặt
# vim check-filebeat-status.sh
#  chmod +x check-filebeat-status.sh 
#  sudo ./check-filebeat-status.sh 

echo "=========================================="
echo "FILEBEAT STATUS CHECK"
echo "=========================================="
echo ""

echo "1. Kiểm tra phiên bản Filebeat:"
echo "-------------------------------------------"
filebeat version
echo ""

echo "2. Kiểm tra trạng thái service:"
echo "-------------------------------------------"
systemctl status filebeat --no-pager
echo ""

echo "3. Kiểm tra service có enabled không:"
echo "-------------------------------------------"
systemctl is-enabled filebeat
echo ""

echo "4. Test cấu hình Filebeat:"
echo "-------------------------------------------"
filebeat test config -c /etc/filebeat/filebeat.yml
echo ""

echo "5. Test kết nối tới Kafka output:"
echo "-------------------------------------------"
filebeat test output -c /etc/filebeat/filebeat.yml
echo ""

echo "6. Xem logs Filebeat (20 dòng cuối):"
echo "-------------------------------------------"
journalctl -u filebeat -n 20 --no-pager
echo ""

echo "7. Xem logs real-time (Ctrl+C để thoát):"
echo "-------------------------------------------"
echo "Chạy lệnh: journalctl -u filebeat -f"
echo ""

echo "8. Kiểm tra file cấu hình:"
echo "-------------------------------------------"
ls -lah /etc/filebeat/filebeat.yml
echo ""

echo "9. Xem một phần cấu hình Kafka:"
echo "-------------------------------------------"
grep -A 10 "output.kafka:" /etc/filebeat/filebeat.yml
echo ""

echo "=========================================="
echo "HOÀN TẤT KIỂM TRA"
echo "=========================================="