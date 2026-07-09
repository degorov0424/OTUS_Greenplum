#!/usr/bin/env bash

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PGHOST=""; PGPORT="5432"; PGUSER=""; PGPASSWORD=""
PGDATABASE="logistics"; PXF_READER_PW=""; ETL_SRC_PW=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)         PGHOST="$2"; shift 2;;
        --port)         PGPORT="$2"; shift 2;;
        --user)         PGUSER="$2"; shift 2;;
        --password)     PGPASSWORD="$2"; shift 2;;
        --db)           PGDATABASE="$2"; shift 2;;
        --pxf-reader-pw) PXF_READER_PW="$2"; shift 2;;
        --etl-src-pw)   ETL_SRC_PW="$2"; shift 2;;
        *) echo "Неизвестный аргумент: $1" >&2; exit 1;;
    esac
done

# Заполнить install.conf только если все обязательные параметры заданы
if [ -n "$PGHOST" ] && [ -n "$PGUSER" ] && [ -n "$PGPASSWORD" ]; then
    sed \
      -e "s|__HOST__|$PGHOST|g" \
      -e "s|__PORT__|$PGPORT|g" \
      -e "s|__USER__|$PGUSER|g" \
      -e "s|__PASSWORD__|$PGPASSWORD|g" \
      -e "s|__DB__|$PGDATABASE|g" \
      -e "s|__PXF_READER_PW__|$PXF_READER_PW|g" \
      -e "s|__ETL_SRC_PW__|$ETL_SRC_PW|g" \
      "$SCRIPT_DIR/install.conf_t" > "$SCRIPT_DIR/install.conf"
else
    # Копировать шаблон без замен (оставить маркеры)
    cp "$SCRIPT_DIR/install.conf_t" "$SCRIPT_DIR/install.conf"
    echo "Внимание: параметры не заданы, install.conf содержит шаблонные маркеры." >&2
fi
chmod 600 "$SCRIPT_DIR/install.conf"

cp "$SCRIPT_DIR/install.sh_t" "$SCRIPT_DIR/install.sh"
chmod +x "$SCRIPT_DIR/install.sh"

echo "OK: созданы $SCRIPT_DIR/install.conf и $SCRIPT_DIR/install.sh"
echo "Запуск: bash db_pg/install.sh"
