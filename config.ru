#\ -p 4000

require "rubygems"
require "bundler/setup"
require "serve"
require "sass/plugin/rack"
require "compass"
require "hashie"

# The project root directory
root = ::File.dirname(__FILE__)

# Compass
Compass.add_project_configuration(root + "/compass.config")
Compass.configure_sass_plugin!

# Middleware
use Rack::ShowStatus # Nice looking 404s and other messages
use Rack::ShowExceptions # Nice looking errors
use Sass::Plugin::Rack # Compile Sass on the fly

# Force SSL
# require "rack/ssl-enforcer"
# use Rack::SslEnforcer, :only_hosts => /\.heroku\.com$/, :strict => true

# Password protection
# use Rack::Auth::Basic, "Restricted Area" do |username, password|
#   valid_credentials = []
#   valid_credentials << ["username1", "password1"]
#   valid_credentials << ["username2", "password2"]
#   valid_credentials.include?([username, password])
# end

# Compass on Heroku
require "fileutils"
FileUtils.mkdir_p(root + "/tmp/stylesheets")
use Rack::Static, :urls => ["/stylesheets"], :root => root + "/tmp"

# Rack Application
run Rack::Cascade.new([
  Serve::RackAdapter.new(root + "/views"),
  Rack::Directory.new(root + "/public")
])

# HAML configuration options
# http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#options
class Haml::Engine
  alias old_initialize initialize
  def initialize(lines, options)
    # options.update(:format => :html5)
    old_initialize(lines, options)
  end
end
