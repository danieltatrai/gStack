#!/bin/bash

# for testing:
# docker run -it --rm -v "$(pwd):/project" -v "$(pwd):/src" gstack-registry:5000/gstack-main setupcheck
# normally:
# docker run -it --rm -v "$(pwd):/project" gstack-registry:5000/gstack-main setupcheck

set -e

. /src/docker/main/utils.sh

readenv() {
  sed -ri "/^(\\s*#.*|\\s*|($1=).*)$/d" /tmp/.env
  while IFS= read -r p; do
    if [ "$(echo "$p" | sed -rn 's/^([^#=]*)=(.*)$/\1/p')" = "$1" ]; then
      echo -n "$p" | sed -rn 's/^([^#=]*)=(.*)$/\2/p'
      return 0
    fi
  done < /project/.env
  return 1
}

readsec() {
  sed -ri "/^(\\s*#.*|\\s*|($1=).*)$/d" /tmp/.secret.env
  SECRET_FILE_PATH=/project/.secret.env readsecret $1 2>/dev/null
}

createsec() {
  SECRET_FILE_PATH=/project/.secret.env createsecret "$@"
}

devenv() {
  # to test non-dev environment, delete the comment:
  # return 1
  [ -d /project/.git ]
}

err() {
  echo "$1" >&2; exit 1
}

################################################################################

if ! [ -d /project ]; then
  err "Make sure to bind mount the project directory"
fi

usr="$(stat -c %u:%u /project)"

# .env #########################################################################

if ! [ -f /project/.env ]; then
  touch /project/.env; chown "$usr" /project/.env
fi

# Copy the .env file to tmp for extra variable check
cp /project/.env /tmp/.env

# .env: COMPOSE_FILE
if value="$(readenv COMPOSE_FILE)"; then
  if devenv; then
    if ! [ "$value" = 'docker-compose.yml:docker-compose.dev.yml' ]; then
      err "In development COMPOSE_FILE should be set to 'docker-compose.yml:docker-compose.dev.yml'"
    fi
  else
    if ! [ "$value" = 'docker-compose.yml' ]; then
      err "In non-development environment COMPOSE_FILE should be set to 'docker-compose.yml'"
    fi
  fi
else
  if devenv; then
    echo 'COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml' >> /project/.env
  fi
fi

# .env: COMPOSE_PROJECT_NAME
if ! value=$(readenv COMPOSE_PROJECT_NAME); then
  read -p "Enter the name of the project (leave empty to use 'gstack'): " value
  if [ -z "$value" ]; then value=gstack; fi
  echo "COMPOSE_PROJECT_NAME=$value" >> /project/.env
fi

# .env: ENV
if value="$(readenv ENV)"; then
  if devenv; then
    if ! [ "$value" = 'DEV' ]; then
      err "In development ENV should be set to 'DEV'"
    fi
  else
    case "$value" in
      TEST|BUILD|PROD)
        ;;
      *)
        err "ENV should be one of TEST, BUILD or PROD"
        ;;
    esac
  fi
else
  if devenv; then
    echo "ENV=DEV" >> /project/.env
  else
    value=$(ask_user "What kind of environment/infrastructure are you building?" TEST BUILD PROD)
    echo "ENV=$value" >> /project/.env
  fi
fi

# .env: REGISTRY_URL
if ! value=$(readenv REGISTRY_URL); then
  read -p "Enter the url of the docker registry to use (leave empty to use 'gstack'): " value
  if [ -z "$value" ]; then value=gstack; fi
  echo "REGISTRY_URL=$value" >> /project/.env
fi

# .env: VERSION
version=$(cat /src/conf/VERSION)
if value="$(readenv VERSION)"; then
  if devenv; then
    if ! [ "$value" = "latest" ]; then
      err "In development VERSION should be set to 'latest'"
    fi
  else
    if ! [ "$value" = "$version" ]; then
      err "VERSION must be set to the version (tag) of the image being used: $version"
    fi
  fi
else
  if devenv; then
    echo "VERSION=latest" >> /project/.env
  else
    echo "VERSION=$version" >> /project/.env
  fi
fi

# .env: HOST_NAME
if ! value=$(readenv HOST_NAME); then
  default=gstack.net
  if devenv; then default=dev.gstack.net; fi
  read -p "Enter the base url of the project (leave empty to use '$default'): " value
  if [ -z "$value" ]; then value="$default"; fi
  echo "HOST_NAME=$value" >> /project/.env
fi

# .env: SERVER_IP
part="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
regex="^$part\\.$part\\.$part\\.$part$"
if value=$(readenv SERVER_IP); then
  if ! [[ "$value" =~ $regex ]]; then
    err "SERVER_IP is invalid"
  fi
else
  while true; do
    read -p "Enter the IP address of the server (leave empty to use '127.0.0.1'): " value
    if [ -z "$value" ]; then value="127.0.0.1"; fi
    if [[ "$value" =~ $regex ]]; then break; fi
  done
  echo "SERVER_IP=$value" >> /project/.env
fi

# .env: BACKUP_UID
uid="$(stat -c %u /project)"
regex="^([0-9]|[1-9][0-9]|[1-9][0-9][0-9]|[1-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9])$"
if value=$(readenv BACKUP_UID); then
  if devenv; then
    if ! [ "$value" = "$uid" ]; then
      err "In development BACKUP_UID should be set to the developer's uid ($uid)"
    fi
  else
    if ! [[ "$value" =~ $regex ]]; then
      err "BACKUP_UID must be an integer in range 0-99999"
    fi
  fi
