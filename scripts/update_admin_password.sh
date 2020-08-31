#!/bin/bash
python3 -m pip install passlib


host='',
database=''
username=''
password=''
port=''

while  { [ -z "$database" ] || [ -z "$username" ] || [ -z "$password" ]; } do
	echo
	echo "Enter database information, (*) is required value:"
	read -p "Host (localhost): " host
	read -p "Database name(*): " database
	read -p "Username(*): " username
	read -sp "Password(*): " password
	echo
	read -p "Port (5432): " port
	host=${host:-localhost}
	port=${port:-5432}
done

hashed_password=$(python3 -c """
from passlib.context import CryptContext
setpw = CryptContext(schemes=['pbkdf2_sha512'])
print(setpw.hash('admin'))
""")

output=`PGPASSWORD=$password psql -U $username -p $port -h $host -d $database -w -c """
	UPDATE res_users SET password='$hashed_password', login='admin' WHERE id=2;
"""`

if [ "$output" = "UPDATE 1" ]
then
	echo 'Updated password successful, username/password is: '
	echo "**********************"
	echo 'admin/admin'
	echo "**********************"
fi
