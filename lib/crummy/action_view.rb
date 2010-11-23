module Crummy
  module ViewMethods
    # List the crumbs as an array
    def crumbs
      @_crumbs ||= [] # Give me something to push to
    end
    
    # Add a crumb to the +crumbs+ array
    def add_crumb(name, url=nil)
      crumbs.push [name, url]
    end
    
    # Render the list of crumbs as either html or xml
    #
    # Takes 3 options:
    # The output format. Can either be xml or html. Default :html
    #   :format => (:html|:xml) 
    # The seperator text. It does not assume you want spaces on either side so you must specify. Default +&raquo;+ for :html and +crumb+ for xml
    #   :seperator => string  
    # Render links in the output. Default +true+
    #   :link => boolean        
    # 
    #   Examples:
    #   render_crumbs                     #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs :seperator => ' | ' #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs :format => :xml     #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   
    # The only argument is for the seperator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(options = {})
      options[:format] = :html if options[:format] == nil
      if options[:seperator] == nil
        options[:seperator] = " &raquo; " if options[:format] == :html 
        options[:seperator] = "crumb" if options[:format] == :xml 
      end
      options[:links] = true if options[:links] == nil
      case options[:format]
      when :html
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html crumb, options[:links]
        end * options[:seperator]
        crumb_string = crumb_string.html_safe if crumb_string.respond_to?(:html_safe)
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml crumb, options[:links], options[:seperator]
        end * ''
      else
        raise "Unknown breadcrumb output format"
      end
    end
    
    def crumb_to_html(crumb, links)
      name, url = crumb
      url && links ? link_to(name, url) : name
    end
    
    def crumb_to_xml(crumb, links, seperator)
      name, url = crumb
      url && links ? "<#{seperator} href=\"#{url}\">#{name}</#{seperator}>" : "<#{seperator}>#{name}</#{seperator}>"
    end
  end
end
