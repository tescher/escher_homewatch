# This file is copied to spec/ when you run 'rails generate rspec:install'

require 'capybara/rspec'
require 'minitest/reporters'
MiniTest::Reporters.use!
Capybara.javascript_driver = :webkit_debug
