#! /bin/bash
docker run --rm -t --name certbot \
    -v "/data/containers/certbot/etc/letsencrypt:/etc/letsencrypt" \
    -v "/data/containers/certbot/var/lib/letsencrypt:/var/lib/letsencrypt" \
    -v "/data/containers/certbot/var/log/letsencrypt:/var/log/letsencrypt" \
    -v "/data/containers/certbot/secrets:/secrets" \
    certbot/dns-digitalocean:v2.7.4 \
    renew \
    --dns-digitalocean \
    --dns-digitalocean-credentials /secrets/digitalocean.ini

# running post-scripts
for s in $(ls /data/containers/certbot/post/*.sh); do
    echo running "$s"
    bash "$s";
done
