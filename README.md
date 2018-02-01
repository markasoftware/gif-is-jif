# Deprecated

Gif is jif is deprecated. Use [AnyPaste](https://anypaste.xyz) ([GitHub link](https://github.com/markasoftware/anypaste)) instead.

# Gif is Jif

Gif is Jif is a simple command-line uploader for Gfycat. Yay!

## How to use?

just run `upload.bash` with the filename to upload as an argument. It'll do the rest.
You'll probably want to mark the script as executable and add it to the $PATH for easier usage.

### Example usage:

```
bash upload.bash /home/markasoftware/gifs/here-comes-dat-boi.gif
bash upload.bash /home/markasoftware/webms/spooky-doot.webm
```

## Does it work on macOS?

It uses some GNU extensions on grep and readlink (I think). So, unless you switch to GNU coreutils, it 
probably won't work.
