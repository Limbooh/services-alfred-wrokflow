#! /bin/sh

SERVICES=""

if [[ "$1" != "" ]]; then
  if [[ "$1" == "Null" ]]; then
    exit
  fi
  SERVICES=`cat supported-services.dat | grep '^[^#].*' | grep $1`
else
 SERVICES=`cat supported-services.dat | grep '^[^#].*'`
fi

items=()
echo  "<?xml version='1.0'?>\n<items>"
while read -r line; do
  SERVICE=(${line// / })
  echo "<item uid='${SERVICE[0]}' valid='yes' autocomplete='${SERVICE[0]}' arg='${SERVICE[0]} $2'><title>${SERVICE[0]}</title><subtitle>${SERVICE[1]}</subtitle></item>"
done <<< "$SERVICES"
echo "</items>"
