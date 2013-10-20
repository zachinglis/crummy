# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(ActionView::Helpers::TagHelper)
    ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.merge([:itemscope].to_set)

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
    # With :format => :html_list you can specify additional params: li_class, ul_class, ul_id
    # The only argument is for the separator text. It does not assume you want spaces on either side so you must specify. Defaults to +&raquo;+
    #
    #   render_crumbs(" . ")  #=> <a href="/">Home</a> . <a href="/businesses">Businesses</a>
    #
    def render_crumbs(crumbs, options = {})

      options[:skip_if_blank] ||= Crummy.configuration.skip_if_blank
      return '' if options[:skip_if_blank] && crumbs.count < 1
      options[:format] ||= Crummy.configuration.format
      options[:separator] ||= Crummy.configuration.send(:"#{options[:format]}_separator")
      options[:right_separator] ||= Crummy.configuration.send(:"#{options[:format]}_right_separator")
      options[:links] ||= Crummy.configuration.links
      options[:first_class] ||= Crummy.configuration.first_class
      options[:last_class] ||= Crummy.configuration.last_class
      options[:microdata] ||= Crummy.configuration.microdata if options[:microdata].nil?
      options[:truncate] ||= Crummy.configuration.truncate if options[:truncate]
      options[:last_crumb_linked] = Crummy.configuration.last_crumb_linked if options[:last_crumb_linked].nil?
      options[:right_side] ||= Crummy.configuration.right_side

      last_hash = lambda {|o|k=o.map{|c|
                                      c.is_a?(Hash) ? (c.empty? ? nil: c) : nil}.compact
                                      k.empty? ? {} : k.last
                                    }
      local_global = lambda {|crumb, global_options, param_name| last_hash.call(crumb).has_key?(param_name.to_sym) ? last_hash.call(crumb)[param_name.to_sym] : global_options[param_name.to_sym]}

      case options[:format]
      when :html
        crumb_string = crumbs.map{|crumb|local_global.call(crumb, options, :right_side) ? nil :
                        crumb_to_html(crumb,
                                      local_global.call(crumb, options, :links),
                                      local_global.call(crumb, options, :first_class),
                                      local_global.call(crumb, options, :last_class),
                                      (crumb == crumbs.first),
                                      (crumb == crumbs.last),
                                      local_global.call(crumb, options, :microdata),
                                      local_global.call(crumb, options, :last_crumb_linked),
                                      local_global.call(crumb, options, :truncate))}.compact.join(options[:separator]).html_safe
        crumb_string
      when :html_list
        # Let's set values for special options of html_list format
        options[:li_class] ||= Crummy.configuration.li_class
        options[:ul_class] ||= Crummy.configuration.ul_class
        options[:ul_id] ||= Crummy.configuration.ul_id
        options[:ul_id] = nil if options[:ul_id].blank?

        crumb_string = crumbs.map{|crumb|local_global.call(crumb, options, :right_side) ? nil : 
                        crumb_to_html_list(crumb,
                                           local_global.call(crumb, options, :links),
                                           local_global.call(crumb, options, :li_class),
                                           local_global.call(crumb, options, :first_class),
                                           local_global.call(crumb, options, :last_class),
                                           (crumb == crumbs.first),
                                           (crumb == crumbs.find_all{|crumb|
                                                    !last_hash.call(crumb).fetch(:right_side,false)}.compact.last),
                                           local_global.call(crumb, options, :microdata),
                                           local_global.call(crumb, options, :last_crumb_linked),
                                           local_global.call(crumb, options, :truncate),
                                           local_global.call(crumb, options, :separator))}.compact.join.html_safe
        crumb_right_string = crumbs.reverse.map{|crumb|!local_global.call(crumb, options, :right_side) ? nil :

                        crumb_to_html_list(crumb,
                                           local_global.call(crumb, options, :links),
                                           local_global.call(crumb, options, :li_right_class),
                                           local_global.call(crumb, options, :first_class),
                                           local_global.call(crumb, options, :last_class),
                                           (crumb == crumbs.first),
                                           (crumb == crumbs.find_all{|crumb|!local_global.call(crumb, options, :right_side)}.compact.last),
                                           local_global.call(crumb, options, :microdata),
                                           local_global.call(crumb, options, :last_crumb_linked),
                                           local_global.call(crumb, options, :truncate),
                                           local_global.call(crumb, options, :right_separator))}.compact.join.html_safe
        crumb_string = content_tag(:ul,
                                   crumb_string+crumb_right_string,
                                   :class => options[:ul_class],
                                   :id => options[:ul_id])
        crumb_string
      when :xml
        crumbs.collect do |crumb|
          crumb_to_xml(crumb,
                      local_global.call(crumb, options, :links),
                      local_global.call(crumb, options, :separator),
                      (crumb == crumbs.first),
                      (crumb == crumbs.last))
        end * ''
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, links, first_class, last_class, is_first, is_last, with_microdata, last_crumb_linked, truncate)
      html_classes = []
      html_classes << first_class if is_first
      html_classes << last_class if is_last
      name, url, options = crumb
      options = {} unless options.is_a?(Hash)
      can_link = url && links && (!is_last || last_crumb_linked)
      link_html_options = options[:link_html_options] || {}
      link_html_options[:class] = html_classes
      if with_microdata
        item_title = content_tag(:span, (truncate.present? ? name.truncate(truncate) : name), :itemprop => "title")
        html_options = {:itemscope => true, :itemtype => data_definition_url("Breadcrumb")}
        link_html_options[:itemprop] = "url"
        html_content = can_link ? link_to(item_title, url, link_html_options) : item_title
        content_tag(:div, html_content, html_options)
      else
        can_link ? link_to((truncate.present? ? name.truncate(truncate) : name), url, link_html_options) : (truncate.present? ? name.truncate(truncate) : name)
      end
    end

    def crumb_to_html_list(crumb, links, li_class, first_class, last_class, is_first, is_last, with_microdata, last_crumb_linked, truncate, separator='')
      name, url, options = crumb
      options = {} unless options.is_a?(Hash)
      can_link = url && links && (!is_last || last_crumb_linked) && !(/<\/a/ =~ name)
      html_classes = []
      html_classes << first_class if is_first && !first_class.empty?
      html_classes << last_class if is_last && !last_class.empty?
      html_classes << li_class unless li_class.empty?
      html_options = html_classes.size > 0 ? {:class => html_classes.join(' ').strip} : {}

      if with_microdata
        html_options[:itemscope] = true
        html_options[:itemtype]  = data_definition_url("Breadcrumb")
        item_title = content_tag(:span, (truncate.present? ? name.truncate(truncate) : name), :itemprop => "title")
        link_html_options = options[:link_html_options] || {}
        link_html_options[:itemprop] = "url"
        html_content = can_link ? link_to(item_title, url, link_html_options) : item_title
      else
        html_content = can_link ? link_to((truncate.present? ? name.truncate(truncate) : name), url, options[:link_html_options]) : content_tag(:span, (truncate.present? ? name.truncate(truncate) : name))
      end
      content_tag(:li, html_content, html_options)+(/<\/li/ =~ separator ? 
                                        separator : content_tag(:li, separator) unless separator.blank? || is_last)
    end

    def crumb_to_xml(crumb, links, separator, is_first, is_last)
      name, url = crumb
      content_tag(separator, name, :href => (url && links ? url : nil))
    end

    def data_definition_url(type)
      "http://data-vocabulary.org/#{type}"
    end
  end
end

