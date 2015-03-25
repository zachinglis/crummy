module Crummy

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :format
    attr_accessor :right_to_left
    attr_accessor :render_with_links
    attr_accessor :skip_if_blank
    attr_accessor :separator
    attr_accessor :right_to_left_separator
    attr_accessor :default_crumb_class
    attr_accessor :container_class
    attr_accessor :first_crumb_class
    attr_accessor :last_crumb_class
    attr_accessor :link_last_crumb
    attr_accessor :truncate
    attr_accessor :escape
    attr_accessor :crumb_html
    attr_accessor :crumb_xml
    attr_accessor :container
    attr_accessor :wrap_with

    def initialize
      @format = :html
      @right_to_left = false
      @separator = " &raquo; ".html_safe
      @right_to_left_separator = " &laquo; ".html_safe
      @skip_if_blank = true
      @render_with_links = true
      @default_crumb_class = ''
      @container_class = ''
      @first_crumb_class = ''
      @last_crumb_class = ''
      @link_last_crumb = true
      @truncate = nil
      @escape = true
      @crumb_html = {}
      @crumb_xml = {}
      @container = nil
      @wrap_with = nil
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
