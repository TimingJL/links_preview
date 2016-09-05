# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

# Link Preview

In this practice, I'm going to use LinkThumbnailer Rubygems to create a Link Preview App so that after the user add a link, the App can give you back an object containing images and website informations.            


https://github.com/gottfrois/link_thumbnailer


![image](https://github.com/TimingJL/links_preview/blob/master/pic/show_styling.jpeg)



# Create a App
```console
$ rails new link_preview
```

# Add some rubygems we're going to use
In Gemfile
```console
gem 'therubyracer'
gem 'haml', '~>4.0.5'
gem 'bootstrap-sass', '~> 3.2.0.2'
gem 'simple_form', github: 'kesha-antonov/simple_form', branch: 'rails-5-0'
gem 'link_thumbnailer'
```

Note: 
Because there is no Javascript interpreter for Rails on Ubuntu Operation System, we have to install `Node.js` or `therubyracer` to get the Javascript interpreter.

Run:
```console
$ rails g link_thumbnailer:install
```


# CRUD
First thing we need to do is create a controller and a model.
```console
$ rails g controller Links

$ rails g model Link title:string link:string favicon:string description:text image:string
$ rake db:migrate
```

Then we have to add the rule of routes.
In `config/routes.rb`
```ruby
Rails.application.routes.draw do
  resources :links

  root 'links#index'
end
```


And in `app/controllers/links_controller.rb`
```ruby
class LinksController < ApplicationController
    before_action :find_link, only: [:show, :edit, :update, :destroy]

    def index
        @links = Link.all.order("created_at DESC")
    end

    def show
    end

    def new
        @link = Link.new
    end

    def create
        @link = Link.new(link_params)
 
        require 'link_thumbnailer'
        object = LinkThumbnailer.generate(@link.link)

        @link.title = object.title
        @link.favicon = object.favicon
        @link.description = object.description
        @link.image = object.images.first.src.to_s

        if @link.save
            redirect_to @link
        else
            render 'new'
        end
    end

    def edit
    end

    def update 		 	
	    if @link.update(link_params)
			require 'link_thumbnailer'
			object = LinkThumbnailer.generate(@link.link)

			@link.title = object.title
			@link.favicon = object.favicon
			@link.description = object.description
			@link.image = object.images.first.src.to_s
			@link.save	    
				
	        redirect_to @link
	    else
	        render 'edit'
	    end    	
    end

	def destroy
	    @link.destroy
	    redirect_to links_path
	end

    private

    def find_link
        @link = Link.find(params[:id])
    end

    def link_params
        params.require(:link).permit(:link)
    end
end
```

Let's create some views in `app/views/links`         
1. _form.html.haml       
2. edit.html.haml         
3. index.html.haml         
4. new.html.haml         
5. show.html.haml        


In `app/views/index.html.haml`, we loop through all of the links we added.
```haml
- @links.each do |link|
    %h2= link_to link.title, link
    %p= link_to link.link, link.link

= link_to 'New Link', new_link_path
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/index2.jpeg)


And we define our form in the partial `app/views/_form.html.haml`.
```haml
= simple_form_for @link do |f|
    = f.input :link
    = f.button :submit
= link_to 'Cancel',  root_path 
```

In `app/views/new.html.haml`
```haml
%h1 Add New Link

= render 'form'
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/new2.jpeg)

In `app/views/edit.html.haml`
```haml
%h1 Edit Link

= render 'form'
= link_to 'Cancel',  root_path
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/edit_page.jpeg)


After we add the link, we show up the details in the show page `app/views/show.html.haml`
```haml
%h1= @link.title
	
%p
	Link:
	= @link.link
%p
	favicon:
	= @link.favicon
%p
	Description:
	= @link.description
%p
	Image URL:
	= @link.image

= link_to 'Edit',  edit_link_path(@link)
= link_to 'Delete', link_path(@link), method: :delete, data: { confirm: 'Are you sure?' }
= link_to 'Home',  root_path
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/show_page.jpeg)




# Embed Responsive YouTube Video
Next thing we wanna do is embed youtube video inside of our show page.         
http://blog.41studio.com/embed-responsive-youtube-video-in-rails-4/         

