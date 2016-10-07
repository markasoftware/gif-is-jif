#!/bin/bash

ABS_PATH=$(readlink -f $1);
if [[ ! -r $ABS_PATH ]]; then
    echo "The file at $1 either does not exist or you don't have read permissions for it.";
    exit 1;
fi;
echo "Getting gfycat key and name...";
GFYCAT_NAME=$(curl -v -XPOST https://api.gfycat.com/v1/gfycats 2> /dev/null | grep -oP "name\":\"[a-zA-Z]*\"" | cut -c 8- | rev | cut -c 2- | rev);
cp $ABS_PATH /tmp/$GFYCAT_NAME;
echo "About to upload. This might take a while.";
echo "There will be no indication of progress until it's complete.";
curl -i https://filedrop.gfycat.com --upload-file /tmp/$GFYCAT_NAME 2> /dev/null > /dev/null;
echo "Upload complete. Your gif will be at https://gfycat.com/$GFYCAT_NAME";
echo "It won't show up yet because Gfycat takes a couple minutes to process the gif";
exit;
