require 'sieve/errors'
require 'sieve/filterable'
require 'sieve/view_helpers'

module Sieve
end

ActionView::Base.send :include, Sieve::ViewHelpers