So we have to extract file name from user input.        
In `app/view/links/show.html.haml`
```haml
%h1= @link.title
%iframe{:src => "//www.youtube.com/embed/" + @link.link.split("=").last}
%p
	Link:
	= @link.link
%p
	favicon:
	= @link.favicon
%p
	Description:
	= @link.description
%p
	= link_to 'Edit',  edit_link_path(@link)
	= link_to 'Delete', link_path(@link), method: :delete, data: { confirm: 'Are you sure?' }
	= link_to 'Home',  root_path
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/show_embed.jpeg)


And we add the image to be a link to link to the show page.        
In `app/views/links/index.html.haml`
```haml
- @links.each do |link|
    %h2= link_to link.title, link   
    %p= link_to (image_tag link.image, height: 100), link
    %p= link_to link.link, link.link

= link_to 'New Link', new_link_path
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/index_image.jpeg)


# Basic Styling

### Masonry
Masonry is a light-weight layout framework which wraps AutoLayout with a nicer syntax.          

https://github.com/kristianmandrup/masonry-rails        

Let's go to our Gemfile, we need a gem called masonry-rails.            
In Gemfile, we add this line, run bundle install and restart the server.
```console
gem 'masonry-rails', '~> 0.2.1'
```

In app/assets/javascripts/application.js, under jquery, we add `//= require masonry/jquery.masonry`
```js
//= require jquery
//= require jquery_ujs
//= require masonry/jquery.masonry
//= require turbolinks
//= require_tree .
```

To get this work, I'm going to add some styling and coffescript. In app/assets/javascripts/pin.coffee
```coffee
$ ->
  $('#links').imagesLoaded ->
    $('#links').masonry
      itemSelector: '.box'
      isFitWidth: true
```

And in `app/assets/stylesheets/application.css.scss`
```scss
/*
 * This is a manifest file that'll be compiled into application.css, which will include all the files
 * listed below.
 *
 * Any CSS and SCSS file within this directory, lib/assets/stylesheets, vendor/assets/stylesheets,
 * or any plugin's vendor/assets/stylesheets directory can be referenced here using a relative path.
 *
 * You're free to add application-wide styles to this file and they'll appear at the bottom of the
 * compiled file so the styles you add here take precedence over styles defined in any other CSS/SCSS
 * files in this directory. Styles in this file should be added after the last require_* statement.
 * It is generally better to create a new file per style scope.
 *
 *= require 'masonry/transitions'
 *= require_tree .
 *= require_self
 */

#links {
  margin: 0 auto;
  width: 100%;
  .box {
      margin: 10px;
      width: 350px;
      box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.22);
      border-radius: 7px;
      text-align: center;
      text-decoration:none;
      img {
        max-width: 100%;
        height: 200px;
      }
      h2 {
        font-size: 22px;
        margin: 0;
        padding: 20px 10px;
        a {
                color: #474747;
                text-decoration:none;
        }
      }
    }
}

textarea {
    min-height: 250px;
}
```

