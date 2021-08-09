#!/bin/bash

# Iterations
iter=50

# How long to wait for each iteration (sec)
waitfor=60

# Path where philo binary is
path="." 
# path="/home/roman/work/2_ecole/github/philosophers/philo"


#colors
RED="\e[31m"
LGREEN="\e[1;32m"
LRED="\e[1;31m"
YELLO="\e[1;33m"
NC="\e[0m"

avg=0
dead=0
alive=0
printf "Doing ${YELLO}%d${NC} iterations, waiting ${YELLO}%d${NC} seconds...\n" $iter $waitfor
echo -e "<iter>	<ms>	<num>	<msg>		<status>"
for((i=0; i < iter; i++));
do
	echo -ne "[`expr $i + 1`]	"
	output=$(timeout $waitfor $path/philo $@)
	# echo -ne "$(tail -n 1 <<<${output})"
	printf "% -19.19s " "$(tail -n 1 <<<${output})"
	if grep -q "died" <<<$(tail -n 5 <<<$output)
	then
		echo -e "${LRED}	💀💀💀 Died!${NC}"
		((dead++))
	else
		echo -e "${LGREEN}	🤔🤔🤔 Alive...${NC}"
		((alive++))
	fi;
done
printf "Summary: ${LRED}%d/%d${NC} 💀, ${LGREEN}%d/%d${NC} 🤔\n" $dead $iter $alive $iter
notif=""
if [ -x "$(command -v notify-send)" ]
then
	printf -v notif "%d/%d died." $dead $iter
	notify-send "Philo test complete" "$notif"
fi;