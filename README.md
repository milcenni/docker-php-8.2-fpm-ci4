# Neoterik — php-fpm stack

nginx (`web`) + PHP 8.2-FPM (`app`). The project lives in `./html`, which is mounted to
`/var/www/html` in both containers, so you can edit, pull or replace the files there without rebuilding.

```
php-fpm/
├── html/              ← put the Neoterik project files here
├── docker-compose.yml
├── Dockerfile
├── nginx/default.conf
└── php/
```

## Deploy on a server

```bash
cd php-fpm

# 1. put the app into ./html (it must be empty for clone)
git clone git@bitbucket.org:milcenni/neoterik.git html
cp html/env html/.env                # then edit baseURL, DB, CI_ENVIRONMENT=production

# 2. start
cp .env.example .env                 # edit HTTP_PORT if needed
docker compose up -d --build
```

On first start the `app` container:
- runs `composer install` if `vendor/` is missing (`--no-dev` unless `COMPOSER_NO_DEV=0`)
- creates `writable/*` and `public/neoterik/uploads`, and gives them to `www-data`

If `html/` is empty, the containers still start and the app container just logs a warning.

## Everyday

```bash
cd html && git pull                            # code updates go live without a restart (opcache revalidates every 2s)
docker compose logs -f app                     # php-fpm / composer output
docker compose exec app php spark migrate      # spark commands
docker compose exec app composer install       # after composer.lock changes
docker compose restart app                     # re-run the setup (e.g. after replacing html/ entirely)
```

## Database

There's no DB container. `host.docker.internal` maps to the host (also on Linux),
so `database.default.hostname = host.docker.internal` reaches a MySQL running on the server itself.
On Linux, MySQL must listen on the docker bridge (e.g. `bind-address = 0.0.0.0`) and the user must be allowed from `172.%`.
