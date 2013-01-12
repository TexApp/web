require 'rubygems'
require 'bundler/setup'
require 'rack/cache'
require 'haml'
require_relative './environment'

class TexAppOrg < Sinatra::Base
  set :haml, {:format => :html5}

  # citation links
  get %r{^/(\d\d-\d\d-\d\d\d\d.+)$} do
    docket_number = params[:captures].first
    opinions = Opinion.all(:number => docket_number)
    # on matching opinion:
    # redirect to CloudFiles
    if opinions.count == 1
      opinion = opinions.first
      container = $cloudfiles.container(CONTAINER)
      object = container.object(opinion.filename)
      redirect object.public_url
    # more than one opinion:
    # show all opinions for case
    elsif opinions.count > 1
      redirect "/opinions/#{docket_number}"
    # no matching opinion
    else
      haml :bad_citation
    end
  end

  get "/opinions/:docket" do
    docket_number = params[:docket]
    @the_case = Case.first(:number => docket_number)
    haml :opinions
  end

  get '/' do
    haml :index
  end

  get '/about' do
    haml :about
  end
end
