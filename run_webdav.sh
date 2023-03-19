#!/bin/bash -eu

target=$1
path=$2
entrypoint=$3
read -p "Username: " user
read -sp "Password: " pass
echo

xpath="//*[local-name()='response' and not(.//*[local-name()='collection'])]/*[local-name()='propstat']/preceding-sibling::*[local-name()='href']/text()"
tmp=$(mktemp -d)

xml=$(curl -s -u $user:$pass -X PROPFIND $target$path)
list=$(echo $xml | sed -e "s/<?xml version=\"1.0\" encoding=\"UTF-8\"?>//g" | xmllint --xpath "$xpath" -)
serialize_path=$(echo $path | sed -e "s/\//\\\\\//g")
for item in $list; do
  cur_path=$(echo $item | sed -e "s/$serialize_path//g")
  curl -s -u $user:$pass $target$item --create-dirs -o $tmp$cur_path
done

chmod +x $tmp/$entrypoint

echo "Running $entrypoint"
(
  cd $tmp
  ./$entrypoint
)
echo "Done"

rm -r $tmp
