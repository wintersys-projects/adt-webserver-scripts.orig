#!/bin/sh
##################################################################################
# Description: This script will update update the database credentials for joomla
# Author: Peter Winter
# Date: 05/01/2017
##################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#################################################################################
#################################################################################
#set -x

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh BUILDARCHIVECHOICE:virgin`" = "1" ] )
then
	exit
fi

if ( [ ! -f ${HOME}/runtime/CONFIG_PRIMED ] && [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh configuration.php.default`" = "" ] )
then
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh /var/www/html/configuration.php.default
	if ( [ "$?" = "0" ] )
 	then
  		/bin/touch ${HOME}/runtime/CONFIG_PRIMED
	fi
fi

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh joomla_configuration.php`" != "" ] )
then
	/bin/sleep 5
	
	${HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh joomla_configuration.php ${HOME}/runtime/joomla_configuration.php.$$

	if ( [ "`/usr/bin/diff ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php`" != "" ] )
	then
		/bin/mv ${HOME}/runtime/joomla_configuration.php.$$ /var/www/html/configuration.php
		/bin/cp /var/www/html/configuration.php ${HOME}/runtime/joomla_configuration.php
		/bin/chown www-data:www-data /var/www/html/configuration.php
		/bin/chmod 600 /var/www/html/configuration.php
	else
		/bin/rm ${HOME}/runtime/joomla_configuration.php.$$
	fi
fi

dbprefix="`/bin/cat /var/www/html/dbp.dat`"
if ( [ "${dbprefix}" = "" ] )
then
	dbprefix="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh DBPREFIX:*`"
fi

secret="`${HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${secret}" = "" ] )
then
	secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
	${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh SECRET:${secret}    
fi

if ( [ ! -d /var/www/html/tmp ] )
then
	/bin/mkdir -p /var/www/html/tmp
 	/bin/chown www-data:www-data /var/www/html/tmp
   	/bin/chmod 750 /var/www/html/tmp

fi

if ( [ ! -d /var/www/html/logs ] )
then
	/bin/mkdir -p /var/www/html/logs
  	/bin/chown www-data:www-data /var/www/html/logs
      	/bin/chmod 750 /var/www/html/logs
fi

if ( [ ! -d /var/www/html/cache ] )
then
	/bin/mkdir -p /var/www/html/cache
  	/bin/chown www-data:www-data /var/www/html/cache
   	/bin/chmod 750 /var/www/html/cache
fi

if ( [ -f /var/www/html/cli/garbagecron.php ] )
then
	/usr/bin/php /var/www/html/cli/garbagecron.php
elif ( [ -f /var/www/html/cli/joomla.php ] )
	/usr/bin/php /var/www/html/cli/joomla.php cache:clean
fi
