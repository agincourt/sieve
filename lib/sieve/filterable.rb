module Sieve
  module Filterable
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        named_scope :sieve_search, lambda { |attribute,value| { :conditions => ["#{attribute.to_s.downcase} LIKE ?", "%#{value}%"] } }
        named_scope :sieve_exact, lambda { |attribute,value| { :conditions => ["#{attribute.to_s.downcase} = ?", value] } }
      end
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def sieve_class
        self.base_class
      end
      
      def filter(params)
        params ||= {}
        # load our current scope
        current_scope = self
        # for each setup filter
        filtering_on.each { |attribute, options|
          case options[:type]
          when :string, :text # we want to search
            if params[attribute].present?
              current_scope = current_scope.sieve_search(attribute, params[attribute])
            end
          when :integer
            if params[attribute].present?
              current_scope = current_scope.sieve_exact(attribute, params[attribute])
            end
          end
        }
        # return the scope object
        current_scope
      end
      
      def filtering_on
        @filtering_on ||= columns.inject({}) { |cols,col|
          if (read_inheritable_attribute(:filters).keys || []).include?(col.name.to_sym) && col.type
            cols.merge!({ col.name.to_sym => read_inheritable_attribute(:filters)[col.name.to_sym].merge(:type => col.type.to_sym) })
          end
          cols
        }
      end
          
      private
      def filter_by(attribute_name, options = {})
        attribute_name = attribute_name.to_sym
        raise Errors::NoColumnError, "#{attribute_name} cannot be filtered" unless columns.select { |c| c.name.to_sym == attribute_name }.length > 0
        write_inheritable_hash(:filters, attribute_name.to_sym => options)
      end
    end
    
    module InstanceMethods
    end
    
  end
end