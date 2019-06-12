# These utilities are used in multiple
# zsh functions on my system

# Vars
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NC=$(tput sgr0)

ONLINE="${GREEN}online$NC"
OFFLINE="${RED}offline$NC"


function echoHeader () {
  echo
  echo
  printf "%40s \n" "[$RED $1 $NC]"
  # echo "> > >  $1 =========="
  echo
}

function echoSection () {
  echo
  echo
  printf "$GREEN > > > $NC %1s \n" "$YELLOW $1 $NC"
  # echo "> > >  $1 =========="
  echo
}

function checkInstalledApt () {
dpkg -s "$1" 2>/dev/null >/dev/null || sudo $APT -y install "$1"
}

function runAptUpdateIfNeeded() {
# Update APT Repos of older than 12 hours
if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -720)" ]; then
  sudo apt update
fi
}

function send-notify() {
MYTOKEN="$(bw get password b43eb18a-1806-45dc-8dfd-aa6901533182)"

THEURL="https://integram.org/webhook/$MYTOKEN"

MYMSG="$1"

PAYLOAD=$(printf "{\"text\":\"%s\"}" "$MYMSG")



# Check if Bitwarden is logged in.
if [[ -z "${BW_SESSION}" ]]; then
  echo "W_SESSION is undefined - Likely need to login to BW CLI or set the export"
else
curl -X POST -H "Content-Type: application/json" --data "$PAYLOAD" $THEURL


fi
}