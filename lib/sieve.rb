require 'sieve/controller'
require 'sieve/date_range'
require 'sieve/errors'
require 'sieve/filterable'
require 'sieve/pagination'
require 'sieve/view_helpers'

ActionView::Base.send(:include, Sieve::ViewHelpers) if defined?(ActionView)
ActionController::Base.send(:include, Sieve::Controller) if defined?(ActionController)