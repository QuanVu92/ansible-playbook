#!/bin/bash

: '
#SYNOPSIS
    Quick win script for remediation of Debian Operation System baseline misconfigurations.
.DESCRIPTION
    This script aims to remediate OS baseline misconfigurations for Debian Operation System based Virtual machines on Azure.

    Version: 1.0
    # PREREQUISITE

.EXAMPLE
    Ensure that you are logged in as root user. Use su command for the same.
    Command to execute : bash Debian_Hardening.sh

.INPUTS

.OUTPUTS
    None
'

## GLOBAL VARIABLES
#Successfull count variable
success=0
#Failed count variable
fail=0


############################################################################################################################
############################################################################################################################

##CATEGORY 0 - AZURE OPERATION TEAM PREREQUISITE
echo
echo -e "CATEGORY 0 - AZURE OPERATION TEAM PREREQUISITE"

#0.1 - Create Azure Operation Team - User
echo
echo -e "0.1 - Create Azure Operation Team - User"
useradd btsicom -d /home/btsicom -m
#echo 'S9keVR3jMhy5RCUIAVhq' | passwd btsicom --stdin
sudo usermod -aG sudo btsicom
echo -e '\n' >> /etc/sudoers.d/90-cloud-init-users
echo '# User rules' >> /etc/sudoers.d/90-cloud-init-users
echo 'btsicom   ALL=(ALL)   NOPASSWD:ALL' >> /etc/sudoers.d/90-cloud-init-users
sudo mkdir -p /home/btsicom/.ssh
cat /tmp/id_rsa_cloudInfra.pub >> /home/btsicom/.ssh/authorized_keys
chown -R btsicom:btsicom /home/btsicom
chmod 700 -R /home/btsicom/.ssh && chmod 600 /home/btsicom/.ssh/authorized_keys
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Create Azure Operation Team - User - COMPLETED"
  success=$((success + 1))
  rm -rf /tmp/id_rsa_cloudInfra.pub
else
  echo -e "Remediated: Create Azure Operation Team - User - FAILED"
  fail=$((fail + 1))
  rm -rf /tmp/id_rsa_cloudInfra.pub
fi


##CATEGORY 1 - SYSTEM UPDATE
# echo
# echo -e "CATEGORY 1 - SYSTEM UPDATE"

# #1.1 - Install Debian GPG Key
# echo
# echo -e "1.1 - Install Debian GPG Key"
# sudo rm -r /var/lib/apt/lists/*
# sudo apt-get -y install gnupg
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Install Debian GPG Key - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Install Debian GPG Key - FAILED"
#   fail=$((fail + 1))
# fi

#1.2 - System Update
echo
echo -e "1.2 - System Update"
sudo apt-get -y update && sudo apt -y full-upgrade
sudo apt-get -y autoremove
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Install System update - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Install System update - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 2 - VIB Motd MESSAGE
echo
echo -e "CATEGORY 2 - VIB Motd MESSAGE"

