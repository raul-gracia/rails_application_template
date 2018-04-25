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
def just_say(text); say "            #{text}" end
def just_ask(text); ask "            #{text}" end

gems_to_configure = {root: [], dev: [], test: [], dev_test: []}

# Check for Rails Version
if Rails::VERSION::MAJOR.to_s != "5"
  say_error 'This template is only for Rails 5'
  exit
end

def replace_line(filename, old_line, new_line)
  text = File.read(filename)
  new_content = text.gsub(old_line, new_line)
  File.open(filename, "w") {|f| f.puts new_content}
end


def choose_option(question, options)
  option = -1
  while(!(1..options.size).include?(option)) do
    just_say(question)
    options.each_with_index{|o, i| just_say("  #{(i+1)}. #{o.to_s.capitalize}")}
    option = just_ask("Choose one option: ").to_i
  end
  options[option-1]
end

def choose_multiple(question, options)
  choosen_options = []
  while(choosen_options.empty?) do
    just_say(question)
    options.each_with_index{|o, i| just_say("  #{(i+1)}. #{o.to_s.capitalize}")}
    choosen_options = just_ask("Choose options(separated by comma): ").split(',')
    choosen_options =
      choosen_options
      .map(&:strip)
      .select{|o| o.match(/\d/)}
      .map(&:to_i)
      .select{|o| (1..options.size).include o}
  end
  choosen_options
end

def new_commit(text)
  git add: '.'
  git commit: "-a -m '#{text}'"
end

def configure_bootstrap
  say_info 'Configuring Bootstrap'
  run 'rm app/assets/stylesheets/application.css'
  file 'app/assets/stylesheets/application.scss', <<~CODE
  /*
   *= require_self
   */
  // Custom bootstrap variables must be set or imported *before* bootstrap.
  @import "bootstrap";
  CODE

  run 'rm app/assets/javascripts/application.js'
  file'app/assets/javascripts/application.js', <<~CODE
  //= require rails-ujs
  //= require turbolinks
  //= require jquery3
  //= require popper
  //= require bootstrap
  CODE
  new_commit 'Configure bootstrap'
  say_success 'Done'
end

def configure_devise
  say_info 'Configuring Devise'
  generate 'devise:install'
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  generate 'devise User name:string role:string'
  rails_command "db:migrate"
  new_commit 'Configuring Devise'
  say_success 'Done'
end

def configure_rspec(erb: true, react: false)
  say_info 'Configuring Rspec'
  generate "rspec:install"
  require_config = <<~CODE
    require 'rspec/rails'
    require 'capybara/rspec'
    Capybara.javascript_driver = :poltergeist
    require 'capybara-screenshot/rspec'
    Capybara.asset_host = 'http://localhost:3000'
    //Capybara.save_path = '$APPLICATION_ROOT/tmp/capybara'
    # Keep only the screenshots generated from the last failing test suite
    Capybara::Screenshot.prune_strategy = :keep_last_run
  CODE
  replace_line('spec/rails_helper.rb', "require 'rspec/rails'", require_config)

  if react
    react_on_rails_config =  <<~CODE
      RSpec.configure do |config|
        ReactOnRails::TestHelper.configure_rspec_to_compile_assets(config)
    CODE
    replace_line('spec/rails_helper.rb', "RSpec.configure do |config|", react_on_rails_config)

  else
    generate 'controller hello_world index', '--no-helper', '--no-view-specs', '--no-assets', '--no-controller-specs'
    if erb
      run 'rm app/views/hello_world/index.html.erb'
      file 'app/views/hello_world/index.html.erb', <<~CODE
      <h1> Hello World</h1>
      <h3> Hello Stranger!</h3>
      CODE
    else
      run 'rm app/views/hello_world/index.html.haml'
      file 'app/views/hello_world/index.html.haml', <<~CODE
      %h1 Hello World
      %h3 Hello Stranger!
      CODE
    end
  end
  route "root to: 'hello_world#index'"
  #<p class="notice"><%= notice %></p>
  #<p class="alert"><%= alert %></p>

  shoulda_config = <<~CODE
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  end
  CODE
  replace_line('spec/rails_helper.rb', /^end$/, shoulda_config)

  run 'rm app/models/user.rb'
  file 'app/models/user.rb', <<~CODE
  class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    validates_presence_of :name, :email
  end
  CODE

  run 'rm .rspec'
  file '.rspec', <<~CODE
  --require rails_helper
  --format progress
  --color
  --order rand
  CODE

  file 'spec/features/hello_world_spec.rb', <<~CODE
   require 'rails_helper'

   RSpec.feature "Hello World Test", type: :feature, js: true do
     it "should render the Hello World on the home page" do
       visit root_path
       expect(page).to have_content "Hello World"
       expect(page).to have_content "Hello, Stranger!"
     end
   end
  CODE

  run 'rm spec/models/user_spec.rb'
  file 'spec/models/user_spec.rb', <<~CODE
    require 'rails_helper'

    RSpec.describe User, type: :model do
      context "has validations" do
        it { should validate_presence_of(:name) }
        it { should validate_presence_of(:email) }
      end

      context "has db structure" do
        it { should have_db_column(:name) }
        it { should have_db_column(:email) }
        it { should have_db_column(:encrypted_password) }
      end
    end
  CODE

  new_commit 'Configure Rspec'
  say_success 'Done'
