#!/bin/bash

service_url='http://localhost:9000'
odoo_service_name="kmv_dev"
db_host="127.0.0.1"
db_user="kmv" # this user must have a superuser to read list database from psql
db_passwd="kmv"
odoo_config_file="/home/xmars/dev/odoo/conf/kmv_dev.conf"

# you need run this file with sudo permission
# ==============================================================
# ==========  $ sudo /bin/bash <path_to_file> ==================
# ==============================================================


# execute query to select list database with owner is $db_user (psql query with password in one line)
databases=`psql "postgresql://$db_user:$db_passwd@$db_host/postgres" -c "SELECT datname FROM pg_database JOIN pg_authid ON pg_database.datdba=pg_authid.oid WHERE rolname='$db_user'"`

# remove string from character '(' to the end of the string
databases=`echo $databases | cut -f1 -d "("`

# remove from character "-" to the start of the string
databases=`echo $databases | sed 's/.*-//'`

# split string to array named $list_db
IFS=' ' read -r -a list_db <<< "$databases"
for db in "${list_db[@]}"
do
	db_name="db_name = $db"
	
	# remove all empty lines in config file
	sed -i '/^$/d' $odoo_config_file
	
	# replace parameter db_name in config file with appropriate database name
	if grep -q "db_name" "$odoo_config_file"; 
	then
		sed -i "s/.*db_name.*/$db_name/" $odoo_config_file
	else
		# if config file don't have db_name param, add it to the end of the file
		echo "" >> $odoo_config_file
		echo $db_name >> $odoo_config_file
	fi
	service $odoo_service_name restart
	attempt_counter=0
	max_attempts=5

	until $(curl --output /dev/null --silent --head --fail "${service_url}"); do
	    if [ ${attempt_counter} -eq ${max_attempts} ];then
	      echo "Max attempts reached"
	      exit 1
	    fi

	    printf '.'
	    attempt_counter=$(($attempt_counter+1))
	    sleep 5
	done
	
done

# remove option db_name to load full databases
sed -i "s/.*db_name.*//" $odoo_config_file
service $odoo_service_name restart
