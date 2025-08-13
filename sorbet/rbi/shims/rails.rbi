# typed: strong

module I18n
  extend T::Sig
  
  sig { params(key: T.any(String, Symbol), options: T::Hash[T.untyped, T.untyped]).returns(String) }
  def self.t(key, options = {}); end
end

module Rails
  extend T::Sig
  
  class Engine < ::Rails::Railtie
    extend T::Sig
    
    sig { params(mod: Module).void }
    def self.isolate_namespace(mod); end
    
    sig { params(name: String, opts: T::Hash[T.untyped, T.untyped], block: T.proc.void).void }
    def self.initializer(name, opts = {}, &block); end
    
    sig { returns(T.untyped) }
    def self.config; end
    
    sig { returns(Pathname) }
    def self.root; end
  end
  
  class Railtie
  end
  
  sig { returns(T.untyped) }
  def self.logger; end
end

module ActiveSupport
  extend T::Sig
  
  sig { params(name: Symbol, block: T.proc.void).void }
  def self.on_load(name, &block); end
  
  module Concern
  end
end

module ActionView
  module Helpers
    module NumberHelper
      extend T::Sig
      
      sig { params(number: T.any(Numeric, String, NilClass), options: T::Hash[T.untyped, T.untyped]).returns(T.nilable(String)) }
      def number_with_precision(number, options = {}); end
    end
    
    module TranslationHelper
      extend T::Sig
      
      sig { params(key: T.any(String, Symbol), options: T.untyped).returns(String) }
      def t(key, **options); end
      
      sig { params(key: T.any(String, Symbol), options: T.untyped).returns(String) }
      def translate(key, **options); end
    end
  end
end

class ApplicationController < ActionController::Base
  extend T::Sig
  
  sig { params(helper_module: Module).void }
  def self.helper(helper_module); end
end

module ActionController
  class Base
    extend T::Sig
    
    sig { params(path: T.any(String, Pathname)).void }
    def self.prepend_view_path(path); end
  end
end

module Kernel
  extend T::Sig
  
  sig { params(symbol: T.any(String, Symbol)).returns(T.untyped) }
  def instance_variable_get(symbol); end
  
  sig { params(arg: T.untyped, exception: T::Boolean).returns(T.nilable(Float)) }
  def Float(arg, exception: true); end
end

class Object
  extend T::Sig
  
  sig { returns(T::Boolean) }
  def present?; end
end

class Pathname
  extend T::Sig
  
  sig { params(args: T.untyped).returns(Pathname) }
  def join(*args); end
end

module InspectionsController
  NOT_COPIED_FIELDS = T.let([], T::Array[String])
end

module ChobbleForms
  module Helpers
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TranslationHelper
  end
end