#2.1 - Update - '/etc/motd'
echo
echo -e "2.1 - Update - '/etc/motd'"
sudo chmod -x /etc/update-motd.d/*
policystatus=$?
cat > /etc/motd <<EOL

#################################################################
#                   _    _           _   _                      #
#                  / \  | | ___ _ __| |_| |                     #
#                 / _ \ | |/ _ \ '__| __| |                     #
#                / ___ \| |  __/ |  | |_|_|                     #
#               /_/   \_\_|\___|_|   \__(_)                     #
#                                                               #
#  You are entering into a secured area! Your IP, Login Time,   #
#   Username has been noted and has been sent to the server     #
#                       administrator!                          #
#   This service is restricted to authorized users only. All    #
#            activities on this system are logged.              #
#  Unauthorized access will be fully investigated and reported  #
#        to the appropriate law enforcement agencies.           #
#################################################################

EOL

if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Update - '/etc/motd' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Update - '/etc/motd' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 3 - VERIFY THAT GPGCHECK IS GLOBALLY ACTIVATED
echo
echo -e "CATEGORY 3 - VERIFY THAT GPGCHECK IS GLOBALLY ACTIVATED"

#3.1 - Check gpg files are existed in '/etc/apt/trusted.gpg.d/'
echo
echo -e "3.1 - Check gpg files are existed in '/etc/apt/trusted.gpg.d/'"
count=$(ls /etc/apt/trusted.gpg.d/ | wc -l)
if [[ "$count" -gt 0 ]]; then
  echo -e "Remediated: Check gpg files are existed in '/etc/apt/trusted.gpg.d/' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Check gpg files are existed in '/etc/apt/trusted.gpg.d/' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 4 - SYSTEM FILE PERMISSIONS
echo
echo -e "CATEGORY 4 - SYSTEM FILE PERMISSIONS"

#4.1 - File permissions for '/etc/fstab' should be set to 644
echo
echo -e "4.1 - File permissions for '/etc/fstab' should be set to 644"
sudo chmod 644 /etc/fstab
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: File permissions for '/etc/fstab' should be set to 644 - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: File permissions for '/etc/fstab' should be set to 644 - FAILED"
  fail=$((fail + 1))
fi

#4.2 - File permissions for '/etc/shadow' should be set to root:root 0000
echo
echo -e "4.2 - File permissions for '/etc/shadow' should be set to root:root 0000"
sudo chown root:root /etc/shadow && chgrp root /etc/shadow && chmod 0000 /etc/shadow
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: File permissions for '/etc/shadow' should be set to root:root 0000 - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: File permissions for '/etc/shadow' should be set to root:root 0000 - FAILED"
  fail=$((fail + 1))
fi

#4.3 - File permissions for '/etc/group' should be set to root:root 644
echo
echo -e "4.3 - File permissions for '/etc/group' should be set to root:root 644"
sudo chown root:root /etc/group && chgrp root /etc/group && chmod 644 /etc/group
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: File permissions for '/etc/group' should be set to root:root 644 - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: File permissions for '/etc/group' should be set to root:root 644 - FAILED"
  fail=$((fail + 1))
fi

#4.4 - File permissions for '/etc/passwd' should be set to root:root 0644
echo
echo -e "4.4 - File permissions for '/etc/passwd' should be set to root:root 0644"
sudo chown root:root /etc/passwd && chgrp root /etc/passwd && chmod 0644 /etc/passwd
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: File permissions for '/etc/passwd' should be set to root:root 0644 - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: File permissions for '/etc/passwd' should be set to root:root 0644 - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 5 - ACCOUNT AND ACCESS CONTROL
echo
echo -e "CATEGORY 5 - ACCOUNT AND ACCESS CONTROL"

# #5.1 - Forbidden access with null passwork - '/etc/pam.d/system-auth'
# echo
# echo -e "5.1 - Forbidden access with null passwork - '/etc/pam.d/system-auth'"
#
# ##
# ## NO NEED TO FIXED
# ##
# sudo sed -i 's/\<nullok\>//g' /etc/pam.d/system-auth
#
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Forbidden access with null passwork - '/etc/pam.d/system-auth' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Forbidden access with null passwork - '/etc/pam.d/system-auth' - FAILED"
#   fail=$((fail + 1))
# fi

#5.2 - Password Policy
echo
echo -e "5.2 - Password Policy"

#5.2.1 - Set PASS_MAX_DAYS = 90 for - '/etc/login.defs'
echo
echo -e "5.2.1 - Set PASS_MAX_DAYS = 90 for - '/etc/login.defs'"
sudo sed -i -e "/^PASS_MAX_DAYS[[:space:]]/c \PASS_MAX_DAYS  90" /etc/login.defs
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Set PASS_MAX_DAYS = 90 for - '/etc/login.defs - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Set PASS_MAX_DAYS = 90 for - '/etc/login.defs - FAILED"
  fail=$((fail + 1))
fi

#5.2.2 - Set PASS_MIN_DAYS = 7 for - '/etc/login.defs'
echo
echo -e "5.2.2 - Set PASS_MIN_DAYS = 7 for - '/etc/login.defs'"
sudo sed -i -e "/^PASS_MIN_DAYS[[:space:]]/c \PASS_MIN_DAYS  7" /etc/login.defs
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Set PASS_MIN_DAYS = 7 for - '/etc/login.defs - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Set PASS_MIN_DAYS = 7 for - '/etc/login.defs - FAILED"
  fail=$((fail + 1))
fi

#5.2.3 - Set PASS_WARN_AGE = 7 for - '/etc/login.defs'
echo
echo -e "5.2.3 - Set PASS_WARN_AGE = 7 for - '/etc/login.defs'"
sudo sed -i -e "/^PASS_WARN_AGE[[:space:]]/c \PASS_WARN_AGE  7" /etc/login.defs
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Set PASS_WARN_AGE = 7 for - '/etc/login.defs - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Set PASS_WARN_AGE = 7 for - '/etc/login.defs - FAILED"
  fail=$((fail + 1))
fi

#5.2.4 - Set pam_pwquality.so for - '/etc/pam.d/system-auth'
echo
echo -e "5.2.4 - Set pam_pwquality.so for - '/etc/pam.d/system-auth'"
sudo echo -e "password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=" >  /etc/pam.d/system-auth
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Set pam_pwquality.so for - '/etc/pam.d/system-auth' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Set pam_pwquality.so for - '/etc/pam.d/system-auth' - FAILED"
  fail=$((fail + 1))
fi

#5.2.5 - Add Password Quality for - '/etc/security/pwquality.conf'
echo
echo -e "5.2.5 - Add Password Quality for - '/etc/security/pwquality.conf'"
sudo cat > /etc/security/pwquality.conf <<EOL
difok = 4
minlen = 8
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 3
EOL
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Add Password Quality for - '/etc/security/pwquality.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Add Password Quality for - '/etc/security/pwquality.conf' - FAILED"
  fail=$((fail + 1))
fi

#5.2.6 - Disable Inactive User after 90 days for - '/etc/default/useradd'
echo
echo -e "5.2.6 - Disable Inactive User after 90 days for - '/etc/default/useradd'"
sudo echo "" >> /etc/default/useradd
sudo echo "INACTIVE=90" >> /etc/default/useradd
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Disable Inactive User after 90 days for - '/etc/default/useradd' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Disable Inactive User after 90 days for - '/etc/default/useradd' - FAILED"
  fail=$((fail + 1))
fi

# #5.2.7 - Set Lockouts for Failed Password Attempts for - '/etc/pam.d/common-auth' ==> "CAN'T LOGIN WITH PUBLIC IP"
# echo
# echo -e "5.2.7 - Set Lockouts for Failed Password Attempts for - '/etc/pam.d/common-auth'"
# sudo echo "" >> /etc/pam.d/common-auth
# sudo echo "auth required pam_tally2.so onerr=fail audit silent deny=6 unlock_time=900" >> /etc/pam.d/common-auth
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Set Lockouts for Failed Password Attempts for - '/etc/pam.d/common-auth' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Set Lockouts for Failed Password Attempts for - '/etc/pam.d/common-auth' - FAILED"
#   fail=$((fail + 1))
# fi

# #5.2.8 - Set Lockout Time For Failed Password Attempts for - '/etc/pam.d/common-account' ==> "CAN'T LOGIN WITH PUBLIC IP"
# echo
# echo -e "5.2.8 - Set Lockout Time For Failed Password Attempts for - '/etc/pam.d/common-account'"
# sudo echo "" >> /etc/pam.d/common-account
# sudo echo "account requisite pam_deny.so" >> /etc/pam.d/common-account
# sudo echo "account required pam_tally2.so" >> /etc/pam.d/common-account
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Set Lockout Time For Failed Password Attempts for - '/etc/pam.d/common-account' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Set Lockout Time For Failed Password Attempts for - '/etc/pam.d/common-account' - FAILED"
#   fail=$((fail + 1))
# fi

#5.2.9 - Limit Password Reuse for - '/etc/pam.d/common-password'
echo
echo -e "5.2.9 - Limit Password Reuse - '/etc/pam.d/common-password'"
sudo echo "" >> /etc/pam.d/common-password
sudo echo "password sufficient pam_unix.so existing_options remember=4" >> /etc/pam.d/common-password
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Limit Password Reuse for - '/etc/pam.d/common-password' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Limit Password Reuse for - '/etc/pam.d/common-password' - FAILED"
  fail=$((fail + 1))
fi

# 5.2.10 - Set Password Hashing Algorithm for - '/etc/login.defs and PAM'
# echo
# echo -e "5.2.10 - Set Password Hashing Algorithm for - '/etc/login.defs and PAM'"
# ##
# ## NO NEED TO FIXED
# ##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Set Password Hashing Algorithm for - '/etc/login.defs and PAM' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Set Password Hashing Algorithm for - '/etc/login.defs and PAM' - FAILED"
#   fail=$((fail + 1))
# fi

# #5.2.11 - Set Password Hashing Algorithm for - '/etc/pam.d/common-password'
# echo
# echo -e "5.2.11 - Set Password Hashing Algorithm for - '/etc/pam.d/common-password'"
# ##
# ## NO NEED TO FIXED
# ##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Set Password Hashing Algorithm for - '/etc/pam.d/common-password' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Set Password Hashing Algorithm for - '/etc/pam.d/common-password' - FAILED"
#   fail=$((fail + 1))
# fi


##CATEGORY 6 - SSH CONFIGURATION
echo
echo -e "CATEGORY 6 - SSH CONFIGURATION"

#6.1 - Forbidden access with Root for - '/etc/ssh/sshd_config'
echo
echo -e "6.1 - Forbidden access with Root for - '/etc/ssh/sshd_config'"
# sudo echo "" >> /etc/ssh/sshd_config
sudo echo "PermitRootLogin no" >> /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Forbidden access with Root for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Forbidden access with Root for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

#6.2 - Enable StrictModes for - '/etc/ssh/sshd_config'
echo
echo -e "6.2 - Enable StrictModes for - '/etc/ssh/sshd_config'"
# sudo echo "" >> /etc/ssh/sshd_config
sudo echo "StrictModes yes" >> /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Enable StrictModes for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Enable StrictModes for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

# #6.3 - Enable SSH Protocal v2 for - '/etc/ssh/sshd_config'
# echo
# echo -e "6.3 - Enable SSH Protocal v2 for - '/etc/ssh/sshd_config'"
# ##
# ## NO NEED TO FIXED
# ##
# # sudo echo "" >> /etc/ssh/sshd_config
# sudo echo "Protocal 2" >> /etc/ssh/sshd_config
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Enable SSH Protocal v2 for - '/etc/ssh/sshd_config' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Enable SSH Protocal v2 for - '/etc/ssh/sshd_config' - FAILED"
#   fail=$((fail + 1))
# fi

#6.4 - Enable SFTP for - '/etc/ssh/sshd_config'
# echo
# echo -e "6.4 - Enable SFTP for - '/etc/ssh/sshd_config'"
# ##
# ## NO NEED TO FIXED
# ##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Enable SFTP for - '/etc/ssh/sshd_config' - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Enable SFTP for - '/etc/ssh/sshd_config' - FAILED"
#   fail=$((fail + 1))
# fi

#6.5 - Session-timeout = 900 (15 mins) for - '/etc/ssh/sshd_config'
echo
echo -e "6.5 - Session-timeout = 900 (15 mins) for - '/etc/ssh/sshd_config'"
sed -i 's/ClientAliveInterval 120/ClientAliveInterval 900/' /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Session-timeout = 900 (15 mins) for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Session-timeout = 900 (15 mins) for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

#6.6 - Forbidden Empty Password for - '/etc/ssh/sshd_config'
echo
echo -e "6.6 - Forbidden Empty Password for - '/etc/ssh/sshd_config'"
# sudo echo "" >> /etc/ssh/sshd_config
sudo echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Forbidden Empty Password for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Forbidden Empty Password for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

#6.7 - Enable LogLevel INFO for - '/etc/ssh/sshd_config'
echo
echo -e "6.7 - Enable LogLevel INFO for - '/etc/ssh/sshd_config'"
# sudo echo "" >> /etc/ssh/sshd_config
sudo echo "LogLevel INFO" >> /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Enable LogLevel INFO for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Enable LogLevel INFO for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

#6.8 - Disable HostbasedAuthentication for - '/etc/ssh/sshd_config'
echo
echo -e "6.8 - Disable HostbasedAuthentication for - '/etc/ssh/sshd_config'"
# sudo echo "" >> /etc/ssh/sshd_config
sudo echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Disable HostbasedAuthentication for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Disable HostbasedAuthentication for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi

#6.9 - Disable SSH X11 Forwarding for - '/etc/ssh/sshd_config'
echo
echo -e "6.9 - Disable SSH X11 Forwarding for - '/etc/ssh/sshd_config'"
sed -i 's/X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Disable SSH X11 Forwarding for - '/etc/ssh/sshd_config' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Disable SSH X11 Forwarding for - '/etc/ssh/sshd_config' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 7 - ADDITIONAL PROCESS HARDENING
echo
echo -e "CATEGORY 7 - ADDITIONAL PROCESS HARDENING"

#7.1 - Ensure address space layout randomization (ASLR) is enabled for - '/etc/sysctl.conf'
echo
echo -e "7.1 - Ensure address space layout randomization (ASLR) is enabled for - '/etc/sysctl.conf'"
sudo echo "" >> /etc/sysctl.conf
sudo echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure address space layout randomization (ASLR) is enabled for - '/etc/sysctl.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure address space layout randomization (ASLR) is enabled for - '/etc/sysctl.conf' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 8 - KERNEL CONFIGURATION
echo
echo -e "CATEGORY 8 - KERNEL CONFIGURATION"

#8.1 - Ensure TCP SYN Cookies is enabled for - '/etc/sysctl.conf'
echo
echo -e "8.1 - Ensure TCP SYN Cookies is enabled for - '/etc/sysctl.conf'"
sudo echo "" >> /etc/sysctl.conf
sudo echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure TCP SYN Cookies is enabled for - '/etc/sysctl.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure TCP SYN Cookies is enabled for - '/etc/sysctl.conf' - FAILED"
  fail=$((fail + 1))
fi

#8.2 - Ensure ALL Packages Redirect is disabled for - '/etc/sysctl.conf'
echo
echo -e "8.2 - Ensure ALL Packages Redirect is disabled for - '/etc/sysctl.conf'"
sudo echo "" >> /etc/sysctl.conf
sudo echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure ALL Packages Redirect is disabled for - '/etc/sysctl.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure ALL Packages Redirect is disabled for - '/etc/sysctl.conf' - FAILED"
  fail=$((fail + 1))
fi

#8.3 - Ensure IMCP Packages Redirect is disabled for - '/etc/sysctl.conf'
echo
echo -e "8.3 - Ensure IMCP Packages Redirect is disabled for - '/etc/sysctl.conf'"
sudo echo "" >> /etc/sysctl.conf
sudo echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure IMCP Packages Redirect is disabled for - '/etc/sysctl.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure IMCP Packages Redirect is disabled for - '/etc/sysctl.conf' - FAILED"
  fail=$((fail + 1))
fi

#8.4 - Ensure broadcast ICMP requests are ignored for - '/etc/sysctl.conf'
echo
echo -e "8.4 - Ensure broadcast ICMP requests are ignored for - '/etc/sysctl.conf'"
sudo echo "" >> /etc/sysctl.conf
sudo echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf
sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1
sudo sysctl -w net.ipv4.route.flush=1
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure broadcast ICMP requests are ignored for - '/etc/sysctl.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure broadcast ICMP requests are ignored for - '/etc/sysctl.conf' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 9 - NTP SERVER CONFIGURATION
echo
echo -e "CATEGORY 9 - NTP SERVER CONFIGURATION"
#9.1 - Configure VIB NTP Servers for - '/etc/ntp.conf'
echo
echo -e "9.1 - Configure VIB NTP Servers for - '/etc/chrony/chrony.conf'"
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
sudo apt-get -y update
sudo apt-get install chrony -y
sudo systemctl start chronyd
sudo echo "server 10.1.46.51" >> /etc/chrony/chrony.conf
sudo systemctl enable chrony
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Configure VIB NTP Servers for - '/etc/ntp.conf' - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Configure VIB NTP Servers for - '/etc/ntp.conf' - FAILED"
  fail=$((fail + 1))
fi


##CATEGORY 10 - SERVICES CONFIGURATION
echo
echo -e "CATEGORY 10 - SERVICES CONFIGURATION"

#10.1 - Ensure httpd is not enabled
# echo
# echo -e "10.1 - Ensure httpd is not enabled"
#sudo systemctl stop httpd
#sudo systemctl disable httpd
# ##
# ## NO NEED TO FIXED
# ##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Ensure httpd is not enabled - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Ensure httpd is not enabled - FAILED"
#   fail=$((fail + 1))
# fi

# #10.2 - Ensure cups is not enabled
# echo
# echo -e "10.2 - Ensure cups is not enabled"
# #sudo systemctl stop cups
# #sudo systemctl disable cups
# ##
# ## NO NEED TO FIXED
# ##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Ensure cups is not enabled - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Ensure cups is not enabled - FAILED"
#   fail=$((fail + 1))
# fi

#10.3 - Ensure sendmail is not enabled
# echo
# echo -e "10.3 - Ensure sendmail is not enabled"
#sudo systemctl stop sendmail
#sudo systemctl disable sendmail
##
## NO NEED TO FIXED
##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Ensure sendmail is not enabled - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Ensure sendmail is not enabled - FAILED"
#   fail=$((fail + 1))
# fi

#10.4 - Ensure send nfs-server is not enabled
# echo
# echo -e "10.4 - Ensure nfs-server is not enabled"
# sudo systemctl stop nfs-server
# sudo systemctl disable nfs-server
##
## NO NEED TO FIXED
##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Ensure nfs-server is not enabled - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Ensure nfs-server is not enabled - FAILED"
#   fail=$((fail + 1))
# fi

#10.5 - Ensure send rpcbind is not enabled
echo
echo -e "10.5 - Ensure rpcbind is not enabled"
sudo systemctl stop rpcbind
sudo systemctl disable rpcbind
sudo apt -y remove rpcbind
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Ensure rpcbind is not enabled - COMPLETED"
  success=$((success + 1))
else
  echo -e "Remediated: Ensure rpcbind is not enabled - FAILED"
  fail=$((fail + 1))
fi


#10.6 - Ensure send samba is not enabled
# echo
# echo -e "10.6 - Ensure samba is not enabled"
# sudo systemctl stop smbd
# sudo systemctl disable smbd
##
## NO NEED TO FIXED
##
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Ensure samba is not enabled - COMPLETED"
#   success=$((success + 1))
# else
#   echo -e "Remediated: Ensure samba is not enabled - FAILED"
#   fail=$((fail + 1))
# fi


##CATEGORY 11 - LOGGING AND AUDITING - CONFIGURE SYSTEM ACCOUNTING (auditd)
echo
echo -e "CATEGORY 11 - LOGGING AND AUDITING - CONFIGURE SYSTEM ACCOUNTING (auditd)"

11.1 - Ensure auditd service is enabled
echo
echo -e "11.1 - Ensure auditd service is enabled"
sudo apt -y update
sudo apt install -y auditd audispd-plugins
sudo systemctl start auditd && sudo systemctl enable auditd
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
 echo -e "Remediated: Ensure auditd service is enabled - COMPLETED"
 success=$((success + 1))
else
 echo -e "Remediated: Ensure auditd service is enabled - FAILED"
 fail=$((fail + 1))
fi


# ##CATEGORY 12 - INTEGRATION WITH VIB SIEM SENTINEL
# echo
# echo -e "CATEGORY 12 - INTEGRATION WITH VIB SIEM SENTINEL"

# #12.1 - Integration with VIB SIEM Sentinel
# echo
# echo -e "12.1 - Integration with VIB SIEM Sentinel"
# sudo wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && \
# sh onboard_agent.sh -w b2854b71-60bf-4340-855f-485be63c146f \
# -s hPqp0uqzW9efFVltp99qrMax6q39u2Zhvrnm3WC77HUhCI7MspCKoI/EZC5+3x84ty6Zi+GXzrfB8EzWui5GMw== \
# -d opinsights.azure.com
# policystatus=$?
# if [[ "$policystatus" -eq 0 ]]; then
#   echo -e "Remediated: Integration with VIB SIEM Sentinel - COMPLETED"
#   success=$((success + 1))
#   rm -rf onboard_agent.sh && rm -rf omsagent-1.14.19-0.universal.x64.sh
# else
#   echo -e "Remediated: Integration with VIB SIEM Sentinel - FAILED"
#   fail=$((fail + 1))
#   rm -rf onboard_agent.sh && rm -rf omsagent-1.14.19-0.universal.x64.sh
# fi


##CATEGORY 13 - AZURE MICROSOFT DEFENDER
echo
echo -e "CATEGORY 13 - AZURE MICROSOFT DEFENDER"

#13.1 - Install Azure Microsoft Defender
echo
echo -e "13.1 - Install Azure Microsoft Defender"
curl -o microsoft.list https://packages.microsoft.com/config/debian/11/prod.list
sudo mv ./microsoft.list /etc/apt/sources.list.d/microsoft-prod.list
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
sudo apt-get install -y apt-transport-https
sudo apt-get install -y libplist-utils
sudo apt-get -y update && apt -y full-upgrade
sudo apt-get -y install mdatp
sudo systemctl status mdatp
sudo systemctl start mdatp
sudo systemctl enable mdatp
chmod +x /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py
/usr/bin/python /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py
# /usr/bin/mdatp health --field healthy
/usr/bin/mdatp health --field definitions_status
policystatus=$?
if [[ "$policystatus" -eq 0 ]]; then
  echo -e "Remediated: Install Azure Microsoft Defender - COMPLETED"
  success=$((success + 1))
  rm -rf /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py
else
  echo -e "Remediated: Install Azure Microsoft Defender - FAILED"
  fail=$((fail + 1))
  rm -rf /tmp/MicrosoftDefenderATPOnboardingLinuxServer.py
fi


###########################################################################################################################

echo
echo -e "- Remediation script for Azure Debian " $(lsb_release --release | cut -f2) " executed successfully!!"
echo
echo -e "SUMMARY:"
echo -e "- Remediation Passed: $success" 
echo -e "- Remediation Failed: $fail"

###########################################################################################################################
