#!bin/bash

function mywhich ()
{

    local command="$1"

    if [  "$command" =  "" ] ; then
        return
    fi

    local mypath=$(which $command 2>/dev/null)

    if [  "$mypath" =  "" ];then
        echo "Command $command not found" > /dev/null
        echo "NOT_FOUND"

    elif [ ! -x "$mypath" ] ; then
        echo "Command $command not executable" > /dev/null
        echo "NOT_FOUND"
    else
        echo "$mypath"
    fi

}

function findCmds
{
        
       TRACEROUTE=$(mywhich traceroute   ) # Network
            SAR=$(mywhich sar            ) # Packages
              YUM=$(mywhich yum          ) # Packages
	         LVS=$(mywhich vgdisplay     ) # H/W Info       
            CAT=$(mywhich cat            ) #standard commands      
                GREP=$(mywhich grep      )
                 AWK=$(mywhich awk       )                  
                HEAD=$(mywhich head      )               
}

#rpm -qa sysstat
#yum info sysstat | egrep "(^Version|^Release|^Repo)"

function OsCheck
{

    # OS : Ubuntu / CentOS
    if [ -f /etc/os-release ]; then
       OS_CHK=$($CAT /etc/os-release | $GREP NAME | $HEAD -n 1 | $AWK -F "\"" '{print $2}' | $AWK '{print $1}')
    elif [ -f /etc/centos-release ]; then
       OS_CHK=$($CAT /etc/centos-release | $AWK '{print $1}')
    else
       OS_CHK="Unknown OS"
    fi
}

function PkgCheck {
    if [ "$OS_CHK" == "CentOS" ]; then
       if [ "$TRACEROUTE" == "NOT_FOUND" ]; then
           $YUM install traceroute -y > /dev/null 2>&1
           echo "  1. traceroute installation complete"
           #TRACEROUTE=$(mywhich traceroute)
       else
           echo "  1. traceroute found"

       fi

       if [ "$SAR" == "NOT_FOUND" ]; then
            $YUM install sysstat -y > /dev/null 2>&1
            echo "  3. sysstat installation complete"
            # SAR=$(mywhich sar)
            # PIDSTAT=$(mywhich pidstat)
            # MPSTAT=$(mywhich mpstat)
        else
            echo "  3. sysstat found"
         fi
       if [ "$LVS" == "NOT_FOUND" ]; then
            $YUM install lvm2 -y > /dev/null 2>&1
            echo "  3. lvm2 installation complete"
        else
            echo "  3. lvm2 found"
         fi
    else
        echo "  1. I have found all the packages for checking the status of the network"
    fi
    echo
}

findCmds

# Check OS type
OsCheck
echo "Check OS type : $OS_CHK"

# System Package Check
PkgCheck

## sysstat config
sed -i.bak "s/\*\/10 \* \* \* \* root \/usr\/lib64\/sa\/sa1 1 1/\*\/1 \* \* \* \* root \/usr\/lib64\/sa\/sa1 1 1/g" /etc/cron.d/sysstat ;
# sed -i "s/HISTORY\=7/HISTORY\=28/g" /etc/sysconfig/sysstat ;
