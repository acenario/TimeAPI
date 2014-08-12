require 'rubygems'
require 'sinatra'
require 'chronic'
require 'date'
require 'cgi'

ENV['RACK_ENV'] ||= "development"
ENV['TIMEAPI_MIME'] ||= "text/plain"

module TimeAPI
  
  class App < Sinatra::Base
 
    configure do 
      disable :sessions
      set :environment, ENV['RACK_ENV']
    end

    helpers do
      # convert zone to offset
      def z2o(zone)
        offsets = { 
    'A' => +1,
    'ACDT' => +10.5,
    'ACST' => +9.5,
    'ADT' => -3,
    'AEDT' => +11,
    'AEST' => +10,
    'AFT' => +4.5,
    'AKDT' => -8,
    'AKST' => -9,
    'AST' => -4,
    'B' => +2,
    'BST' => +1,
    'C' => +3,
    'CDT' => -5,
    'CEDT' => +2,
    'CEST' => +2,
    'CET' => +1,
    'CST' => -6,
    'D' => +4,
    'E' => +5,
    'EDT' => -4,
    'EEDT' => +3,
    'EEST' => +3,
    'EET' => +2,
    'EST' => -5,
    'F' => +6,
    'G' => +7,
    'GMT' => 0,
    'H' => +8,
    'HADT' => -9,
    'HAST' => -10,
    'I' => +9,
    'IST' => +5.5,
    'K' => +10,
    'L' => +11,
    'M' => +12,
    'MDT' => -6,
    'MSD' => +4,
    'MSK' => +3,
    'MST' => -7,
    'N' => -1,
    'O' => -2,
    'P' => -3,
    'PDT' => -7,
    'PST' => -8,
    'Q' => -4,
    'R' => -5,
    'S' => -6,
    'T' => -7,
    'U' => -8,
    'UTC' => 0,
    'V' => -9,
    'W' => -10,
    'WEDT' => +1,
    'WEST' => +1,
    'WET' => 0,
    'X' => -11,
    'Y' => -12,
    'Z' => 0
 }
        offsets[zone ? zone.upcase : "UTC"]
      end  
    end  
  
    get '/' do
      erb :index
    end

    post '/' do
      throw :halt, [400, "Bad request, missing 'dt' parameter"] unless params[:dt]
      content_type ENV['TIMEAPI_MIME']
      offset = z2o(params[:zone])
      Time.new.utc.to_datetime.new_offset(Rational(offset, 24)).to_s
    end
    
    get '/favicon.ico' do
      ''
    end
    
    get '/:zone' do
      content_type ENV['TIMEAPI_MIME']
      offset = z2o(params[:zone])
      Time.new.utc.to_datetime.new_offset(Rational(offset,24)).to_s
    end
    
    get '/:zone/:time' do
      offset = z2o(params[:zone])
      result = Chronic.parse(CGI.unescape(params[:time]),:now=>Time.new.utc.to_datetime.new_offset(Rational(offset,24)))
      throw :halt, [400, "Bad request"] unless result
      content_type ENV['TIMEAPI_MIME']
      result.to_datetime.new_offset(Rational(offset,24)).to_s
    end

    # start the server if ruby file executed directly
    run! if app_file == $0  
  end
end

class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

class DateTime
  def to_datetime
    self
  end
end
