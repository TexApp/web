require 'rubygems'
require 'bundler/setup'
require 'rack/cache'
require_relative 'environment'

use Rack::Cache do
  set :metastore, 'heap:/'
  set :entitystore, 'heap:/'
end

class TexAppOrg < Sinatra::Base
  set :haml, :format => :html5

  get '/' do
    haml :index
  end
end
