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
              # if a set of items are provided
              if options[:set] || options[:collection]
                # we want the exact item
                current_scope = current_scope.sieve_exact(attribute, params[attribute])
              # if it's just a string
              else
                # search for it
                current_scope = current_scope.sieve_search(attribute, params[attribute])
              end
            end
          when :integer, :decimal
            if params[attribute].present?
              current_scope = current_scope.sieve_exact(attribute, params[attribute])
            end
          end
        }
        # return the scope object
        current_scope
      end
      
      def filtering_on
        read_inheritable_attribute(:filters)
      end
          
      private
      def filter_by(attribute_name, options = {})
        write_inheritable_hash(:filters, { attribute_name.to_sym => options.merge(:type => column_type_for(attribute_name.to_sym)) })
      end
      
      def column_type_for(attribute_name)
        cols = columns.select { |col| col.name.to_sym == attribute_name.to_sym }
        raise Errors::NoColumnError, "#{attribute_name} cannot be filtered" unless cols.length > 0
        cols.first.type
      end
    end
    
    module InstanceMethods
    end
    
  end
end