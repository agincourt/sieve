module Sieve
  module ViewHelpers
    def sieve(filter)
      filter.attributes.inject([]) { |a| filter_field_for(a) }.join("\n")
    end
    
    private
    def filter_field_for(attribute)
      label = label_tag("filters_#{attribute[:name]}", attribute[:name].humanize)
      
      input = case attribute[:type]
      when :search, :value
        text_field_tag(
          "filters[#{attribute[:name]}]", params[:filters][attribute[:name]],
          :id => "filters_#{attribute[:name]}",
        )
      when :range
        # TODO
      when :toggle
        check_box_tag(
          "filters[#{attribute[:name]}]", '1', params[:filters][attribute[:name]],
          :id => "filters_#{attribute[:name]}"
        )
      else
        ''
      end
      
      [label, input].join("\n")
    end
  end
end