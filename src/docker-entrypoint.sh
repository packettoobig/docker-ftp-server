#!/bin/bash

# Create users and groups
addgroup \
	-g $GID \
	-S \
	$FTP_USER

adduser \
	-D \
	-G $FTP_USER \
	-h /home/$FTP_USER \
	-s /bin/false \
	-u $UID \
	$FTP_USER

mkdir -p /home/$FTP_USER
chown -R $FTP_USER:$FTP_USER /home/$FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd

# openssl req -x509 -noenc -days 3650 -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
# 	-keyout /etc/vsftpd.key -out /etc/vsftpd.crt \
# 	-subj "/CN=$FQDN" \
# 	-addext "subjectAltName=DNS:$FQDN,DNS:*.$FQDN"

# Create SSL cert
openssl req -x509 -noenc -days 3650 -newkey rsa:2048 \
	-keyout /etc/ssl/private/vsftpd.key \
	-out /etc/ssl/certs/vsftpd.crt \
	-subj "/CN=$FQDN" \
	-addext "subjectAltName=DNS:$FQDN,DNS:*.$FQDN"

# Manage config file (transform template variables into static data)
eval "cat <<EOF
$(< /etc/vsftpd.conf.template)
EOF
" | cat > /etc/vsftpd.conf

touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log | tee /dev/stdout &
touch /var/log/xferlog
tail -f /var/log/xferlog | tee /dev/stdout &

/usr/sbin/vsftpd
