# Crummy

[![Gem Version](https://badge.fury.io/rb/crummy.png)](http://badge.fury.io/rb/crummy)
[![Build Status](https://secure.travis-ci.org/zachinglis/crummy.png)](http://travis-ci.org/zachinglis/crummy)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/zachinglis/crummy)

Crummy is a simple and tasty way to add breadcrumbs to your Rails applications.

## Install

Simply add the dependency to your Gemfile:

```ruby
gem "crummy", github: 'blaknite/crummy', branch: 'master'
```

# Example

In your controllers you may add\_crumb either like a before\_filter or
within a method (It is also available to views).

```ruby
class ApplicationController
  add_crumb "Home", '/'
end

class BusinessController < ApplicationController
  add_crumb("Businesses") { |instance| instance.send :businesses_path }
  add_crumb("Comments", only: "comments") { |instance| instance.send :businesses_comments_path }
  before_action :load_comment, only: "show"
  add_crumb :comment, only: "show"

  # Example for nested routes:
  add_crumb(:document) { [:account, :document] }

  def show
    add_crumb @business.display_name, @business
  end

  def load_comment
    @comment = Comment.find(params[:id])
  end
end
```

Then in your view:

```erb
<%= render_crumbs %>
```

## Html options for breadcrumb link

You can set the html options with `:crumb_html`.
These are added to the `<a>` or `<li>` tag.

```ruby
add_crumb "Home", '/', crumb_html: { title: "my link title" }
```

##You can set html instead text in first parameter.
You must tell specify that the string is not to be escaped. For example if you want to use icons in your crumbs:

```ruby
add_crumb "<span class="fa fa-life-ring"></span> Support", "/", escape: false
```

## Options for render\_crumbs

`render_crumbs` renders the list of crumbs as either html or xml

The output format. Can either be :xml or :html. Defaults
to :html

```ruby
format: (:html|:xml)
```

Unordered lists and other such structures can be created by specifying :container and :wrap_with.
The following would output an unordered list:

```ruby
render_crumbs container: :ul, wrap_with: :li, separator: ''
```

The separator text. It does not assume you want spaces on either side so
you must specify. Defaults to `&raquo;` for :html and
`<crumb>` for :xml

```ruby
separator: string
```

Render links in the output. Defaults to *true*

```ruby
render_with_links: false
```

Optionally disable linking of the last crumb, Defaults to *true*

```ruby
link_last_crumb: false
```

With this option, output will be blank if there are no breadcrumbs.

```ruby
skip_if_blank: true
```

### Examples

```ruby
render_crumbs                     #=> <a href="/">Home</a> &raquo; <a href="/businesses">Businesses</a>
render_crumbs separator: ' | '    #=> <a href="/">Home</a> | <a href="/businesses">Businesses</a>
render_crumbs format: :xml        #=> <crumb href="/">Home</crumb><crumb href="/businesses">Businesses</crumb>
render_crumbs format: :html_list  #=> <ul class="" id=""><li class=""><a href="/">Home</a></li><li class=""><a href="/">Businesses</a></li></ul>
render_crumbs format: :html_list, :microdata => true
                                  #=> <ul class="" id=""><li class="" itemscope="itemscope" itemtype="http://data-vocabulary.org/Breadcrumb">
                                  #     <a href="/" itemprop="url"><span itemprop="title">Home</span></a></li></ul>
add_crumb support_link, {:right_side => true, :links => "/support", :li_right_class => "pull-right hidden-phone"}
                                  #=> <li class="pull-right hidden-phone">
                                  #=>  <span><a class="glyphicons shield" href="/support">
                                  #=>   <i></i>Support</a>
                                  #=>  </span>
                                  #=> </li>
                                  #=> <li class="divider pull-right hidden-phone"></li>
```

A crumb with a nil argument for the link will output an unlinked crumb.

With `format: :html_list` you can specify the additional option `:container_class`

### App-wide configuration

You have the option to pre-configure any of the Crummy options in an
application-wide configuration. The options above are available to
configure, with the exception of `:separator`, as well as many others.

The biggest difference is that `:separator` is not an option. Instead,
you have format-specific configuration options: `:html_separator`,
`:xml_separator`, and `:html_list_separator`. `:separator` can still be
overridden in the view.

Insert the following in a file named `config/initializers/crummy.rb`:

```ruby
Crummy.configure do |config|
  config.format = :xml
end
```

Possible parameters for configuration are:

```ruby
:format
:render_with_links
:skip_if_blank
:html_separator
:html_right_to_left_separator
:xml_separator
:xml_right_to_left_separator
:default_crumb_class
:crumb_first_class
:crumb_last_class
:container_class
:link_last_crumb
:truncate
:escape
:right_to_left
:crumb_html
```

See `lib/crummy.rb` for a list of these parameters and their defaults.

###Individually for each crumb configuration:
```ruby
add_crumb 'Support', support_path, crumb_html: { class: 'important', title: 'File a support request.' }, truncate: 20
```
Simple add that parameter to options hash.

## Todo

-   Accept collections of models as a single argument
-   Accept instances of models as a single argument
-   Allow for variables in names. (The workaround is to do your own
    before\_filter for that currently)
-   Make a crumbs? type method

## Credits

-   [Zach Inglis](http://zachinglis.com) of [Superhero Studios](http://superhero-studios.com)
-   [Andrew Nesbitt](http://github.com/andrew)
-   [Rein Henrichs](http://reinh.com)
-   [Les Hill](http://blog.leshill.org/)
-   [Sandro Turriate](http://turriate.com/)
-   [Przemysław
    Kowalczyk](http://szeryf.wordpress.com/2008/06/13/easy-and-flexible-breadcrumbs-for-rails/)
    - feature ideas
-   [Sharad Jain](http://github.com/sjain)
-   [Max Riveiro](http://github.com/kavu)
-   [Kamil K. Lemański](http://kml.jogger.pl)
-   [Brian Cobb](http://bcobb.net/)
-   [Kir Shatrov](http://github.com/shatrov) ([Evrone
    company](http://evrone.com))
-   [sugilog](http://github.com/sugilog)
-   [Trond Arve Nordheim](http://github.com/tanordheim)
-   [Jan Szumiec](http://github.com/jasiek)
-   [Jeff Browning](http://github.com/jbrowning)
-   [Bill Turner](http://github.com/billturner)
-   [Grant Colegate](http://github.com/blaknite)

**Copyright 2008-2013 Zach Inglis, released under the MIT license**
