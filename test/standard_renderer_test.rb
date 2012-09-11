require 'rubygems'
require 'bundler'
Bundler.require(:test)
require 'test/unit'

require 'action_controller'
require 'active_support/core_ext/string/output_safety'
require 'crummy'
require 'crummy/standard_renderer'

class StandardRendererTest < Test::Unit::TestCase
  include Crummy

  def test_classes
    renderer = StandardRenderer.new
    assert_equal('<a href="url" class="first last">name</a>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html))
    assert_equal('<ul class="" id=""><li class="first last"><a href="url">name</a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list))
    assert_equal('<crumb href="url">name</crumb>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :xml))

    assert_equal('<a href="url1" class="first">name1</a> &raquo; <a href="url2" class="last">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :html))
    assert_equal('<ul class="" id=""><li class="first"><a href="url1">name1</a></li><li class="li_class"><a href="url2">name2</a></li><li class="last"><a href="url3">name3</a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list))
    assert_equal('<ul class="" id=""><li class="first"><a href="url1">name1</a></li> / <li class="li_class"><a href="url2">name2</a></li> / <li class="last"><a href="url3">name3</a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list, :separator => " / "))
    assert_equal('<crumb href="url1">name1</crumb><crumb href="url2">name2</crumb>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :xml))

    assert_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" class="first last" itemprop="url"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html, :microdata => true))
    assert_equal('<ul class="" id=""><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" itemprop="url"><span itemprop="title">name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list, :microdata => true))
  end

  def test_configuration
    renderer = StandardRenderer.new
    # check defaults
    assert_equal " &raquo; ", Crummy.configuration.html_separator
    # adjust configuration
    Crummy.configure do |config|
      config.html_separator = " / "
    end
    assert_equal " / ", Crummy.configuration.html_separator
  end

  def test_configured_renderer
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.html_separator = " / "
    end
    # using configured separator
    assert_equal('<a href="url1" class="">name1</a> / <a href="url2" class="">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']]))
    # overriding configured separator
    assert_equal('<a href="url1" class="">name1</a> | <a href="url2" class="">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :separator => " | "))
  end

  def test_configured_renderer_with_microdata
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = true
    end
    # using configured microdata setting
    assert_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" class="first last" itemprop="url"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html))
  end
end
