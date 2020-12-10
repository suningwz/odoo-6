#!/bin/bash
# *************************** Instruction - step by step ******************************
# 0. Pull code to custom add-ons folder (if it is git folder)
# 1. Get list databases
# 2. Get list custom add-ons
# 3. Append update list add-ons option to the service file
# 4. Reload system service info
# 5. Loop on list databases
#   5.1. Add database option to the config file
#   5.2. Restart service
# 6. Remove update list add-ons option from service file
# 7. Remove database option from the config file
# ************************************************************************************
# *********************************** Notes ******************************************
# You need run this file with sudo permission
# ==========  $ sudo /bin/bash <path_to_file> ==================
# ==============================================================

service_url='http://localhost:9000'
odoo_service_name="kmv_dev"
db_host="127.0.0.1"
db_user="kmv" # this user must have a superuser to read list database from psql
db_passwd="kmv"
odoo_service_file="/etc/systemd/system/odoo13.conf"
odoo_config_file="/home/xmars/dev/odoo/conf/kmv_dev.conf" # don't put -u option to this file
odoo_custom_addons_path="/home/xmars/dev/odoo/customaddons"
is_git_repo="yes" # custom addons folder is the git repo or not

# ==========================================================================================
# ======================= 0. Pull code to custom add-ons folder ============================
# ==========================================================================================
if [ $is_git_repo == 'yes' ]; then
  cd $odoo_custom_addons_path || return
  git config credential.helper store
  git pull
fi

# ==========================================================================================
# =============================== 1. Get list databases ====================================
# ==========================================================================================
# execute query to select list database with owner is $db_user (psql query with password in one line)
databases=$(psql "postgresql://$db_user:$db_passwd@$db_host/postgres" -c "SELECT datname FROM pg_database JOIN pg_authid ON pg_database.datdba=pg_authid.oid WHERE rolname='$db_user'")

# remove string from character '(' to the end of the string
databases=$(echo $databases | cut -f1 -d "(")

# remove from character "-" to the start of the string
databases=$(echo $databases | sed 's/.*-//')

# =============================================================================================
# ============================== 2. Get list custom add-ons ===================================
# =============================================================================================
# ignore all hidden and implies folders (. and ..)
custom_addons=$(find . -maxdepth 1 -mindepth 1 -not -path '*/\.*' -type d -printf "%f,")

# ==============================================================================================
# ==================== 3. Append update list add-ons option to the service file ================
# ==============================================================================================
if [ -n "${custom_addons}" ]; then
  # ========== Edit config file to update list addons =================
  execute_script_line=$(grep -n 'ExecStart' "${odoo_service_file}")
  IFS=':'
  read -a execute_script_line_values <<<"$execute_script_line"
  execute_script_line_number=${execute_script_line_values[0]}
  execute_script_line_value_original=${execute_script_line_values[1]}
  execute_script_line_value_new="${execute_script_line_value_original} -u ${custom_addons}"
  # replace value of file at a specific line number
  sed -i "${execute_script_line_number}s|^.*$|$execute_script_line_value_new|" "$odoo_service_file"
fi

# ==============================================================================================
# ================================== 4. Reload system service info==============================
# ==============================================================================================
systemctl daemon-reload

# ==============================================================================================
# =================================== 5. Loop on list databases ================================
# ==============================================================================================
# split string to array named $list_db
IFS=' ' read -r -a list_db <<<"$databases"
for db in "${list_db[@]}"; do
  db_name="db_name = $db"

  # remove all empty lines in config file
  sed -i '/^$/d' $odoo_config_file

  # replace parameter db_name in config file with appropriate database name
  if grep -q "db_name" "$odoo_config_file"; then
    sed -i "s/.*db_name.*/$db_name/" $odoo_config_file
  else
    # if config file don't have db_name param, add it to the end of the file
    echo "" >>$odoo_config_file
    echo $db_name >>$odoo_config_file
  fi
  service $odoo_service_name restart
  attempt_counter=0
  max_attempts=5

  until curl --output /dev/null --silent --head --fail "${service_url}"; do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
      echo "Max attempts reached"
      exit 1
    fi

    printf '.'
    attempt_counter=$(($attempt_counter + 1))
    sleep 5
  done

done

# ==============================================================================================
# ================== 6. Remove update list add-ons option from service file ====================
# ==============================================================================================
if [ -n "${custom_addons}" ]; then
  # reverse config file to the original file
  sed -i "${execute_script_line_number}s|^.*$|$execute_script_line_value_original|" "$odoo_service_file"
  systemctl daemon-reload
fi

# ==============================================================================================
# ====================== 7. Remove database option from the config file ========================
# ==============================================================================================
# remove option db_name to load full databases
sed -i "s/.*db_name.*//" $odoo_config_file
service $odoo_service_name restart
