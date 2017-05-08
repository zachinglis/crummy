# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(ActionView::Helpers::TagHelper)
    ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.merge([:itemscope].to_set)
    include ERB::Util

    attr_accessor :options

    # Render the list of crumbs as either html or xml
    #
    # Takes 3 options:
    # The output format. Can either be HTML, XML or JSON. Default :html
    #   :format => (:html|:xml|:json)
    # The separator text. It does not assume you want spaces on either side so you must specify. Default +&raquo;+ for :html and +crumb+ for xml
    #   :separator => string
    # Render links in the output. Default +true+
    #   :link => boolean
    #
    #   Examples:
    #   render_crumbs                                                #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
    #   render_crumbs separator: ' | '                               #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
    #   render_crumbs format: :xml                                   #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
    #   render_crumbs container: :ul, wrap_with: :li, separator: nil #=> <ul><li><a href="/">Home</a></li><li><a href="/">Businesses</a></li></ul>
    #
    def render_crumbs(crumbs, options = {})
      self.options = options

      return '' if get_option(:skip_if_blank) && crumbs.count < 1

      crumbs = crumbs.reverse if get_option(:right_to_left)

      crumbs_count = crumbs.count - 1

      case get_option(:format)
      when :html
        html = crumbs.map.with_index { |crumb, index|
          crumb_to_html(crumb, index, crumbs_count)
        }.compact.join(get_option(:separator)).html_safe
        if get_option(:container).present?
          html = content_tag(get_option(:container).to_sym, html, class: get_option(:container_class).presence)
        end
        html
      when :xml
        xml = crumbs.map.with_index { |crumb, index|
          crumb_to_xml(crumb, index, crumbs_count)
        }.compact.join.html_safe
        content_tag(:crumbs, xml)
      when :json
        crumbs.map.with_index { |crumb, index|
          crumb_to_json(crumb, index, crumbs_count)
        }.to_json
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, index, total)
      name, url, options = normalize_crumb(crumb, index, total)

      crumb_html = get_option(:crumb_html).merge(options.fetch(:crumb_html, {}))
      crumb_html[:class] = Array(crumb_html.fetch(:class, []))
      crumb_html[:class] << get_option(:default_crumb_class).presence
      crumb_html[:class] << get_option(:first_crumb_class).presence if index == 0
      crumb_html[:class] << get_option(:last_crumb_class).presence if index == total
      crumb_html[:class].compact!
      crumb_html[:class].uniq!
      crumb_html.delete(:class) if crumb_html[:class].blank?

      if url && get_option(:wrap_with).present?
        content_tag(get_option(:wrap_with).to_sym, link_to(name, url), crumb_html)
      elsif url
        link_to(name, url, crumb_html)
      elsif get_option(:wrap_with).present?
        content_tag(get_option(:wrap_with).to_sym, content_tag(:span, name), crumb_html)
      else
        content_tag(:span, name, crumb_html)
      end
    end

    def crumb_to_xml(crumb, index, total)
      name, url, options = normalize_crumb(crumb, index, total)

      crumb_xml = get_option(:crumb_xml).merge(options.fetch(:crumb_xml, {}))
      crumb_xml[:href] = url if url

      content_tag(:crumb, name, crumb_xml)
    end

    def crumb_to_json(crumb, index, total, options)
      name, url, options = normalize_crumb(crumb, index, total)

      { name: name, href: url }
    end

    def normalize_crumb(crumb, index, total)
      name, url, options = crumb
      options = {} unless options.is_a?(Hash)

      options[:truncate] = options.fetch(:truncate, get_option(:truncate))
      name = name.truncate(options[:truncate]) if options[:truncate]

      options[:escape] = options.fetch(:escape, get_option(:escape))
      name = options[:escape] ? h(name) : name.html_safe

      url = nil unless options.fetch(:link, get_option(:link)) && ( index != total || get_option(:link_last_crumb) )

      [name, url, options]
    end

    def get_option(option)
      self.options.fetch(option, Crummy.configuration.send(option.to_sym)).clone
    end
  end
end
