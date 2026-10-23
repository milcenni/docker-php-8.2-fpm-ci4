#!/bin/sh
set -e

cd /var/www/html

if [ ! -f public/index.php ]; then
    echo "[entrypoint] WARNING: no app found in /var/www/html (put the project files in ./html), skipping setup"
    exec docker-php-entrypoint "$@"
fi

git config --global --add safe.directory /var/www/html 2>/dev/null || true

if [ ! -f vendor/autoload.php ]; then
    echo "[entrypoint] vendor/ missing, running composer install..."
    if [ "${COMPOSER_NO_DEV:-1}" = "1" ]; then
        composer install --no-dev --optimize-autoloader --no-interaction --no-progress
    else
        composer install --optimize-autoloader --no-interaction --no-progress
    fi
fi

if [ ! -f .env ]; then
    echo "[entrypoint] WARNING: no .env in app root (copy 'env' to '.env' and configure it)"
fi

# Directories PHP needs to write to
for d in writable/cache writable/logs writable/session writable/uploads writable/debugbar public/neoterik/uploads; do
    mkdir -p "$d"
done
chown -R www-data:www-data writable public/neoterik/uploads
chmod -R ug+rwX writable public/neoterik/uploads

exec docker-php-entrypoint "$@"
