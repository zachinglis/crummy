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
    
    # Render the list of crumbs using renderer
    #
    def render_crumbs(options = {})
      raise ArgumentError, "Renderer and block given" if options.has_key?(:renderer) && block_given?
      return yield(crumbs, options) if block_given?
      
      @_renderer ||= if options.has_key?(:renderer)
        options.delete(:renderer)
      else
        require 'crummy/standard_renderer'
        Crummy::StandardRenderer.new
      end

      @_renderer.render_crumbs(crumbs, options)
    end
  end
end
