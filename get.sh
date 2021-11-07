get() {
    local pacoIP="10.x.y.z"
    local pacoPort=9002
    options=("YourService1" "YourService2" "YourService3")
    select opt in "${options[@]}"; do
        S=$opt

        echo -n "P: "
        read -s P
        echo
        echo
        echo "sp:$S,$P" | ncat --ssl $pacoIP $pacoPort 2>&1
        echo "===="
        #echo -n "|"
        timeout 5 echo `ncat --ssl -lnp $pacoPort 2>&1` | xclip -sel clip && echo "|OK|"
        echo "===="
        echo
        break
    done
 }
