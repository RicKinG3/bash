#!/bin/bash

trap "tput reset; exit 0" 1 2 3 6 9 10 11 15

TREE="\033[s
           *
          .^.
         .-o-.
        .-.0'-.
       .-oO.Y'-.
      .-0*'O}{ 0.
     .- Y  X .Y'-.
    .- J O.0' * o-.
   .-TY*-' o 0YO  -.
  .-.0'.-.Y-.O.Y.*Y-.
  _*OYo *|~~~|   (\(\\
 / /\\\\\\V \''0''/ =(*.*)=
 \_|_|A  \___/   (v v) \033[u"
while true; do
    for i in `seq 1 7`; do

        color=$((30+$i))

        case $i in
            1)  ball="\*";;
            2)  ball="o";;
            3)  ball="Y";;
            4)  ball="O";;
            5)  ball="0";;
            6)  ball="\.";;
            7)  ball="\-";;
        esac

        tput reset
        echo -en "$TREE" | sed "s:$ball:`echo -en "\033[${color}m$ball\033[0m"`:g"
        sleep 0.3
 done
done