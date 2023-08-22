#!/bin/bash
if [ -z "$1" ]
  then
    echo "Usage: createplist.sh PATH_TO_PLIST"
    exit 1
fi

cat > "$1" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
EOF
