require 'rubygems'
require 'test/unit'
require 'active_record'

#require this plugin
require File.join(File.dirname(__FILE__), "..", "init")

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

#load the database schema for this test
load File.expand_path(File.dirname(__FILE__) + "/test_models/schema.rb")

#require the mock models for the voting system
require File.expand_path(File.dirname(__FILE__) + '/test_models/models.rb')

I18nAddress.load_locale("en")
I18nAddress.load_locale("pirate")
