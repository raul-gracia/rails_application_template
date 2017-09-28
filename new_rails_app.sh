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
echo "Executing rails new $APPNAME -T -d postgresql -m https://raw.githubusercontent.com/raul-gracia/rails_application_template/master/template.rb"
rails new $APPNAME -T -d postgresql -m https://raw.githubusercontent.com/raul-gracia/rails_application_template/master/template.rb
