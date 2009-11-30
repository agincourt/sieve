module Sieve
  module Pagination
    module WillPaginate
      module InstanceMethods
        def sieve_class(value = nil)
          @sieve_class = value if value
          @sieve_class
        end
        alias_method :sieve_class=, :sieve_class
      end
    end
  end
end

if defined?(WillPaginate::Collection)
  WillPaginate::Collection.send(:include, Sieve::Pagination::WillPaginate::InstanceMethods)
  
  ActiveRecord::Base.class_eval do
    def self.paginate_with_sieve(args = {})
      collection = paginate_without_sieve(args)
      collection.sieve_class = sieve_class
      collection
    end
    
    class << self
      alias_method :paginate_without_sieve, :paginate
      alias_method :paginate, :paginate_with_sieve
    end
  end
end