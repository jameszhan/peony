# Peony

Local Script Management System Using Rake

## Installation

Add this line to your application's Gemfile:

    gem 'peony'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install peony

## Usage
Peony inherits from Rake, and added many useful methods for you to write rake scripts.

If you want to run nginx server on your local server, you can add the following to your Rakefile
    
    set :base_dir, "/opt"
    set_default :www_http_port, 80
    set :www_paths, {
      "/homebrew" => "/Library/Caches/Homebrew"
    }
    set :nginx, "/usr/local/bin/nginx"
    
Execute the following commands 

    peony nginx:init
    peony nginx:www:init
    peony nginx:www:start
    
Then you can check the http://localhost/homebrew


Maybe you just want to use rake, all you just want to use some recipes of peony, 
you can just add the following code to your Rakefile

    require 'peony'
    require 'peony/rake'

    spec = Gem::Specification.find_by_name("peony")
    modules = ["#{spec.gem_dir}/recipes/nginx.rake", "#{spec.gem_dir}/recipes/nginx/www.rake"]
    modules.each do|f|
      load f
    end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


