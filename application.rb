# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require_relative './environment'
require 'barista'
require 'sinatra/partial'
require 'haml'
require 'will_paginate'
require 'will_paginate/data_mapper'
require "will_paginate-bootstrap"

# TODO: memcache? for Rack::Cache?

class TexAppOrg < Sinatra::Base
  register Sinatra::Partial
  include WillPaginate::Sinatra::Helpers

  # automatic CoffeeScript compilation
  register Barista::Integration::Sinatra
  Barista.configure do |b|
    b.root = File.join(root, 'coffeescripts')
  end

  set :haml, { :format => :html5 }

  # citation links
  get %r{^/(\d\d-\d\d-\d\d\d\d.+)} do
    docket_number = params[:captures].first
    md5sum = params[:md5]
    if md5sum && md5sum.length == 32
      filename = "#{docket_number}_#{md5sum}.pdf"
      container = $cloudfiles.container(CONTAINER)
      object = container.object(filename)
      attachment "#{docket_number}.pdf"
      redirect object.public_url
    else
      court_case = Case.first :docket_number => docket_number
      opinions = court_case.opinions
      if opinions.count == 1
        opinion = opinions.first
        filename = "#{court_case.docket_number}_#{opinion.md5sum}.pdf"
        container = $cloudfiles.container(CONTAINER)
        object = container.object(filename)
        attachment "#{docket_number}.pdf"
        redirect object.public_url
      elsif opinions.count > 1
        redirect "/case/#{docket_number}"
      else
        haml :bad_citation
      end
    end
  end

  get "/case/:docket" do
    docket_number = params[:docket]
    @the_case = Case.first :docket_number => docket_number
    haml :case
  end

  get "/court/:court" do
    @court = params[:court].to_i
    @opinions = Opinion.paginate(
      :case => { :court => @court },
      :page => params[:page],
      :order => [:date.desc],
      :per_page => 20
    )
    haml :simple, :locals => {
      :heading => cardinal_name(@court),
      :subheading => CITIES[@court]
    }
  end

  get "/recent" do
    @opinions = Opinion.paginate(
      :order => [:date.desc],
      :page => params[:page],
      :per_page => 20
    )
    haml :simple, :locals => { :heading => 'Recent Opinions' }
  end

  get '/' do haml :index end

  get '/about' do
    haml :markdown, :locals => {
      :heading => 'About',
      :file => 'about.md'
    }
  end

  get '/citation' do
    haml :markdown, :locals => {
      :heading => 'Citation',
      :file => 'citation.md'
    }
  end

  get '/technology' do
    haml :markdown, :locals => {
      :heading => 'Technology',
      :file => 'technology.md'
    }
  end

  get '/search' do
    @query = params[:query]
    redirect "/" unless @query
    @opinions = Opinion.paginate(
      :order => [:date.desc]
    )
    haml :simle, :locals => {
      :heading => 'Search Results',
      :subheading => "“#{@query}”"
    }
  end

  helpers do
    CARDINALS = %w{_ First Second Third Fourth Fifth Sixth Seventh Eigth Ninth Tenth Eleventh Twelfth Thirteenth Fourteenth}

    CITIES = %w{_ Houston Fort\ Worth Austin San\ Antonio Dallas Texarkana Amarillo El\ Paso Beaumont Waco Eastland Tyler Corpus\ Christi/Edinburg Houston}
    def court_name(number)
      cardinal_name(number) + "—#{CITIES[number]}"
    end

    def cardinal_name(number)
      "#{CARDINALS[number]} Court of Appeals"
    end

    MONTHS = %w{_ Jan. Feb. Mar. Apr. May June July Aug. Sept. Oct. Nov. Dec.}
    def bluebook_date(date)
      "#{MONTHS[date.month]} #{date.mday}, #{date.year}"
    end
  end
end
