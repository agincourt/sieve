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
      label = label_tag("filters_#{attribute}", attribute.to_s.humanize)
      
      input = case options[:type]
      when :string, :text
        text_field_tag("filters[#{attribute}]", params[:filters][attribute], :id => "filters_#{attribute}")
      when :boolean
        check_box_tag("filters[#{attribute}]", '1', params[:filters][attribute], :id => "filters_#{attribute}")
      when :integer
        if attribute.to_s =~ /\_id$/i
          select_tag(
            "filters[#{attribute}]",
            options_for_select(
              [['-', nil]] + attribute.to_s.gsub(/\_id$/i, '').classify.constantize.all.map { |obj| [obj.name, obj.id] },
              params[:filters][attribute].present? ? params[:filters][attribute].to_i : nil
            )
          )
        else
          text_field_tag("filters[#{attribute}]", params[:filters][attribute], :id => "filters_#{attribute}")
        end
      else
        ''
      end
      
      { :name => attribute, :field => [label, input].join("\n") }
    end
  end
end