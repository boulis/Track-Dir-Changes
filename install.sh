#! /bin/bash

# check if Python is there , grep -q means quite 
if which python | grep -q 'python'; then

    # check if the version is right. Notice we redirect stderr to stdout, because python outputs in stderr
    if python --version 2>&1 | grep -q '2.7'; then
        echo 'Python 2.7 found in the system.'
    else 
        echo 'A version of Python other than 2.7 was found in the system. Track-Dir-Change might not work (but try it)'
    fi

    if which python | grep -q '/usr/bin/python'; then
        echo 'Python found at the expected location.'
    else
        echo 'Python found in different location than expected, updating the script...'
        sed -i '' s%/usr/bin/python%`which python`% trackDirFileChanges.py
    fi
else
    echo 'Python not found. Install Python 2.7 and try again'; exit 
fi

# substitute HOMEDIR with the current dir in the plist template. 
# Use % instead of the usual / because the directory path contains /
# also create a new file, do not substitute infile
sed s%HOMEDIR%`pwd`%g net.boulis.TrackDir.plist.template > net.boulis.TrackDir.plist

# substitute TRACKEDDIR infile with the first argument to the install script
sed -i '' s%TRACKEDDIR%$1%g net.boulis.TrackDir.plist

echo 'Created plist file from template.' 

# check if an older agent is there
if [ -f ~/Library/LaunchAgents/net.boulis.TrackDir.plist ]; then
    echo "Older plist file found, trying to stop and unload old agent."
    launchctl stop net.boulis.TrackDir
    launchctl unload ~/Library/LaunchAgents/net.boulis.TrackDir.plist
    rm ~/Library/LaunchAgents/net.boulis.TrackDir.plist
fi

# move the newly created plist file in the right location, so that the agent can start automatically at bootup. 
mv net.boulis.TrackDir.plist ~/Library/LaunchAgents/

# launch the agent
launchctl load ~/Library/LaunchAgents/net.boulis.TrackDir.plist
echo 'New agent loaded and launched.'