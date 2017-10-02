#!/bin/sh
RAILS="$(gem list -i rails -v '~>5')"
COLORIZE="$(gem list -i colorize)"
TEMPLATE_PATH="https://raw.githubusercontent.com/raul-gracia/rails_application_template/master/template.rb"

if [ "$RAILS" == "false" ]; then
  echo "Please make sure to have rails version 5 or above"
  exit
fi

if [ "$COLORIZE" == "false" ]; then
  echo "Please make sure to have the colorize gem installed"
  exit
fi

read -p "What's the name of the new app? " APPNAME
read -p "Do you need react js support? (y/N) " REACTJS

if [ "$REACTJS" == "Y" ] || [ "$REACTJS" == "y" ] || [ "$REACTJS" == "yes" ] || [ "$REACTJS" == "YES" ]; then
  echo "Executing rails new $APPNAME -T -d postgresql --webpack=react -m $TEMPLATE_PATH"
  rails new $APPNAME -T -d postgresql --webpack=react -m $TEMPLATE_PATH
else
  echo "Executing rails new $APPNAME -T -d postgresql -m $TEMPLATE_PATH"
  rails new $APPNAME -T -d postgresql -m $TEMPLATE_PATH
fi
