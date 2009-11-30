module Sieve
  module Filterable
    
    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        named_scope :sieve_search, lambda { |attribute,value| { :conditions => ["#{attribute.to_s.downcase} LIKE ?", "%#{value}%"] } }
        named_scope :sieve_exact, lambda { |attribute,value| { :conditions => ["#{attribute.to_s.downcase} = ?", value] } }
        named_scope :sieve_null, {}
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
        current_scope = self.sieve_null
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
        
        if params[:order_by].present?
          # default to descending
          order_method = params[:order_method].downcase == 'asc' ? 'asc' : 'desc'
          # check the parameter can be ordered on
          raise Errors::NotOptionError, "#{params[:order_by]} cannot be ordered upon." unless ordering_on.include?(params[:order_by].to_sym)
          # add it to the scope
          current_scope = current_scope.scoped(:order => "#{params[:order_by]} #{order_method.upcase}")
        # if no order is passed, use the default
        elsif read_inheritable_attribute(:default_order_by)
          current_scope = current_scope.scoped(:order => "#{read_inheritable_attribute(:default_order_by)} #{read_inheritable_attribute(:default_order_method).upcase}")
        end
        
        # return the scope object
        current_scope
      end
      
      def filtering_on
        read_inheritable_attribute(:filters)
      end
      
      def ordering_on
        read_inheritable_attribute(:order_by)
      end
          
      private
      def filter_by(attribute_name, options = {})
        write_inheritable_hash(:filters, { attribute_name.to_sym => options.merge(:type => column_type_for(attribute_name.to_sym)) })
      end
      
      def order_by(attribute_name, options = {})
        # throw an exception if the column doesn't exist
        column_type_for(attribute_name.to_sym)
        # add the attribute into the hash
        write_inheritable_array(:order_by, [ attribute_name.to_sym ])
        # if this order should be the default
        if options[:default]
          # if a default has already been defined
          if read_inheritable_attribute(:default_order_by)
            # throw them out!
            raise Errors::DuplicateDefaultError, "#{read_inheritable_attribute(:default_order_by)} is already set as the default order."
          end
          # set the orders
          write_inheritable_attribute(:default_order_by, attribute_name.to_sym)
          write_inheritable_attribute(:default_order_method, options[:default].downcase == 'asc' ? 'asc' : 'desc')
        end
      end
      
      def column_type_for(attribute_name)
        cols = columns.select { |col| col.name.to_sym == attribute_name.to_sym }
        raise Errors::NoColumnError, "#{attribute_name} cannot be filtered" unless cols.length > 0
        cols.first.type
      end
    end
    
    module InstanceMethods
      def sieve_class
        self.class.sieve_class
      end
    end
    
  end
end