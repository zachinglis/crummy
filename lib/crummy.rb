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
    attr_accessor :xml_separator
    attr_accessor :html_list_separator
    attr_accessor :first_class
    attr_accessor :last_class
    attr_accessor :ul_id
    attr_accessor :ul_class
    attr_accessor :li_class
    attr_accessor :active_li_class
    attr_accessor :microdata

    def initialize
      @format = :html
      @html_separator = " &raquo; ".html_safe
      @xml_separator = "crumb"
      @html_list_separator = ''
      @skip_if_blank = true
      @links = true
      @first_class = ''
      @last_class = ''
      @ul_id = ''
      @ul_class = ''
      @li_class = ''
      @active_li_class = ''
      @migrodata = false
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
