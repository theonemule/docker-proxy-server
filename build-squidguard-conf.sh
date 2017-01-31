#!/bin/bash

CONFFILE="/etc/squidguard/squidGuard.conf"
DB="/opt/blacklists/"

rm $CONFFILE
touch $CONFFILE

chown -R proxy:proxy $DB
chown -R proxy:proxy $CONFFILE
chown -R proxy:proxy /var/log/squidguard/

echo "dbhome $DB" >> $CONFFILE
echo "logdir /var/log/squidguard/" >> $CONFFILE


for CATEGORY in $(echo $BLACKLIST | sed "s/,/ /g")
do
	echo "dest $CATEGORY {" >> $CONFFILE
	
	if [ -e "$DB/$CATEGORY/domains" ]
	then
		    echo "	domainlist $CATEGORY/domains" >> $CONFFILE
	fi
	
	if [ -e "$DB/$CATEGORY/urls" ]
	then
		    echo "	urllist $CATEGORY/urls" >> $CONFFILE
	fi
	
	if [ -e "$DB/$CATEGORY/expressions" ]
	then
		echo "	expressionlist $CATEGORY/expressions" >> $CONFFILE
	fi

    echo "}" >> $CONFFILE
done

NOT_LIST="${BLACKLIST//,/ !}"

echo "acl {" >> $CONFFILE
echo "	default {" >> $CONFFILE
echo "		pass !$NOT_LIST all" >> $CONFFILE
echo "		redirect http://$IP_OR_HOSTNAME/block.html" >> $CONFFILE
echo "	}" >> $CONFFILE
echo "}" >> $CONFFILE

squidGuard -b -C all

chown -R proxy:proxy $DB
chown -R proxy:proxy $CONFFILE
chown -R proxy:proxy /var/log/squidguard/
chown -R www-data:www-data /var/www/html/

exit 0
