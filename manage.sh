#! /usr/bin/env bash

list_out()
{
    
    if [[ ! $1 =~ -([dar]{1})$ ]] 
    then 
        return 1
    fi
        
    if [[ $1 == "-d" ]]
    then
        local typeD="enabled"
        local operationNeed="disable"
    elif [[ $1 == "-a" ]] 
    then
        local typeD="available"
        local operationNeed="enable"
    else 
        local typeD="available"
        local operationNeed="remove"
    fi  
    
    listArr=($(ls /etc/nginx/sites-$typeD))
    
    if [ ${#listArr[*]} -eq 0 ] 
    then
        echo "$typeD sites not found"
        exit
    fi
    
    printf "Enter number between 0 and %d for $operationNeed or type 'N' for break:\n\n"  $((${#listArr[@]}-1))
    
    for i in ${!listArr[*]}
    do
        printf "%4d) %s\n" $i ${listArr[$i]}
    done
    
    printf "\n"
    
    siteNum=-1

    while [[ ! $siteNum -ge 0 ]] || [[ ! $siteNum -lt ${#listArr[@]} ]] && [[ $siteNum != [nN] ]]
    do
        read  siteNum
    done
    
    if [[ $siteNum == [nN] ]]
    then
        echo "Task cancelled"
        exit
    fi
}

s_disable()
{   
    
    local siteLn="/etc/nginx/sites-enabled/${listArr[$siteNum]}"
    
    if [ -L $siteLn ] 
    then        
        sudo rm $siteLn
        sudo service nginx reload
        printf "\n%s\n%s\n\n" "Success!" "Site ${listArr[$siteNum]} disabled"
    else
        printf "\n%s\n%s\n\n" "Operation failed." "File $siteLn not found"
    fi
}

s_enable()
{
    
    local siteFile="/etc/nginx/sites-available/${listArr[$siteNum]}"
    
    local listLn=($(ls /etc/nginx/sites-enabled))
    
    if [ ! ${#listLn[*]} -eq 0 ] 
    then
        for lnk in ${listLn[@]}
        do
            if [ -L "/etc/nginx/sites-enabled/$lnk" ]
            then
                lnkArr=($(file "/etc/nginx/sites-enabled/$lnk" |  sed "s/ /\n\0/g"))
                lnkTo=${lnkArr[@]:(-1)}
                if [ $lnkTo == $siteFile ] 
                then 
                    echo "Site ${listArr[$siteNum]} already enabled"
                    exit
                fi
            fi
        done
    fi
    
    sudo ln -s "/etc/nginx/sites-available/${listArr[$siteNum]}" "/etc/nginx/sites-enabled/${listArr[$siteNum]}"
    sudo service nginx reload
    printf "\n%s\n%s\n\n" "Success!" "Site ${listArr[$siteNum]} enabled"        
} 

s_remove()
{
    nl=$(echo $'\n.')
    nl=${nl%.}
    read -n 1 -s -r -p "${nl}WARNING! This action cannot be undone. Type 'Y' for continue or any key for cancel$nl" confirm_k

    if [[ $confirm_k != [yY] ]]
    then
        echo "Operation cancelled"
        exit
    fi
       
    siteFile="/etc/nginx/sites-available/${listArr[$siteNum]}"

    
    listLn=($(ls /etc/nginx/sites-enabled))
    
    if [ ! ${#listLn[*]} -eq 0 ] 
    then
        for lnk in ${listLn[@]}
        do
            if [ -L "/etc/nginx/sites-enabled/$lnk" ]
            then
                lnkArr=($(file "/etc/nginx/sites-enabled/$lnk" |  sed "s/ /\n\0/g"))
                lnkTo=${lnkArr[@]:(-1)}
                if [ $lnkTo == $siteFile ] 
                then 
                    printf "\n%s\n" "Found link to ${listArr[$siteNum]} ${lnkTo}"
                    #sudo rm ${lnkTo}
                fi
            fi
        done
    fi

    #sudo rm ${siteFile}
    #sudo service nginx restart
    #printf "\n%s\n" "Site "
    
}


list_out $1

case $1 in
-d) s_disable;; 
-a) s_enable;;
-r) s_remove;;
-b) s_db;;
*) echo "$1 is not a correct option";;
esac
