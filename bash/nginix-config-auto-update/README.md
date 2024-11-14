
```bash
crontab -e
* * * * * /home/ubuntu/script.sh >> /var/log/nginx-update.log 2>&1
