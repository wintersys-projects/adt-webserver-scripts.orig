#!/bin/sh
###########################################################################################################
# Description: If you are building from a snapshot this will restore the latest version of your application
# from your datastore because the snapshot you are building off (including the application code) could be
# weeks or even months old so we want our application sourcecode to be up to date
# Author: Peter Winter
# Date: 05/02/2017
###########################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

if ( [ ! -f ${HOME}/runtime/SNAPSHOT_BUILT ] || [ -f ${HOME}/runtime/APPLICATION_UPDATED_FOR_SNAPSHOT ] )
then
        exit
fi

/bin/touch ${HOME}/runtime/APPLICATION_UPDATED_FOR_SNAPSHOT

WEBSITE_URL="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITEURL'`"
WEBSITE_NAME="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'WEBSITENAME'`"
WEBSITE_SUBDOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"
DATASTORE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'DATASTORECHOICE'`"
BUILD_IDENTIFIER="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILD_IDENTIFIER'`"
BUILD_ARCHIVE_CHOICE="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDARCHIVECHOICE'`"

if ( [ -d /var/www/html ] )
then
        /bin/mkdir /var/www/html-backup.$$
        /bin/mv /var/www/html/* /var/www/html-backup.$$
else
        /bin/mkdir -p /var/www/html
fi

cd ${HOME}

application_datastore="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${BUILD_ARCHIVE_CHOICE}/applicationsourcecode.tar.gz"
${HOME}/providerscripts/datastore/GetFromDatastore.sh ${application_datastore}
/bin/tar xvfz ${HOME}/applicationsourcecode.tar.gz
/bin/rm ${HOME}/applicationsourcecode.tar.gz
/bin/mv ${HOME}/tmp/backup/* /var/www/html
/bin/rm -rf ${HOME}/tmp
/bin/chown -R www-data:www-data /var/www/* > /dev/null 2>&1
/usr/bin/find /var/www -type d -exec chmod 755 {} \;
/usr/bin/find /var/www -type f -exec chmod 644 {} \;
/bin/chmod 755 /var/www/html
/bin/chown www-data:www-data /var/www/html


