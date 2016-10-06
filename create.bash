#!/bin/bash

# Uploads the file at $VID_PATH to gfycat
gfycatupload () {
    echo "Getting gfycat key and name...";
    [[ $(curl -v -XPOST https://api.gfycat.com/v1/gfycats 2> /dev/null) =~ name\":\"[a-zA-Z]*\" ]];
    GFYCAT_NAME=$(echo $BASH_REMATCH | cut -c 8- | rev | cut -c 2- | rev);
    mv $OUT_PATH /tmp/$GFYCAT_NAME;
    echo "About to upload. This might take a while.";
    echo "There will be no indication of progress until it's complete.";
    curl -i https://filedrop.gfycat.com --upload-file /tmp/$GFYCAT_NAME 2> /dev/null;
    echo "Upload complete. Your gif will be at gfycat.com/$GFYCAT_NAME";
    echo "It won't show up yet because Gfycat takes a couple minutes to process the gif";
    echo "Thank you for using Gif Creator!";
    exit;
}

# Run ffmpeg -h and check exit code to verify it's installed
ffmpeg -h > /dev/null 2> /dev/null;
if [ $? != 0 ]; then
    echo "ffmpeg was not detected. Please install it then try again.";
    exit 1;
fi

echo "Welcome to Gif Creator! Please enter the full path of the video
you wish to convert, then hit enter:"
read VID_PATH;

# verify file exists
if [ ! -f $VID_PATH ]; then
    echo "There is no file at $VID_PATH, please run this script again with a valid path";
    exit 1;
fi

# verify file has read permissions
if [ ! -r $VID_PATH ]; then
    echo "The file at $VID_PATH is not readable, make sure your user has permission to read it.";
    exit 1;
fi

echo "Verifying if video is valid..."
ffmpeg -v quiet -i $VID_PATH -f null -
if [ $? != 0 ]; then
    echo "ffmpeg says the $VID_PATH is not a valid video.";
    exit 1;
fi
echo "Video validity confirmed"
echo "";

# run ffmpeg to get basic info, grab duration line and cut to get duration, then remove : and leading 0s
VID_DURATION=$(ffmpeg -i $VID_PATH 2>&1 | grep Duration | cut -c13-20 | sed "s/://g" | sed "s/^0*//")
if [[ VID_DURATION -lt 15 ]]; then
    echo "Your video is shorter than 15 seconds. Gfycat allows you to use the webm format instead of the gif format for video this short."
    echo "";
    echo "Generally speaking, a webm is better than a gif because it allows higher quality in a smaller file";
    echo "";
    echo "However, imgur, which usually has higher quality than gfycat, only supports .gif";
    WEBM_OR_GIF="h";
    while [[ ($WEBM_OR_GIF != "webm") && ($WEBM_OR_GIF != "gif") ]]; do
        echo "";
        echo "So, do you want a webm or gif? Please type either webm or gif then hit enter.";
        read WEBM_OR_GIF;
    done;
    if [[ $WEBM_OR_GIF == "webm" ]]; then
        echo "";
        echo "I'll use a 6M/S bitrate by default.";
        echo "This should generate very high quality webms most of the time";
        echo "If you would like to override it, enter a number of M/S then hit enter";
        echo "If you are fine with the default value, just hit enter without typing anything";
        read OUT_BITRATE;
        if [[ ${#OUT_BITRATE} == 0 ]]; then
            # idk if i need this to be a string
            OUT_BITRATE="6";
        fi
        OUT_BITRATE=$(($OUT_BITRATE + 0));
        echo "Ok, using a bitrate of $OUT_BITRATE M/S";
        echo "";
        echo "Would you like to upload to Gfycat or save locally?";
        UPLOAD_OR_LOCAL='';
        while [[ ($UPLOAD_OR_LOCAL != 'upload') && ($UPLOAD_OR_LOCAL != 'local') ]]; do
            echo "Enter upload or local then hit enter:";
            read UPLOAD_OR_LOCAL;
        done;
        if [[ $UPLOAD_OR_LOCAL == 'upload' ]]; then
            # this somehow generates 5 random letters
            OUT_PATH="/tmp/$(cat /dev/urandom | tr -dc "a-z" | fold -w 6 | head -n 1).webm";
        else
            echo "Please enter the full path to where you want to save the webm";
            echo "Include .webm on the end, and hit enter when done";
            read OUT_PATH;
            while [[ $(echo $OUT_PATH | grep '.webm$' | wc -l) != 1 ]] || ! touch $OUT_PATH 2> /dev/null; do
                echo "Enter a valid path which you have write permission and ends in .webm:";
                read OUT_PATH;
            done;
        fi
        echo "About to start encoding...";
        ffmpeg -i "$VID_PATH" -c:v libvpx -crf 8 -b:v ${OUT_BITRATE}M "$OUT_PATH";
        if [[ $? != 0 ]]; then
            echo "";
            echo "There was an error during encoding";
            exit 1;
        fi
        echo "";
        echo "Encoding completed successfully"
        if [[ $UPLOAD_OR_LOCAL == 'local' ]]; then
            exit;
        fi;
        gfycatupload;
        exit;
    fi;
fi;

echo "Your video"
