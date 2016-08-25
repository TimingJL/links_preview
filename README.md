# Learning by Doing 

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)

# Link Preview

In this practice, I'm going to use LinkThumbnailer Rubygems to create a Link Preview App so that after the user add an link, the App can give you back an object containing images and website informations. Works like Facebook link previewer.           

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