module Sieve
  module ViewHelpers
    def sieve(collection, options = {})
      logger.debug "OPTIONS: #{options.inspect}"
      
      # setup our config
      options ||= {}
      options.symbolize_keys!
      params[:filters] ||= {}
      
      # create and sort our fields
      options[:form] ? sieve_form(collection, options) : sieve_fields(collection)
    end
    
    private
    def sieve_form(collection, options = {})
      content_tag(:form,
        content_tag(
          :fieldset,
          "<legend>Filters</legend><div>#{sieve_fields(collection)}\n#{submit_tag 'Update Filters &raquo;', :name => nil}</div>"
        ),
        :method => 'get',
        :action => options[:form].kind_of?(String) ? options[:form] : ''
      )
    end
    
    def sieve_fields(collection)
      (collection.sieve_class.filtering_on.map { |attribute,options|
        filter_field_for(attribute,options)
      }.sort { |a,b| a[:name].to_s<=>b[:name].to_s }.map { |f| f[:field] } + sieve_order_fields(collection)).join("\n")
    end
    
    def sieve_order_fields(collection)
      collection.sieve_class.ordering_on ? [
        label_tag("filters_order_by", "Order By:"),
        select_tag("filters[order_by]",
          options_for_select(
            [['-', nil]] +
            collection.sieve_class.ordering_on.map { |attribute| [attribute.to_s.humanize, attribute] }, 
            params[:filters][:order_by].present? ? params[:filters][:order_by].to_sym : collection.sieve_class.read_inheritable_attribute(:default_order_by)
          )
        ),
        select_tag("filters[order_method]",
          options_for_select(
            [['Ascending', 'asc'], ['Descending', 'desc']], 
            params[:filters][:order_method].present? ? params[:filters][:order_method] : collection.sieve_class.read_inheritable_attribute(:default_order_method)
          )
        )
      ] : []
    end
    
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