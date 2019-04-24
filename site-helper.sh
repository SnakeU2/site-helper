#! /usr/bin/env bash

caption="
//////////////////////
// SITE-HELPER
//////////////////////
" 

helpMessage="
Usage: site-helper OPTION
    Options:
    -l List available sites
    -e List enabled sites
    -c Create site
    -d Disable site
    -a Enable site
    -r Remove site
    -m Manage site (open site config in Nano editor)
    -b Create MySQL database
    -w Install last WordPress to site. Create new one if site name is empty or not in available 
"

echo "$caption";


case "$1" in

-l) echo "
Available sites :
-----------------
";
    ls /etc/nginx/sites-available| xargs -n 1 -i echo "{}";
    echo " 
    ";;
-e) echo "
Enabled sites :
-----------------
";

    ls /etc/nginx/sites-enabled| xargs -n 1 -i echo "{}";
    echo " 
    ";;
-c) ./create.sh;;
-d) ./manage.sh -d;;
-a) ./manage.sh -a;;
-r) ./manage.sh -r;;
-m) ./manage.sh -m;;
-b) ./db.sh;;
-w) ./wp.sh;;
*)  echo "$helpMessage";;
esac
