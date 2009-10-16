module Sieve
  class Filter
    def self.filter(class_name)
      write_inheritable_attribute(:klass, class_name.is_a?(String) ? class_name.constantize : class_name)
    end
    
    def self.by(attribute_name, type = nil)
      attribute_name = attribute_name.to_sym
      write_inheritable_hash(:attributes, { attribute_name => { :type => type ? type.to_sym : type_for(attribute_name), :properties => columns[attribute_name.to_sym] } })
    end
    
    def attributes
      read_inheritable_attribute(:attributes)
    end
    
    private
    def self.type_for(attribute_name)
      if has_column?(attribute_name)
        case columns[attribute_name][:type].to_s
        when 'text', 'string'
          :search
        when 'date', 'datetime', 'time'
          :range
        when 'boolean'
          :toggle
        else
          :value
        end
      end
    end
    
    def self.has_column?(attribute_name)
      unless columns[attribute_name.to_sym]
        raise NoColumnError, "The class #{klass.name} has no column named #{attribute_name}"
      end
      true
    end
    
    def self.columns
      # try to read the columns attribute
      columns = read_inheritable_attribute(:columns)
      # failing that...
      unless columns
        # load the columns from the klass
        columns = read_inheritable_attribute(:klass).columns
        # transform the columns into a hash with the column name as key
        column_hash = columns.inject({}) { |c| c[:name].to_sym => c }
        # write the columns into the attribute
        write_inheritable_attribute(:columns, column_hash)
      end
      # return the columns
      columns
    end
  end
end