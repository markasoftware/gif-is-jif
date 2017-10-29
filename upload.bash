#!/bin/bash

abs_path=$(readlink -f "$1");
if [[ ! -r "$abs_path" ]]
then
    echo "The file at $1 either does not exist or you don't have read permissions for it."
    exit 1
fi
echo "Getting gfycat key and name..."
gfycat_name=$(curl -s -XPOST https://api.gfycat.com/v1/gfycats | grep -oP 'gfyname":"[a-zA-Z]+"' | cut -d '"' -f 3)
cp "$abs_path" "/tmp/$gfycat_name"
echo "About to upload. This might take a while."
upload_res=$(curl https://filedrop.gfycat.com --upload-file "/tmp/$gfycat_name")
echo "Upload complete. Waiting for remote encoding to complete..."
echo "Uploaded as https://gfycat.com/${gfycat_name}"
echo '(this might take a while)'
sleep 2
completed=''
while [[ -z "$completed" ]]
do
    check_res=$(curl -s https://api.gfycat.com/v1/gfycats/fetch/status/$gfycat_name)
    completed=$(grep -o 'complete' <<< "$check_res")
    sleep 5
done
echo 'Encoding complete.'
grep -F '"md5Found":1' <<< "$check_res" > /dev/null
if [[ $? == 0 ]]
then
    echo 'It looks like somebody else has uploaded this gif/video before!'
    echo 'The given link will be to the already uploaded one.'
fi
gfy_name_from_fetch=$(grep -oP 'gfyname":"[a-zA-Z]+"' <<< "$check_res" | cut -d '"' -f 3)
echo "Your gif/video should be at https://gfycat.com/$gfy_name_from_fetch"
echo 'Have a nice day!'
exit
