require 'rubygems'
require 'bundler'
Bundler.require(:test)
require 'test/unit'

require 'action_controller'
require 'active_support/core_ext/string/output_safety'
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
    assert_equal('<ul class="" id=""><li class="first"><a href="url1">name1</a></li><li class="last"><a href="url2">name2</a></li></ul>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :html_list))
    assert_equal('<crumb href="url1">name1</crumb><crumb href="url2">name2</crumb>',
                 renderer.render_crumbs([['name1', 'url1'], ['name2', 'url2']], :first_class => 'first', :last_class => 'last', :format => :xml))
  end
end
