#!/bin/sh
# Refer: /usr/local/bin/docker-php-entrypoint
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- php-fpm "$@"
fi

# Testing sendmail
php -r "\$from = \$to = 'php-contaier@docker.local'; \$x = mail(\$to, 'Testing email on startup', 'Hello World', 'From: '. \$from); var_dump(\$x);"

# Fix permission
chown nginx:nginx /home/nginx/.composer
chmod 644 /home/nginx/.ssh/config \
&& chmod -R 600 /home/nginx/.ssh/* \
&& chown -R nginx:nginx /home/nginx/ \
&& eval `ssh-agent -s`

exec "$@"