And in `app/views/links/index.html.haml`
```haml
#links.transitions-enabled
    - @links.each do |link|
        .box.panel.panel-default
            - if link.image.present?
                =link_to (image_tag link.image, width: '100%'), link
            - else
                =link_to link.title, link
            .panel-body
                %h2= link_to link.title, link
=link_to "New", new_link_path, class: "btn btn-default"
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/masonry.jpeg)


### Bootstrap Setup
We need to rename the `application.css` to `application.css.scss`, and import bootstrap styles in `app/assets/stylesheets/application.css.scss`
```scss
@import "bootstrap-sprockets";
@import "bootstrap";
```

And we need to require bootstrap-sprockets within the `app/assets/javascripts/application.js`
```js
//= require jquery
//= require bootstrap-sprockets
```

### Bootstrap RWD Navbar
https://getbootstrap.com/components/#navbar            

We need to rename the `application.html.erb` to `application.html.haml` in `app/views/layouts` and tweak the code to
```haml
!!!
%html
  %head
    %meta{:content => "text/html; charset=UTF-8", "http-equiv" => "Content-Type"}/
    %title LinksPreview
    = csrf_meta_tags
    = stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload'
    = javascript_include_tag 'application', 'data-turbolinks-track': 'reload'
  %body
    %nav.navbar.navbar-inverse
      .container-fluid
        / Brand and toggle get grouped for better mobile display
        .navbar-header
          %button.navbar-toggle.collapsed{"aria-expanded" => "false", "data-target" => "#bs-example-navbar-collapse-1", "data-toggle" => "collapse", :type => "button"}
            %span.sr-only Toggle navigation
            %span.icon-bar
            %span.icon-bar
            %span.icon-bar
          %a.navbar-brand{:href => root_path} Home
        / Collect the nav links, forms, and other content for toggling
        #bs-example-navbar-collapse-1.collapse.navbar-collapse
          %ul.nav.navbar-nav.navbar-left
            = form_tag search_links_path, method: :get, class: "navbar-form", role: "search" do
              .input-group
                = text_field_tag :search, params[:search], class: "form-control",:placeholder => "Search"  
                %span.input-group-btn
                  %button.btn.btn-default{:type => "submit"} 
                    %span.glyphicon.glyphicon-search   
          %ul.nav.navbar-nav.navbar-right
            %li
              %a{:href => new_link_path} New
            %li.dropdown
              %a.dropdown-toggle{"aria-expanded" => "false", "aria-haspopup" => "true", "data-toggle" => "dropdown", :href => "#", :role => "button"}
                %span.glyphicon.glyphicon-cog{"aria-hidden" => "true"}
              %ul.dropdown-menu
                %li
                  %a{:href => "#"} Log In
                %li
                  %a{:href => "#"} Edit
                %li
                  %a{:href => "#"} Sign Up
                %li.divider{:role => "separator"}
                %li
                  %a{:href => "#"} Log Out
        / /.navbar-collapse
      / /.container-fluid
    = yield
```

And in `app/views/links/index.html.haml`, we remove the following code because it has exited in navbar.
```haml
=link_to "New", new_link_path, class: "btn btn-default"
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/navbar.jpeg)


### Show Page Styling
In `app/assets/stylesheets/application.css.scss`, we add
```scss
#link_show {
    .link_image {
        img {
            max-width: 100%;
            width: 100%;
            display: block;
            margin: 0 auto;
        }
    }
    .panel-body {
        padding: 35px;
        h1 {
            margin: 0 0 10px 0;
        }
        .description {
            color: #868686;
            line-height: 1.75;
            margin: 0;
        }
    }
    .panel-footer {
        padding: 20px 35px;
        p {
            margin: 0;
        }
        .user {
            padding-top: 8px;
        }
    }  
}
```

And in `app/views/links/show.html.haml`, we tweak the code to the following
```haml
#link_show.row
    .col-md-6.col-md-offset-3
        .panel.panel-default
            %iframe{:frameborder => "0",:height => "510", :width => "100%", :src => "//www.youtube.com/embed/" + @link.link.split("=").last}
            .panel-body
                %h1= @link.title
                %p.description= @link.description
            .panel-footer
                = link_to "Edit", edit_link_path, class: "btn btn-default"
                = link_to "Delete", link_path, method: :delete, data: { confirm: "Are you sure?" }, class: "btn btn-default"
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/show_styling.jpeg)

### Form Styling
In `app/assets/stylesheets/application.css.scss`, we add
```scss
.input {
    width: 100%;
    font-size: 28px;
    margin: 0px 8;
    box-sizing: border-box;
}
.button {
    background-color: #4CAF50; /* Green */
    border: none;
    color: white;
    padding: 10px 32px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    width:100%;
}
.center{
  margin: 0px auto;
  text-align: center;
}
h1 {
    font-size: 36px;
    font-weight: normal;
    color: #4CAF50;
}
```

In `app/views/links/_form.html.haml`
```haml
= simple_form_for @link do |f|
    = f.input :link, input_html: { class: 'input' }
    = f.button :submit, class: ".button"
%br
= link_to 'Cancel',  root_path, class: "btn btn-default add-button"
```

In `app/views/links/edit.haml`
```haml
#link_show.row
    .col-md-8.col-md-offset-2
        .panel.panel-default
            .panel-body
                %h1.center Edit Link

                = render 'form'
