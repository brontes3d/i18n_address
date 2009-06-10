$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'i18n_address'

ActiveRecord::Base.extend I18nAddress::ARClassMethods
