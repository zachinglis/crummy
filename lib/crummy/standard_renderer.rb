# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(ActionView::Helpers::TagHelper)

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
    #   render_crumbs                         #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs :separator => ' | '     #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs :format => :xml         #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   render_crumbs :format => :html_list   #=> <ul class="" id=""><li class=""><a href="/">Home</a></li><li class=""><a href="/">Businesses</a></li></ul>
    #   
    # With :format => :html_list you can specify additional params: active_li_class, li_class, ul_class, ul_id
    # The only argument is for the separator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(crumbs, options = {})
      options[:skip_if_blank] ||= Crummy.configuration.skip_if_blank
      return '' if options[:skip_if_blank] && crumbs.count < 1
      options[:format] ||= Crummy.configuration.format
      options[:separator] ||= Crummy.configuration.send(:"#{options[:format]}_separator")
      options[:links] ||= Crummy.configuration.links
      options[:first_class] ||= Crummy.configuration.first_class
      options[:last_class] ||= Crummy.configuration.last_class

      case options[:format]
      when :html
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html(crumb, options[:links], options[:first_class], options[:last_class], (crumb == crumbs.first), (crumb == crumbs.last))
        end * options[:separator]
        crumb_string
      when :html_list
        # Let's set values for special options of html_list format
        options[:active_li_class] ||= Crummy.configuration.active_li_class
        options[:li_class] ||= Crummy.configuration.li_class
        options[:ul_class] ||= Crummy.configuration.ul_class
        options[:ul_id] ||= Crummy.configuration.ul_id
        crumb_string = crumbs.collect do |crumb|
          crumb_to_html_list(crumb, options[:links], options[:li_class], options[:active_li_class], options[:first_class], options[:last_class], (crumb == crumbs.first), (crumb == crumbs.last))
        end * options[:separator]
        crumb_string = content_tag(:ul, crumb_string, :class => options[:ul_class], :id => options[:ul_id])
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml(crumb, options[:links], options[:separator], (crumb == crumbs.first), (crumb == crumbs.last))
        end * ''
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, links, first_class, last_class, is_first, is_last)
      html_classes = []
      html_classes << first_class if is_first
      html_classes << last_class if is_last
      name, url = crumb
      url && links ? link_to(name, url, :class => html_classes) : name
    end
    
    def crumb_to_html_list(crumb, links, li_class, active_li_class, first_class, last_class, is_first, is_last)
      name, url = crumb
      html_classes = []
      html_classes << first_class if is_first
      html_classes << last_class if is_last
      html_classes << active_li_class unless url && links
      html_classes << li_class if !is_first && !is_last && url && links
      content_tag(:li, url && links ? link_to(name, url) : content_tag(:span, name), :class => html_classes.join(' ').strip)
    end
  
    def crumb_to_xml(crumb, links, separator, is_first, is_last)
      name, url = crumb
      content_tag(separator, name, :href => (url && links ? url : nil))
    end
  end
end
