module Sieve
  class DateRange
    attr_accessor :to
    attr_accessor :from
    
    def initialize(attribute)
      set_date('from', attribute)
      set_date('to', attribute)
    end
    
    def set_date(type, attribute)
      self.send("#{type}=".to_sym, [DateTime.civil(
        [(attribute["#{type}(1i)"] || 0).to_i, Date.today.year - 5].max,
        [(attribute["#{type}(2i)"] || 0).to_i, 1].max,
        [(attribute["#{type}(3i)"] || 0).to_i, 1].max,
        (attribute["#{type}(4i)"] || 0).to_i,
        (attribute["#{type}(5i)"] || 0).to_i
      ), DateTime.now].min) if attribute.respond_to?(:select) && attribute.select { |k,v| k =~ /^#{type}/ && v.present? }.length > 0
    rescue ArgumentError
      raise Sieve::InvalidDateError, "The '#{type}' date is invalid:\n#{attribute.select { |k,v| k =~ /^#{type}/ }.map { |k,v| "#{k} => #{v}" }.join("\n")}"
    end
  end
  
  class InvalidDateError < StandardError
  end
end