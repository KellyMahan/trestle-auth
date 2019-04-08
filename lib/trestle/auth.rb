require "trestle/auth/version"
require "trestle"
require 'rqrcode'

module Trestle
  module Auth
    extend ActiveSupport::Autoload

    autoload :AuthException
    autoload :TwofactorField
    autoload :Configuration
    autoload :Constraint
    autoload :ControllerMethods
    autoload :ModelMethods
    autoload :NullUser
  end

  Configuration.option :auth, Auth::Configuration.new
end

require "trestle/auth/engine" if defined?(Rails)
