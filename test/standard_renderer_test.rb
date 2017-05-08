require 'rubygems'
require 'bundler'
Bundler.require(:test)
require 'minitest/autorun'

require 'action_controller'
require 'active_support/core_ext/string/output_safety'
require 'action_dispatch/testing/assertions'
require 'crummy'
require 'crummy/standard_renderer'

class StandardRendererTest < Minitest::Test
  include ActionDispatch::Assertions
  include Crummy

  def test_classes
    renderer = StandardRenderer.new
    assert_dom_equal('<a href="url" class="default first last"><span>name</span></a>',
                 renderer.render_crumbs([['name', 'url']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', format: :html))

    assert_dom_equal('<ul><li class="default first last"><a href="url"><span>name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', container: :ul, wrap_with: :li, separator: nil, format: :html))

    assert_dom_equal('<crumbs><crumb href="url">name</crumb></crumbs>',
                 renderer.render_crumbs([['name', 'url']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', format: :xml))

    assert_dom_equal('<a href="url1" class="default first"><span>name1</span></a> &raquo; <a href="url2" class="default"><span>name2</span></a> &raquo; <a href="url3" class="default last"><span>name3</span></a>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', format: :html))

    assert_dom_equal('<ul class="container"><li class="default first"><a href="url1"><span>name1</span></a></li><li class="default"><a href="url2"><span>name2</span></a></li><li class="default last"><a href="url3"><span>name3</span></a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', container_class: 'container', container: :ul, wrap_with: :li, separator: nil, format: :html))

    assert_dom_equal('<crumbs><crumb href="url1">name1</crumb><crumb href="url2">name2</crumb></crumbs>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], default_crumb_class: 'default', first_crumb_class: 'first', last_crumb_class: 'last', format: :xml))
  end

  def test_last_crumb_not_linked
    renderer = StandardRenderer.new
    assert_dom_equal('<span>name</span>',
                 renderer.render_crumbs([['name', 'url']], format: :html, link_last_crumb: false))

    assert_dom_equal('<ul><li><span>name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url']], container: :ul, wrap_with: :li, separator: nil, format: :html, link_last_crumb: false))

    assert_dom_equal('<crumbs><crumb>name</crumb></crumbs>',
                 renderer.render_crumbs([['name', 'url']], format: :xml, link_last_crumb: false))

    assert_dom_equal('<a href="url1"><span>name1</span></a> &raquo; <span>name2</span>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], format: :html, link_last_crumb: false))

    assert_dom_equal('<ul><li><a href="url1"><span>name1</span></a></li><li><a href="url2"><span>name2</span></a></li><li><span>name3</span></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2'], ['name3', 'url3']], container: :ul, wrap_with: :li, separator: nil, format: :html, link_last_crumb: false))

    assert_dom_equal('<crumbs><crumb href="url1">name1</crumb><crumb>name2</crumb></crumbs>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], format: :xml, link_last_crumb: false))
  end

  def test_input_object_mutation
    renderer = StandardRenderer.new

    name1 = 'name1'
    url1 = nil
    name2 = 'name2'
    url2 = nil

    renderer.render_crumbs([[name1, url1], [name2, url2]], format: :html, microdata: false)

    # Rendering the crumbs shouldn't alter the input objects.
    assert_equal('name1', name1);
    assert_equal(nil, url2);
    assert_equal('name2', name2);
    assert_equal(nil, url2);
  end

  def test_html_options
    renderer = StandardRenderer.new

    assert_dom_equal('<a href="url" title="title"><span>name</span></a>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], format: :html))

    assert_dom_equal('<span title="title">name</span>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], format: :html, link_last_crumb: false))

    assert_dom_equal('<ul><li title="title"><a href="url"><span>name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], container: :ul, wrap_with: :li, separator: nil, format: :html))

    assert_dom_equal('<ul><li title="title"><span>name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], container: :ul, wrap_with: :li, format: :html, link_last_crumb: false))
  end

  def test_link_html_options_with_microdata
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.microdata = true
    end

    assert_dom_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/breadcrumb" title="title" class="first last"><a href="url" itemprop="url"><span itemprop="title">name</span></a></div>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], first_crumb_class: 'first', last_crumb_class: 'last', format: :html))

    assert_dom_equal('<div itemscope="itemscope" itemtype="http://data-vocabulary.org/breadcrumb" title="title" class="first last"><span itemprop="title">name</span></div>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], first_crumb_class: 'first', last_crumb_class: 'last', format: :html, link_last_crumb: false))

    assert_dom_equal('<ul><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/breadcrumb" title="title"><a itemprop="url" href="url"><span itemprop="title">name</span></a></li></ul>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], first_crumb_class: 'first', last_crumb_class: 'last', format: :html, container: :ul, wrap_with: :li, separator: nil))

    assert_dom_equal('<ul><li class="first last" itemscope="itemscope" itemtype="http://data-vocabulary.org/breadcrumb" title="title"><span itemprop="title">name</span></li></ul>',
                 renderer.render_crumbs([['name', 'url', crumb_html: { title: 'title' }]], first_crumb_class: 'first', last_crumb_class: 'last', format: :html, container: :ul, wrap_with: :li, separator: nil, link_last_crumb: false))

    Crummy.configure do |config|
      config.microdata = false
    end
  end

  def test_inline_configuration
    renderer = StandardRenderer.new
    Crummy.configure do |config|
      config.link_last_crumb = true
    end

    refute_match(/href/, renderer.render_crumbs([['name', 'url']], link_last_crumb: false))
    assert_match(/href/, renderer.render_crumbs([['name', 'url']], link_last_crumb: true))

    Crummy.configure do |config|
      config.link_last_crumb = false
    end

    refute_match(/href/, renderer.render_crumbs([['name', 'url']], link_last_crumb: false))
    assert_match(/href/, renderer.render_crumbs([['name', 'url']], link_last_crumb: true))

    Crummy.configure do |config|
      config.link_last_crumb = true
    end
  end

  def test_configuration
    renderer = StandardRenderer.new
    # check defaults
    assert_equal " &raquo; ", Crummy.configuration.separator
    # adjust configuration
    Crummy.configure do |config|
      config.separator = " / "
    end
    assert_equal " / ", Crummy.configuration.separator
    Crummy.configure do |config|
      config.separator = " &raquo; "
    end
  end
end
