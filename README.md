# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

# Link Preview

In this practice, I'm going to use LinkThumbnailer Rubygems to create a Link Preview App so that after the user add a link, the App can give you back an object containing images and website informations.            


https://github.com/gottfrois/link_thumbnailer




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
          %form.navbar-form.navbar-left
            .form-group
              %input.form-control{:placeholder => "Search", :type => "text"}/
            %button.btn.btn-default{:type => "submit"} Submit
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

To be continued...