#!/bin/bash

BACKUP_DIR=/root/kmv_backup
ADDONS_FOLDER=/root/kmv/custom_addons
ODOO_DATABASE=kmv
ADMIN_PASSWORD=3c6Sy2ykwOSoIeIbjSOo
URL=http://118.68.168.228
CURRENT_DATE=`date +%d%m%Y`


# create a backup directory for database and addons file
mkdir -p ${BACKUP_DIR}
tar czfP ${BACKUP_DIR}/custom_addons.${CURRENT_DATE}.tar.gz ${ADDONS_FOLDER}

# create a backup
curl -X POST \
	-F "master_pwd=${ADMIN_PASSWORD}" \
	-F "name=${ODOO_DATABASE}" \
	-F "backup_format=zip" \
	-o ${BACKUP_DIR}/${ODOO_DATABASE}.${CURRENT_DATE}.zip \
	${URL}/web/database/backup

# delete old backups
find ${BACKUP_DIR} -type f -mtime +3 -name "${ODOO_DATABASE}.*.zip" -delete
find ${BACKUP_DIR} -type f -mtime +3 -name "custom_addons.*.tar.gz" -delete
