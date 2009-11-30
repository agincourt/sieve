require 'sieve/errors'
require 'sieve/filterable'
require 'sieve/pagination'
require 'sieve/view_helpers'

ActionView::Base.send :include, Sieve::ViewHelpers if defined?(ActionView)