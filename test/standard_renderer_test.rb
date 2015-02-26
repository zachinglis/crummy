require 'rubygems'
require 'bundler'
Bundler.require(:test)
require 'test/unit'

require 'action_controller'
require 'active_support/core_ext/string/output_safety'
require 'action_dispatch/testing/assertions'
require 'crummy'
require 'crummy/standard_renderer'

class StandardRendererTest < Test::Unit::TestCase
  include ActionDispatch::Assertions
  include Crummy

  def test_classes
    renderer = StandardRenderer.new
    assert_dom_equal('<a href="url" class="first last">name</a>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html))
    assert_equal('<ul class=""><li class="first last"><a href="url">name</a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list))
    assert_equal('<crumb href="url">name</crumb>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :xml))

    assert_dom_equal('<a href="url1" class="first">name1</a> &raquo; <a href="url2" class="last">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :html))
    assert_equal('<ul class=""><li class="first li_class"><a href="url1">name1</a></li><li class="li_class"><a href="url2">name2</a></li><li class="last li_class"><a href="url3">name3</a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list))
    assert_equal('<ul class=""><li class="first li_class"><a href="url1">name1</a></li><li> / </li><li class="li_class"><a href="url2">name2</a></li><li> / </li><li class="last li_class"><a href="url3">name3</a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list, :separator => " / "))
    assert_equal('<crumb href="url1">name1</crumb><crumb href="url2">name2</crumb>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :xml))

    assert_dom_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" class="first last" itemprop="url"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html, :microdata => true))
    assert_equal('<ul class=""><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a itemprop="url" href="url"><span itemprop="title">name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list, :microdata => true))
    assert_equal('<ul class="crumbclass" id="crumbid"><li class="liclass"><a href="url">name</a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :format => :html_list, :ul_id => "crumbid", :ul_class => "crumbclass", :li_class => "liclass"))
  end

  def test_classes_last_crumb_not_linked
    renderer = StandardRenderer.new
    assert_equal('name',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html, :last_crumb_linked => false))
    assert_equal('<ul class=""><li class="first last"><span>name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list, :last_crumb_linked => false))
    assert_equal('<crumb href="url">name</crumb>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :xml, :last_crumb_linked => false))

    assert_dom_equal('<a href="url1" class="first">name1</a> &raquo; name2',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :html, :last_crumb_linked => false))
    assert_equal('<ul class=""><li class="first li_class"><a href="url1">name1</a></li><li class="li_class"><a href="url2">name2</a></li><li class="last li_class"><span>name3</span></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list, :last_crumb_linked => false))
    assert_equal('<ul class=""><li class="first li_class"><a href="url1">name1</a></li><li> / </li><li class="li_class"><a href="url2">name2</a></li><li> / </li><li class="last li_class"><span>name3</span></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], :li_class => "li_class", :first_class => 'first', :last_class => 'last', :format => :html_list, :separator => " / ", :last_crumb_linked => false))
    assert_equal('<crumb href="url1">name1</crumb><crumb href="url2">name2</crumb>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :xml, :last_crumb_linked => false))

    assert_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><span itemprop="title">name</span></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html, :microdata => true, :last_crumb_linked => false))
    assert_equal('<ul class=""><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><span itemprop="title">name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html_list, :microdata => true, :last_crumb_linked => false))
    assert_equal('<ul class="crumbclass" id="crumbid"><li class="liclass"><span>name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url']], :format => :html_list, :ul_id => "crumbid", :ul_class => "crumbclass", :li_class => "liclass", :last_crumb_linked => false))
  end

  def test_input_object_mutation
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = false
    end

    name1 = 'name1'
    url1 = nil
    name2 = 'name2'
    url2 = nil

    renderer.render_crumbs([[name1, url1], [name2, url2]], :format => :html, :microdata => false)

    # Rendering the crumbs shouldn't alter the input objects.
    assert_equal('name1', name1);
    assert_equal(nil, url2);
    assert_equal('name2', name2);
    assert_equal(nil, url2);
  end

  def test_link_html_options
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = false
    end

    assert_dom_equal('<a href="url" class="first last" title="link title">name</a>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html))

    assert_equal('name',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html, :last_crumb_linked => false))

    assert_equal('<ul class=""><li class="first last"><a title="link title" href="url">name</a></li></ul>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html_list))

    assert_equal('<ul class=""><li class="first last"><span>name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html_list, :last_crumb_linked => false))
  end

  def test_link_html_options_with_microdata
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = true
    end

    assert_dom_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" class="first last" itemprop="url" title="link title"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html))

    assert_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><span itemprop="title">name</span></div>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html, :last_crumb_linked => false))

    assert_equal('<ul class=""><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a title="link title" itemprop="url" href="url"><span itemprop="title">name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html_list))

    assert_equal('<ul class=""><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><span itemprop="title">name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url', {:link_html_options => {:title => 'link title'}}]], :first_class => 'first', :last_class => 'last', :format => :html_list, :last_crumb_linked => false))
  end

  def test_inline_configuration
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = true
      config.last_crumb_linked = true
    end

    assert_no_match(/itemscope/, renderer.render_crumbs([['name', 'url']], :microdata => false))
    assert_match(/href/, renderer.render_crumbs([['name', 'url']], :last_crumb_linked => true))

    Crummy.configure do |config|
      config.microdata = false
      config.last_crumb_linked = true
    end

    assert_match(/itemscope/, renderer.render_crumbs([['name', 'url']], :microdata => true))
    assert_no_match(/href/, renderer.render_crumbs([['name', 'url']], :last_crumb_linked => false))
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
    assert_dom_equal('<a href="url1" class="">name1</a> / <a href="url2" class="">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']]))
    # overriding configured separator
    assert_dom_equal('<a href="url1" class="">name1</a> | <a href="url2" class="">name2</a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :separator => " | "))
  end

  def test_configured_renderer_with_microdata
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = true
    end
    # using configured microdata setting
    assert_dom_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="url" class="first last" itemprop="url"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html))
    # last crumb not linked
    assert_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb"><span itemprop="title">name</span></div>',
                 renderer.render_crumbs([['name', 'url']], :first_class => 'first', :last_class => 'last', :format => :html, :last_crumb_linked => false))
  end

end
