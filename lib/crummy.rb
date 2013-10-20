module Crummy

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :format
    attr_accessor :links
    attr_accessor :skip_if_blank
    attr_accessor :html_separator
    attr_accessor :html_right_separator
    attr_accessor :xml_separator
    attr_accessor :xml_right_separator
    attr_accessor :html_list_separator
    attr_accessor :html_list_right_separator
    attr_accessor :first_class
    attr_accessor :last_class
    attr_accessor :ul_id
    attr_accessor :ul_class
    attr_accessor :li_class
    attr_accessor :microdata
    attr_accessor :last_crumb_linked
    attr_accessor :truncate
    attr_accessor :right_side

    def initialize
      @format = :html
      @html_separator = " &raquo; ".html_safe
      @html_right_separator = " &raquo; ".html_safe
      @xml_separator = "crumb"
      @xml_right_separator = "crumb"
      @html_list_separator = ''
      @html_list_right_separator = ''
      @skip_if_blank = true
      @links = true
      @first_class = ''
      @last_class = ''
      @ul_id = ''
      @ul_class = ''
      @li_class = ''
      @microdata = false
      @last_crumb_linked = true
      @truncate = nil
      @right_side = false
    end

    def active_li_class=(class_name)
      puts "CRUMMY: The 'active_li_class' option is DEPRECATED and will be removed from a future version"
    end

    def active_li_class
      puts "CRUMMY: The 'active_li_class' option is DEPRECATED and will be removed from a future version"
    end
  end

  if defined?(Rails::Railtie)
    require 'crummy/railtie'
  else
    require 'crummy/action_controller'
    require 'crummy/action_view'
    ActionController::Base.send :include, Crummy::ControllerMethods
    ActionView::Base.send :include, Crummy::ViewMethods
  end
end
