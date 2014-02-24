#!/bin/bash

<<COMMENT
	Author: Ricardo A. Walter <ricardoa.walter@gmail.com>
	Last update: 24/02/2014 16:24
	
	HOW TO:
	1. Extract Cpanel backup file:
		tar -xvf backup-2.24.2014_13-39-35_youraccount.tar.gz
		
	2. Open extracted folder
		cd backup-2.24.2014_13-39-35_youraccount
		
	3. Copy this file
		cp /your-location/import-db.bash ./
		
	4. Adjust this vars
	5. Run it!
	
COMMENT


# DB Settings
DB_USER="root"
DB_PASS="123456"
DB_ISPCONFIG="ispconfig"

# ISP Config settings
ISP_USER_ID=1
ISP_GROUP_ID=2

ISP_SERVER_ID=1
ISP_PARENT_DOMAIN_ID=2



DBS=$(cd mysql; find ./ -iname "*_*.create" | cut -c 3-9999 | sed 's/.create//' )

echo "#> Importing Databases"
for db in $DBS
do
	echo "> Importing $db"
	mysql -u $DB_USER -p$DB_PASS < mysql/$db.create
	mysql -u $DB_USER -p$DB_PASS $db < mysql/$db.sql
	echo "INSERT INTO web_database(
			sys_userid,
			sys_groupid,
			sys_perm_user,
			sys_perm_group,
			server_id,
			parent_domain_id,
			type,
			database_name,
			remote_access,
			active
		) VALUES (
			'$ISP_USER_ID',
			'$ISP_GROUP_ID',
			'riud',
			'riud',
			'$ISP_SERVER_ID',
			'$ISP_PARENT_DOMAIN_ID',
			'mysql',
			'$db',
			'n',
			'y'
		);" | mysql -u $DB_USER -p$DB_PASS $DB_ISPCONFIG
done

echo "#> Importing privileges"
mysql -u $DB_USER -p$DB_PASS < mysql.sql
