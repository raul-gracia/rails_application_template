#!/usr/bin/ruby
rails = `gem list -i rails -v '~>5'`.strip
colorize = `gem list -i colorize`.strip
template_path = 'https://raw.githubusercontent.com/raul-gracia/rails_application_template/master/template.rb'
# template_path = '/Users/maliciousmind/Dropbox/Development/rails_application_template/template.rb'

if rails == 'false'
  puts 'Please make sure to have rails version 5 or above'
  exit
end

if colorize == 'false'
  puts 'Please make sure to have the colorize gem installed (ie. gem install colorize)'
  exit
end

print "What's the name of the new app? "
app_name = gets.chomp

command = "rails new #{app_name} -B -T -d postgresql -m #{template_path}"

puts "Executing #{command}"
exec command
