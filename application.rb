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
    @opinions = Opinion.all(:case => { :court => @court })
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
    CARDINALS = 

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
