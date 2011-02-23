# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(TagHelper)

    # Render the list of crumbs as either html or xml
    #
    # Takes 3 options:
    # The output format. Can either be xml or html. Default :html
    #   :format => (:html|:xml) 
    # The separator text. It does not assume you want spaces on either side so you must specify. Default +&raquo;+ for :html and +crumb+ for xml
    #   :separator => string  
    # Render links in the output. Default +true+
    #   :link => boolean        
    # 
    #   Examples:
    #   render_crumbs                     #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs :separator => ' | ' #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs :format => :xml     #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   
    # The only argument is for the separator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(crumbs, options = {})
      options[:format] = :html if options[:format] == nil
      if options[:separator] == nil
        options[:separator] = " &raquo; " if options[:format] == :html 
        options[:separator] = "crumb" if options[:format] == :xml 
      end
      options[:links] = true if options[:links] == nil
      case options[:format]
      when :html
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html crumb, options[:links]
        end * options[:separator]
        crumb_string = crumb_string.html_safe if crumb_string.respond_to?(:html_safe)
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml crumb, options[:links], options[:separator]
        end * ''
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, links)
      name, url = crumb
      url && links ? link_to(name, url) : name
    end

    def crumb_to_xml(crumb, links, separator)
      name, url = crumb
      url && links ? "<#{separator} href=\"#{url}\">#{name}</#{separator}>" : "<#{separator}>#{name}</#{separator}>"
    end
  end
end
