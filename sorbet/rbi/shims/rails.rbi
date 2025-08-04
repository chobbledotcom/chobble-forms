# typed: strong

module I18n
  def self.t(key, options = {}); end
end

module Rails
  class Engine < ::Rails::Railtie
    def self.isolate_namespace(mod); end
    def self.initializer(name, opts = {}, &block); end
    def self.config; end
    def self.root; end
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
      def number_with_precision(number, options = {}); end
    end
    
    module TranslationHelper
      def t(key, options = {}); end
      def translate(key, options = {}); end
    end
  end
end

class ApplicationController < ActionController::Base
  def self.helper(helper_module); end
end

module ActionController
  class Base
    def self.prepend_view_path(path); end
  end
end

module Kernel
  def instance_variable_get(symbol); end
  def Float(arg, exception: true); end
end

class Object
  def present?; end
end

# Add any constants that might be defined in the app
module InspectionsController
  NOT_COPIED_FIELDS = []
end