end


##########################################
##########################################
##########################################

say_info("Lets Configure your new rails app!\n")

# Now we ask all the questions upfront

####################
#   VIEW LIBRARY   #
####################
library = choose_option('Choose a View Library', [:erb, :haml])
if library == :haml
  gems_to_configure[:root] << library
else
  say_info("Moving on")
end

#########################
#   FACTORIES LIBRARY   #
#########################
library = choose_option('Choose a Factory Library', [:factory_bot_rails, :fabricator])
gems_to_configure[:dev_test] << library

################
#   REACT JS   #
################
webpack_react = yes? "Do you need reactjs support? (y/N) "
if webpack_react
  gems_to_configure[:root] << :webpacker
  gems_to_configure[:root] << :react_on_rails
end

###############################################################################
###############################################################################
###############################################################################
new_commit('Initial Commit')


gems_to_configure[:root]     += %i[bootstrap jquery-rails devise]
gems_to_configure[:dev]      += %i[better_errors binding_of_caller spring-commands-rspec]
gems_to_configure[:dev_test] += %i[pry-byebug rspec-rails shoulda-matchers faker]
gems_to_configure[:test]     += %i[capybara capybara-screenshot poltergeist]

gems_to_configure.each do |group, gems|
  case group
  when :root
    gems.each{|gem_name| gem gem_name.to_s}
  when :dev
    gem_group :development { gems.each{ |gem_name| gem gem_name.to_s } }
  when :test
    gem_group :test { gems.each{ |gem_name| gem gem_name.to_s } }
  when :dev_test
    gem_group :development, :test { gems.each{ |gem_name| gem gem_name.to_s } }
  end
end
run "bundle install"
new_commit 'Install all the required gems'

if webpack_react
  say_info("Configuring Webpacker")
  rails_command "webpacker:install"
  say_info("Installing react")
  rails_command "webpacker:install:react"
  new_commit('Configure webpack:react')
  generate "react_on_rails:install"
  new_commit('Install react on rails config')
  say_success("React and webpacker installed")
end
rails_command "db:migrate"
rails_command "db:reset"
rails_command "db:setup"

configure_bootstrap
configure_devise
configure_rspec(erb: gems_to_configure[:root].include?(:erb), react: webpack_react)


after_bundle do
  run "bundle exec spring binstub --all"
  new_commit 'Add binstubs'
end

say_info("Enjoy!")
