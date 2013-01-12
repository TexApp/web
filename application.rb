# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'barista'
require 'sinatra/partial'
require 'haml'
require_relative './environment'

# TODO: memcache? for Rack::Cache?

class TexAppOrg < Sinatra::Base
  register Sinatra::Partial

  # automatic CoffeeScript compilation
  register Barista::Integration::Sinatra
  Barista.configure do |b|
    b.root = File.join(root, 'coffeescripts')
  end

  set :haml, { :format => :html5 }

  # citation links
  get %r{^/(\d\d-\d\d-\d\d\d\d.+)} do
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

  get "/court/:court" do
    @court = params[:court].to_i
    @opinions = Opinion.all(
      :number.like => format("%02d-%", @court),
      :order => [:date.desc]
    )
    haml :court
  end

  get '/' do haml :index end

  get '/about' do haml :about end

  get "/citation" do haml :citation end

  get "/technology" do haml :citation end

  get '/search' do
    @query = params[:query]
    # TODO: Implement search
    @results = []
    haml :search
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
