# typed: strong

module I18n
  def self.t(key, options = {}); end
end

module Rails
  class Engine < ::Rails::Railtie
  end
  
  class Railtie
  end
  
  def self.logger; end
end

module ActiveSupport
  def self.on_load(name, &block); end
  
  module Concern
  end
end

module ActionView
  module Helpers
    module NumberHelper
    end
  end
end

class ApplicationController < ActionController::Base
  def self.helper(helper_module); end
end

module ActionController
  class Base
  end
end