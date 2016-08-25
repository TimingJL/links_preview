# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

# Link Preview

In this practice, I'm going to use LinkThumbnailer Rubygems to create a Link Preview App so that after the user add a link, the App can give you back an object containing images and website informations. Works like Facebook link previewer.           

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




To be continued...