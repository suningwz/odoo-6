#!/bin/bash

BACKUP_DIR=/home/truongpx/Downloads/backup
ADDONS_FOLDER=/home/truongpx/dev/projects/tokyolife/erp-odoo
ODOO_DATABASE=odoo13_1
ADMIN_PASSWORD=""
URL=http://localhost
CURRENT_DATE=$(date +%d%m%Y)

# create a backup directory for database and addons file
mkdir -p ${BACKUP_DIR}
tar czfP ${BACKUP_DIR}/custom_addons.${CURRENT_DATE}.tar.gz ${ADDONS_FOLDER}

create a backup
if [ -z "$ADMIN_PASSWORD" ]
then
	ADMIN_PASSWORD="admin"
fi

curl -X POST \
	-d "master_pwd=${ADMIN_PASSWORD}&name=${ODOO_DATABASE}&backup_format=zip" \
	-o ${BACKUP_DIR}/${ODOO_DATABASE}.${CURRENT_DATE}.zip \
	${URL}/web/database/backup

# delete old backups
find ${BACKUP_DIR} -type f -mtime +3 -name "${ODOO_DATABASE}.*.zip" -delete
find ${BACKUP_DIR} -type f -mtime +3 -name "custom_addons.*.tar.gz" -delete
