# Files and Path handling
# Routines for handling files and paths


# Checks if a given directory exists.
# OUTPUT: 1 if exists  0 if not.
#https://linuxize.com/post/bash-if-else-statement/
function direxists()
{

	if [ -d $1 ]
	then
		local v=1
	 else
	   	local v=0
	fi
	echo $v
}


# OUTPUT: 1 if exists  0 if not.
function fileexists()
{
	if [ -r $1 ]
	then
		local v=1
	 else
	   	local v=0
	fi
	echo $v
}


function saythis()
{
  RED='\033[0;31m'
  PURPLE='\033[0;35m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  BLUE='\033[0;34m'
  YELLOW='\033[0;33m'
  NC='\033[0m' # No Color	

if [ $2 = "error" ]; then
  color=$PURPLE
elif [ $2 = "warn" ]; then 
  color=$YELLOW 
elif [ $2 = "msg" ]; then 
  color=$BLUE
elif [ $2 = "success" ]; then 
  color=$GREEN
 else
   color=$NC
fi

  echo ""
  printf " ${CYAN}Message from: $0 ${NC}"
  echo ""
  printf " ${color}$1 ${NC}"
  echo ""
  echo ""
}

#Creates a timestamp of right now. 
function rightnow()
{
  local v=$(date +%Y%m%d-%I%M%S)
  printf $v

}
