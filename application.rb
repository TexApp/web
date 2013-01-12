require 'rubygems'
require 'bundler/setup'
require_relative 'environment'

class TexAppOrg < Sinatra::Base
  set :haml, :format => :html5

  get '/' do
    haml :index
  end
end