else
  if devenv; then
    echo "BACKUP_UID=$uid" >> /project/.env
  else
    while true; do
      read -p "Enter the backup user's uid (0-99999, leave empty to use '1024'): " value
      if [ -z "$value" ]; then value="1024"; fi
      if [[ "$value" =~ $regex ]]; then break; fi
    done
    echo "BACKUP_UID=$value" >> /project/.env
  fi
fi

# Search for extra variables
extra=$(cat /tmp/.env)
if [ -n "$extra" ]; then
  echo "WARNING: extra variables in .env:"
  echo "$extra"
fi

# .secret.env ##################################################################

if ! [ -f /project/.secret.env ]; then
  touch /project/.secret.env; chown "$usr" /project/.secret.env
fi

# Copy the .env file to tmp for extra variable check
cp /project/.secret.env /tmp/.secret.env

# DB_PASSWORD
if ! value=$(readsec DB_PASSWORD); then
  createsec -r DB_PASSWORD 16
fi

# DJANGO_SECRET_KEY
if ! value=$(readsec DJANGO_SECRET_KEY); then
  createsec -r DJANGO_SECRET_KEY 64
fi

# PG_CERTIFICATE_...
mkdir -p /project/.files; chown "$usr" /project/.files; chmod 700 /project/.files

if key=$(readsec PG_CERTIFICATE_KEY) && crt=$(readsec PG_CERTIFICATE_CRT) && cacert=$(readsec PG_CERTIFICATE_CACERT); then
  echo "$key" > /tmp/certificate.key
  echo "$crt" > /tmp/certificate.crt
  echo "$cacert" > /tmp/ca.crt
else
  echo "The secrets PG_CERTIFICATE_KEY, PG_CERTIFICATE_CRT and PG_CERTIFICATE_CACERT are not set correctly." >&2
  if devenv; then
    answer="$(DEFAULT_ANSWER=yes ask_user "Do you want to set it up automatically? (certificates under .files will be lost)" yes no)"
    if [ "$answer" = 'yes' ]; then
      cd /project/.files
      COMPOSE_PROJECT_NAME=$(readenv COMPOSE_PROJECT_NAME) \
      HOST_NAME=$(readenv HOST_NAME) \
      SERVER_IP=$(readenv SERVER_IP) /src/docker/main/create_dev_certificates.sh
      chown -R "$usr" /project/.files
      cd /

      createsec -f PG_CERTIFICATE_KEY /project/.files/certificate.key 1
      createsec -f PG_CERTIFICATE_CRT /project/.files/certificate.crt 1
      createsec -f PG_CERTIFICATE_CACERT /project/.files/ca.crt 1

      readsec PG_CERTIFICATE_KEY > /tmp/certificate.key
      readsec PG_CERTIFICATE_CRT > /tmp/certificate.crt
      readsec PG_CERTIFICATE_CACERT > /tmp/ca.crt
    else
      exit 1
    fi
  else
    exit 1
  fi
fi

if ! [ "$(openssl x509 -noout -modulus -in /tmp/certificate.crt)" = "$(openssl rsa -noout -modulus -in /tmp/certificate.key)" ]; then
  err "PG_CERTIFICATE_KEY and PG_CERTIFICATE_CRT are not compatible."
fi

if ! openssl verify -CAfile /tmp/ca.crt /tmp/certificate.crt > /dev/null; then
  err "PG_CERTIFICATE_CRT was not signed by PG_CERTIFICATE_CACERT."
fi

# SITE_CERTIFICATE_...
if key=$(readsec SITE_CERTIFICATE_KEY) && crt=$(readsec SITE_CERTIFICATE_CRT); then
  echo "$key" > /tmp/certificate.key
  echo "$crt" > /tmp/certificate.crt
else
  echo "The secrets SITE_CERTIFICATE_KEY, SITE_CERTIFICATE_CRT are not set correctly." >&2
  if devenv; then
    answer="$(DEFAULT_ANSWER=yes ask_user "Do you want to use the existing certificates?" yes no)"
    if [ "$answer" = 'yes' ]; then
      readsec PG_CERTIFICATE_KEY | createsec -s SITE_CERTIFICATE_KEY 1
      readsec PG_CERTIFICATE_CRT | createsec -s SITE_CERTIFICATE_CRT 1

      readsec SITE_CERTIFICATE_KEY > /tmp/certificate.key
      readsec SITE_CERTIFICATE_CRT > /tmp/certificate.crt
    else
      exit 1
    fi
  else
    exit 1
  fi
fi

if ! [ "$(openssl x509 -noout -modulus -in /tmp/certificate.crt)" = "$(openssl rsa -noout -modulus -in /tmp/certificate.key)" ]; then
  err "SITE_CERTIFICATE_KEY and SITE_CERTIFICATE_CRT are not compatible."
fi

# Search for extra variables
sed -ri "s/^([^=]+=).*$/\\1**********/" /tmp/.secret.env
extra=$(cat /tmp/.secret.env)
if [ -n "$extra" ]; then
  echo "WARNING: extra variables in .secret.env:"
  echo "$extra"
fi
