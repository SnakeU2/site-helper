#!/usr/bin/env bash

# 1. Get info: local domain, external domain, php version 

nl=$(echo $'\n.')
nl=${nl%.}

read -p "${nl}Enter local site address:$nl"  localDomain


read -p "${nl}Enter remote site address:$nl" remoteDomain


echo "${nl}Select php version"

phps=($(ls /run/php | grep .sock))

for i in ${!phps[*]}
do
	printf "%3d: %s\n" $i ${phps[$i]}
done

read phpv
printf "\n\n"

# 2. Create nginx config file

cd ~/site-helper

cp sceleton $localDomain
sed -i "s/__localDomain__/$localDomain/g" $localDomain
sed -i "s/__remoteDomain__/$remoteDomain/g" $localDomain
sed -i "s/__phpVersion__/${phps[$phpv]}/g" $localDomain
sudo mv ${localDomain} /etc/nginx/sites-available/${localDomain}

# 3. Create symlink

sudo ln -s /etc/nginx/sites-available/${localDomain}  /etc/nginx/sites-enabled/${localDomain}

# 4. Create directories for domain

sudo mkdir /var/www/${localDomain}
sudo mkdir /var/www/${localDomain}/docs
sudo mkdir /var/www/${localDomain}/logs

sudo chown -R snake:www-data /var/www/${localDomain}
sudo chmod -R 775 /var/www/${localDomain}

echo "<?php ${nl} phpinfo();" > /var/www/${localDomain}/docs/index.php


# 5. Restart nginx

sudo service nginx reload
