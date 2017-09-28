def say_color(tag, text); say "\033[1m\033[36m" + tag.to_s.rjust(10) + "\033[0m" + "  #{text}" end
# Dependencies
begin
  require 'colorize'
rescue
  say_color('ERROR', 'Please install the colorize gem to use this template')
  exit
end
def say_info(text);    say "      " + "INFO".white.on_blue   + "  #{text.blue}" end
def say_error(text);   say "     " + "ERROR".white.on_red     + "  #{text.red}" end
def say_success(text); say "   " + "SUCCESS".white.on_green + "  #{text.green}" end

# Check for Rails Version
if Rails::VERSION::MAJOR.to_s != "5"
  say_error 'This template is only for Rails 5'
  exit
end

say_info('Hello! Welcome to this template')
say_error('Ups! Something went wrong')
say_success('Fixed! Nevermind...')
exit
