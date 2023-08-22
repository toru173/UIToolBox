#!/usr/bin/osascript
on run argv
    set oldFileName to POSIX file (item 1 of argv)
    set newFileName to (item 2 of argv)
    tell application "Finder"
        set name of folder oldFileName to newFileName
    end tell
end run
