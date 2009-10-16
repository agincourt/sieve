$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Sieve
  VERSION = '0.0.1'
  
  class << self
    def enable_actionpack
      return if ActionView::Base.instance_methods.include_method? :sieve
      ActionView::Base.send :include, ViewHelpers
    end
  end
end

if defined? Rails
  Sieve.enable_actionpack if defined? ActionController
end