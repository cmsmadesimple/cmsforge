module ActionView
  module Helpers

    module PrototypeHelper
      def button_to_remote(name, options = {}, html_options = {})   
        button_to_function(name, remote_function(options), html_options) 
      end 
    end
    
    #module UrlHelper
      #def button_to(name, options = {}, html_options = nil)
        
        #html_options = (html_options || {}).stringify_keys
        #convert_boolean_attributes!(html_options, %w( disabled ))

        #if confirm = html_options.delete("confirm")
          #html_options["onclick"] = "return #{confirm_javascript_function(confirm)};"
        #end

        #url = options.is_a?(String) ? options : url_for(options)
        #name ||= url
        
        #method = options.is_a?(Hash) and options.has_key?(:method) ? options[:method] : 'post'

        #html_options.merge!("type" => "submit", "value" => name)

        #"<form method=\"#{h method}\" action=\"#{h url}\" class=\"button-to\"><div>" +
          #tag("input", html_options) + "</div></form>"
      #end
    #end
    
  end
end
