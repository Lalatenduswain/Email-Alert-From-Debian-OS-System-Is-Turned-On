# Send Notification Script

## Description

This script sends a system notification email when your Ubuntu system is turned on. The email includes the date, external IP address, and geolocation information.

## Prerequisites

Before running the script, ensure you have the necessary packages installed and your system is configured correctly.

### Required Packages

Install the following packages:

```sh
sudo apt install libsasl2-modules postfix mailutils sendmail postfix-pcre -y
sudo apt-get install msmtp-mta
```

### Verify Postfix Installation

Check the Postfix installation by running:

```sh
postconf -d | grep mail_version
dpkg -l | grep postfix
```

### Configure msmtp

Configure `msmtp` as the Mail Transfer Agent (MTA). You may need to create or edit the configuration file at `/etc/msmtprc`.

```sh
sudo nano /etc/msmtprc
```

Add the following configuration to the file (replace placeholders with your email provider's SMTP details):

```sh
# Example configuration
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        default
host           smtp.example.com
port           587
from           you@example.com
user           your_username
password       your_password
```

Make sure the configuration file is only readable by you:

```sh
sudo chmod 600 /etc/msmtprc
```

### Testing Email Sending

Send a test email to ensure everything is working correctly:

```sh
echo "This is a test email." | mail -s "Test Email" lalatendu.swain@gmail.com
```

## Postfix Configuration for Email Header Name

### Configure Email Header Name

Edit the Postfix configuration to change the email header name:

```sh
sudo nano /etc/postfix/smtp_header_checks
```

Add the following line:

```sh
/^From:.*/ REPLACE From: PVE Login Alert <urfromemail@gmail.com>
```

Apply the changes:

```sh
sudo postmap hash:/etc/postfix/smtp_header_checks
sudo postfix reload
```

### Configure SMTP Authentication

Edit the SMTP authentication details:

```sh
sudo nano /etc/postfix/sasl_passwd
```

Add the following line (replace with your actual email and password):

```sh
[smtp.gmail.com]:587 uremail@gmail.com:ur_strong_password_here
```

Apply the changes and set permissions:

```sh
sudo postmap /etc/postfix/sasl_passwd
sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
sudo service postfix restart
sudo service postfix status
```

### Postfix Main Configuration

Edit the main Postfix configuration file:

```sh
sudo nano /etc/postfix/main.cf
```

Add the following lines:

```sh
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
inet_protocols = ipv4
smtp_header_checks = pcre:/etc/postfix/smtp_header_checks
```

### Truncate Logs

Truncate the mail logs:

```sh
sudo truncate -s 0 /var/log/mail.log
sudo truncate -s 0 /home/lalatendu/mbox
```

Send a test email:

```sh
echo "Test email body" | mail -s "Test Subject" lalatendu.swain@gmail.com
```

Monitor the mail log:

```sh
sudo tail -f /var/log/mail.log
```

## SSH Login Notification Script

Add the following to your `/etc/profile` to send an email notification on SSH login:

```sh
sudo nano /etc/profile
```

Add this script to the end of the file:

```sh
#!/bin/bash

if [ -n "$SSH_CLIENT" ]; then
  # Get current date in "13th June 2024" format
  DATE=$(date +'%e %B %Y' | sed 's/  / /g;s/^ //;s/ $//;s/  / /g;s/^ //;s/ $//;s/  / /g;s/^ //;s/ $//;s/  / /g;s/^ //;s/ $//')
  
  # Get current time in AM/PM format including seconds
  TIME=$(date +'%l:%M:%S %p')

  # Get current time in AM/PM format including seconds for subject line
  TIME_SUBJECT=$(date +'%l:%M:%S %p')

  # Get the user name
  USER_NAME=$(whoami)

  # Compose the SSH login alert message
  TEXT="${DATE} ${TIME}: ssh login to ${USER_NAME}@$(hostname -f) from $(echo $SSH_CLIENT | awk '{print $1}')"
  
  # Primary email recipient
  echo "$TEXT" | mail -s "SSH Login Alert - ${USER_NAME} - ${DATE} ${TIME_SUBJECT}" lalatendu.swain@gmail.com
  
  # Additional email recipient
  echo "$TEXT" | mail -s "SSH Login Alert - ${USER_NAME} - ${DATE} ${TIME_SUBJECT}" swain@lalatendu.info
fi
```

## Email Aliases

Set up email aliases:

```sh
sudo nano /etc/aliases
```

Add the following lines:

```sh
swain: lalatendu.swain@gmail.com
lalatendu: lalatendu.swain@gmail.com
```

Check the mailbox:

```sh
cat /home/lalatendu/mbox
cat /var/mail/lalatendu
```

Restart Postfix:

```sh
sudo service postfix restart
```

## Script Usage

Clone the repository and navigate to the directory:

```sh
git clone https://github.com/Lalatenduswain/send_notification.sh
cd send_notification.sh
```

### Script Content

The script `send_notification.sh` should have the following content:

```sh
#!/bin/bash

# Replace the placeholders with your email settings
EMAIL_TO="lalatendu.swain@gmail.com"
SUBJECT="System Notification: Ubuntu System Turned On"
DATE=$(date)
EXTERNAL_IP=$(curl -s https://ipinfo.io/ip)
GEO_LOCATION=$(curl -s https://ipinfo.io/${EXTERNAL_IP}/json | jq -r '.city + ", " + .region + ", " + .country')

# Body of the email with IP and geolocation information
BODY="Your Ubuntu system has been turned on at $DATE\n\nExternal IP Address: $EXTERNAL_IP\nLocation: $GEO_LOCATION"

# Send the email
echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL_TO"
```

### Running the Script

Ensure the script is executable:

```sh
chmod +x send_notification.sh
```

Run the script:

```sh
./send_notification.sh
```

## Disclaimer | Running the Script

**Author:** Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided as-is and may require modifications or updates based on your specific environment and requirements. Use it at your own risk. The authors of the script are not liable for any damages or issues caused by its usage.

## Donations

If you find this script useful and want to show your appreciation, you can donate via [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain).

## Support or Contact

Encountering issues? Don't hesitate to submit an issue on our [GitHub page](https://github.com/Lalatenduswain/send_notification.sh/issues).
