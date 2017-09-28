#!/bin/sh
RAILS="$(gem list -i rails -v '~>5')"
COLORIZE="$(gem list -i colorize)"

if [ "$RAILS" == "false" ]; then
  echo "Please make sure to have rails version 5 or above"
  exit
fi

if [ "$COLORIZE" == "false" ]; then
  echo "Please make sure to have the colorize gem installed"
  exit
fi

read -p "What's the name of the new app? " APPNAME
NEW_COMMAND="rails new $APPNAME -T -d postgresql -m template.rb"
echo "Executing $NEW_COMMAND"

rails new $APPNAME -T -d postgresql -m template.rb
