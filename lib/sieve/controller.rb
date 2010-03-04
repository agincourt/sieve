module Sieve
  module Controller
    
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :setup_sieve_filters
      end
    end
    
    module InstanceMethods
      protected
      def setup_sieve_filters
        params           ||= {}
        params[:filters] ||= {}
      
        params[:filters].each { |key,value|
          if params[:filters][key].respond_to?(:select) && params[:filters][key].select { |k,v| k =~ /^[from|to]/ }.length > 0
            params[:filters][key][:date] = Sieve::DateRange.new(params[:filters][key])
          end
        }
      end
    end
  end
end