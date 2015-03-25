# encoding: utf-8

module Crummy
  class StandardRenderer
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TagHelper unless self.included_modules.include?(ActionView::Helpers::TagHelper)
    ActionView::Helpers::TagHelper::BOOLEAN_ATTRIBUTES.merge([:itemscope].to_set)
    include ERB::Util

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

      options = normailize_options(options)

      return '' if options[:skip_if_blank] && crumbs.count < 1

      crumbs = crumbs.reverse if options[:right_to_left]

      case options[:format]
      when :html
        html = crumbs.each_with_index.map{ |crumb, index|
          crumb_to_html(crumb, index, crumbs.count, options)
        }.compact.join(options[:separator]).html_safe
        if options[:container].present?
          html = content_tag(options[:container].to_sym, html, class: options[:container_class])
        end
        html
      when :xml
        xml = crumbs.each_with_index.map{ |crumb, index|
          crumb_to_xml(crumb, index, crumbs.count, options)
        }.compact.join.html_safe
        content_tag(:crumbs, xml)
      when :json
        crumbs.each_with_index.map{ |crumb, index|
          crumb_to_json(crumb, index, crumbs.count, options)
        }.to_json
      else
        raise ArgumentError, "Unknown breadcrumb output format"
      end
    end

    private

    def crumb_to_html(crumb, index, total, options)
      name, url, crumb_options = normalize_crumb(crumb, index, total, options)

      if url && crumb_options[:wrap_with].present?
        content_tag(crumb_options[:wrap_with].to_sym, link_to(name, url), crumb_options[:html])
      elsif url
        link_to(name, url, crumb_options[:html])
      elsif crumb_options[:wrap_with].present?
        content_tag(crumb_options[:wrap_with].to_sym, content_tag(:span, name), crumb_options[:html])
      else
        content_tag(:span, name, crumb_options[:html])
      end
    end

    def crumb_to_xml(crumb, index, total, options)
      name, url, crumb_options = normalize_crumb(crumb, index, total, options)

      crumb_options[:xml][:href] = url if url && options[:render_with_links]

      content_tag(:crumb, name, crumb_options[:xml])
    end

    def crumb_to_json(crumb, index, total, options)
      name, url, crumb_options = normalize_crumb(crumb, index, total, options)

      { name: name, href: (url if options[:render_with_links]) }
    end

    def normalize_crumb(crumb, index, total, options)
      name, url, crumb_options = crumb
      crumb_options = {} unless crumb_options.is_a?(Hash)

      crumb_options = options[:crumb_options].merge(crumb_options)

      total -= 1

      name = name.truncate(crumb_options[:truncate]) if crumb_options[:truncate].present?
      name = crumb_options[:escape] == false ? name.html_safe : h(name)

      url = options[:render_with_links] && ( index != total || options[:link_last_crumb] ) ? url : nil

      html_classes = []
      html_classes << options[:default_crumb_class] if options[:default_crumb_class].present?
      html_classes << options[:first_crumb_class] if options[:first_crumb_class].present? && index == 0
      html_classes << options[:last_crumb_class] if options[:last_crumb_class].present? && index == total

      if html_classes.present? && crumb_options[:html][:class]
        crumb_options[:html][:class] = [crumb_options[:html][:class], html_classes].flatten.join(' ')
      elsif html_classes.present?
        crumb_options[:html][:class] = html_classes.join(' ')
      end

      [name, url, crumb_options]
    end

    def normailize_options(options)
      normalized_options = {}

      normalized_options[:skip_if_blank] = option_or_default(:skip_if_blank, options)
      normalized_options[:format] = option_or_default(:format, options)
      normalized_options[:right_to_left] = option_or_default(:right_to_left, options)
      normalized_options[:separator] = option_or_default(options[:right_to_left] ? :right_to_left_separator : :separator, options)
      normalized_options[:render_with_links] = option_or_default(:render_with_links, options)
      normalized_options[:container_class] = option_or_default(:container_class, options)
      normalized_options[:default_crumb_class] = option_or_default(:default_crumb_class, options)
      normalized_options[:first_crumb_class] = option_or_default(:first_crumb_class, options)
      normalized_options[:last_crumb_class] = option_or_default(:last_crumb_class, options)
      normalized_options[:link_last_crumb] = option_or_default(:link_last_crumb, options)
      normalized_options[:container] = option_or_default(:container, options)

      normalized_options[:crumb_options] = {}
      normalized_options[:crumb_options][:truncate] = option_or_default(:truncate, options)
      normalized_options[:crumb_options][:escape] = option_or_default(:escape, options)
      normalized_options[:crumb_options][:html] = option_or_default(:crumb_html, options)
      normalized_options[:crumb_options][:xml] = option_or_default(:crumb_xml, options)
      normalized_options[:crumb_options][:wrap_with] = option_or_default(:wrap_with, options)

      normalized_options
    end

    def option_or_default(option, options)
      options.has_key?(option.to_sym) ? options[option.to_sym] : Crummy.configuration.send(option.to_sym)
    end
  end
end