```


In `app/views/links/new.haml`
```haml
#link_show.row
    .col-md-8.col-md-offset-2
        .panel.panel-default
            .panel-body
                %h1.center Add New Link

                = render 'form'
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/styling_form.jpeg)


# Search
We're going to use a gem called searchkick.             
https://github.com/ankane/searchkick

### How To Install and Configure Elasticsearch on Ubuntu 16.04
https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-16-04 https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-ubuntu-16-04           

To do so, we gonna need java.
```
# Add the Oracle Java PPA to apt:
$ sudo add-apt-repository -y ppa:webupd8team/java

# Update your apt package database:
$ sudo apt-get update

# Install the latest stable version of Oracle Java 8 with this command (and accept the license agreement that pops up):
$ sudo apt-get -y install oracle-java8-installer
```

Next thing we need to do is install elasticsearch.
```
# Elasticsearch can be installed with a package manager by adding Elastic's package source list.
# Run the following command to import the Elasticsearch public GPG key into apt:
$ wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

# Create the Elasticsearch source list:
$ echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list

# Update the apt package database again:
$ sudo apt-get update

# Install Elasticsearch with this command:
$ sudo apt-get -y install elasticsearch

# Elasticsearch is now installed. Let's edit the configuration:
$ sudo vim /etc/elasticsearch/elasticsearch.yml

# In /etc/elasticsearch/elasticsearch.yml excerpt (updated)
$ network.host: localhost

# Now, start Elasticsearch:
$ sudo systemctl restart elasticsearch

# Then, run the following command to start Elasticsearch on boot up:
$ sudo systemctl daemon-reload
$ sudo systemctl enable elasticsearch
```
After installing and loading Elasticsearch, You go to `http://localhost:9200/`, it should print out:              
```
{
  "name" : "Plug",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "2.3.5",
    "build_hash" : "90f439ff60a3c0f497f91663701e64ccd01edbb4",
    "build_timestamp" : "2016-07-27T10:36:52Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.0"
  },
  "tagline" : "You Know, for Search"
}
```
That will confirm that is installed correctly.

### Searchkick
Then we need to install `searchkick` gems and restart the server. So in our `Gemfile`, we add:
```
gem 'searchkick', '~> 0.7.1'
```
Note:          
Error when reindexing after upgrade to 0.8.2. Downgrading to 0.7.1 "fixed" the problem.         

Then we need to add the line searchkick to our link's model.         
In `app/models/link.rb`
```ruby
class Link < ApplicationRecord
    validates :link, presence: true
    searchkick highlight: [:title, :description]
end
```

Next, we need to load reindex all of the links from our database.
```console
$ rake searchkick:reindex CLASS=Link
```

Next, we need to add a route for our search.          
In `config/routes.rb`
```ruby
Rails.application.routes.draw do
    resources :links do
        collection do
            get 'search'
        end
    end

  root 'links#index'
end
```
Now, we need to add a search method within our controller.          
In `app/controllers/links_controller.rb`
```ruby

    def search
        query = params[:search].presence || "*"
        @links = Post.search(query, fields: [:title, :description], highlight: {tag: "<strong>"})
    end
```

In `app/assets/stylesheets/application.css.scss`, we add the following css for highlight
```scss
strong { 
    color: red;
    background-color: yellow;
}
```

Then we need to create a view for our search. So under `app/views/links/`, we create a new file and save it as `search.html.haml`
```haml
#links.transitions-enabled
    - @links.with_details.each do |link, details|
        .box.panel.panel-default
            - if link.image.present?
                =link_to (image_tag link.image, width: '100%'), link
            - else
                %h2= link_to simple_format(details[:highlight][:title]), link
            .panel-body
                -if !details[:highlight][:title].present?
                    %h2= link_to link.title, link
                -else
                    %h2= link_to simple_format(details[:highlight][:title]), link
            .panel-footer
                -if !details[:highlight][:description].present?
                -else
                    %p= link_to simple_format(details[:highlight][:description]), link
```
![image](https://github.com/TimingJL/links_preview/blob/master/pic/searchkick.jpeg)

Note:         
Remember to add `simple_format`, or the html highlight tag might not work.         



To be continued...