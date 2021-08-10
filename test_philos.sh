#!/bin/bash

# Iterations
iter=50

# How long to wait for each iteration (sec)
waitfor=60

# Path where philo binary is
path="../philo_talyx" 
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
arg=$@
padding="                 "

trap 'rm -rf "$tempdir"; exit' SIGINT

if [ -x "$path"/philo ]
then
	tempdir=`mktemp -d`
	cp "$path"/philo "$tempdir"
else
	echo -e "\a Binary error"
	exit
fi;

printf "Doing ${YELLO}%d${NC} iterations, waiting ${YELLO}%d${NC} seconds...\n" $iter $waitfor

echo -e "<iter>	<ms>	<num>	<msg>		<status>"

for((i=0; i < iter; i++));
do
	echo -ne "[`expr $i + 1`]	"
	output=$(timeout --foreground $waitfor $tempdir/philo $@)
	line="$(tail -n 1 <<<${output})"
	# printf "% -19.19s " "$(tail -n 1 <<<${output})"
	printf "%s %s" "$line" "${padding:${#line}}"
	if grep -q "died" <<<$(tail -n 5 <<<$output)
	then
		echo -e "${LRED}	💀💀💀 Died!${NC}"
		((dead++))
		mkdir -p ./logs_philo
		printf "%s" "$output" > "./logs_philo/$$-${i}_${arg// /_}.txt"
	else
		echo -e "${LGREEN}	🤔🤔🤔 Alive...${NC}"
		((alive++))
	fi;
done

rm -rf "$tempdir"

printf "Summary: ${LRED}%d/%d${NC} 💀, ${LGREEN}%d/%d${NC} 🤔\n" $dead $iter $alive $iter

if [[ -x "$(command -v notify-send)" ]] && (( $iter * $waitfor >= 60 )) 
then
	printf -v notif "%d/%d died." $dead $iter
	notify-send "Philo test complete" "$notif"
fi;
