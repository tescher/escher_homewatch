
source 'https://rubygems.org'
ruby "2.2.7"

gem 'rails', '4.2.10'
gem 'bootstrap-sass'
gem 'bcrypt'
gem 'faker'
gem 'will_paginate', '3.0.3'
gem 'bootstrap-will_paginate', '0.0.6'
# gem 'jquery-rails', '2.1.4'
gem 'jquery-rails'
gem 'pg', '~> 0.18'
gem 'state_machine'
gem 'validates_existence'
gem 'jquery-ui-rails'
gem 'rack-ssl-enforcer'
gem 'enumerated_attribute', :git => "git://github.com/rchekaluk/enumerated_attribute.git", :branch => "feature/rails4"
gem 'delayed_job_active_record'
gem 'sass'

group :development, :test do
  # gem 'sqlite3', '1.3.5'
  gem 'rspec-rails'
  gem 'rspec-its'
  # gem 'guard-rspec', '1.2.1'
  # gem 'guard-spork', '1.2.0'  
  # gem 'spork', '0.9.2'
end

group :development do
  gem 'annotate'
end

group :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test do
  gem 'capybara', '>= 2.5'
  gem 'capybara-webkit'
  gem 'launchy'
  gem 'factory_bot_rails', '~> 4.0'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner', '0.7.0'
  gem "minitest"
  gem "minitest-reporters", '< 1.0.0'
  gem 'test-unit', '~> 3.0'
  gem 'rubocop-rspec'

  # gem 'launchy', '2.1.0'
  # gem 'rb-fsevent', '0.9.1', :require => false
  # gem 'growl', '1.0.3'
end

