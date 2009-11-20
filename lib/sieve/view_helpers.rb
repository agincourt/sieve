module Sieve
  module ViewHelpers
    def sieve(collection)
      params[:filters] ||= {}
      collection.sieve_class.filtering_on.map { |attribute,options|
        filter_field_for(attribute,options)
      }.sort { |a,b| a[:name].to_s<=>b[:name].to_s }.map { |f| f[:field] }.join("\n")
    end
    
    private
    def filter_field_for(attribute, options)    
      label = label_tag("filters_#{attribute}", options[:label] ? options[:label] : attribute.to_s.humanize)
      
      input = case options[:type]
      when :string, :text, :integer, :decimal
        if options[:collection]
          select_tag("filters[#{attribute}]",
            options_for_select(
              (options[:include_blank] ? [[options[:include_blank], nil]] : []) +
              options[:collection].map { |obj| options[:display] ? options[:display].call(obj) : [obj.id] }, 
              params[:filters][attribute].present? ? params[:filters][attribute].to_i : nil
            )
          )
        elsif options[:set]
          select_tag("filters[#{attribute}]",
            options_for_select(
              (options[:include_blank] ? [[options[:include_blank], nil]] : []) +
              options[:set],
              params[:filters][attribute].present? ? params[:filters][attribute] : nil
            )
          )
        else
          text_field_tag("filters[#{attribute}]", params[:filters][attribute], :id => "filters_#{attribute}", :maxlength => options[:max_length])
        end
      when :boolean
        check_box_tag("filters[#{attribute}]", '1', params[:filters][attribute], :id => "filters_#{attribute}")
      else
        ''
      end
      
      { :name => attribute, :field => [label, input].join("\n") }
    end
  end
end