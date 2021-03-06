# frozen_string_literal: true

require 'uri'
require 'typhoeus'
require 'digest/md5'
require 'ox'
require 'rest-client'

module UPS
  # The {Connection} class acts as the main entry point to performing rate and
  # ship operations against the UPS API.
  #
  # @author Paul Trippett
  # @abstract
  # @since 0.1.0
  # @attr [String] url The base url to use either TEST_URL or LIVE_URL
  class Connection
    attr_accessor :url

    TEST_URL = 'https://wwwcie.ups.com'
    LIVE_URL = 'https://onlinetools.ups.com'

    #JSON 
    # TEST_URL = 'https://wwwcie.ups.com/webservices/'
    # LIVE_URL = 'https://onlinetools.ups.com/webservices/'


    RATE_PATH = '/ups.app/xml/Rate'    
    SHIP_CONFIRM_PATH = '/ups.app/xml/ShipConfirm'
    SHIP_ACCEPT_PATH = '/ups.app/xml/ShipAccept'
    VOID_SHIP_PATH = '/ups.app/xml/Void'
    ADDRESS_PATH = '/ups.app/xml/XAV'
    PICKUP_PATH = '/rest/Pickup'
    TRACK_PATH  = '/rest/Track'

    DEFAULT_PARAMS = {
      test_mode: false
    }.freeze

    # Initializes a new {Connection} object
    #
    # @param [Hash] params The initialization options
    # @option params [Boolean] :test_mode If TEST_URL should be used for
    #   requests to the UPS URL
    def initialize(params = {})
      params = DEFAULT_PARAMS.merge(params)
      self.url = params[:test_mode] ? TEST_URL : LIVE_URL
    end

    # Makes a request to fetch Rates for a shipment.
    #
    # A pre-configured {Builders::RateBuilder} object can be passed as the first
    # option or a block yielded to configure a new {Builders::RateBuilder}
    # object.
    #
    # @param [Builders::RateBuilder] rate_builder A pre-configured
    #   {Builders::RateBuilder} object to use
    # @yield [rate_builder] A RateBuilder object for configuring
    #   the shipment information sent
    def rates(rate_builder = nil)      
      if rate_builder.nil? && block_given?
        rate_builder = UPS::Builders::RateBuilder.new
        yield rate_builder
      end         
      
      response = get_response_stream RATE_PATH, rate_builder.to_xml
      UPS::Parsers::RatesParser.new.tap do |parser|        
        Ox.sax_parse(parser, response)
      end
    end

    def pickup(pickup_builder = nil)      
      if pickup_builder.nil? && block_given?
        pickup_builder = UPS::Builders::PickupBuilder.new
        yield pickup_builder
      end         
      
      puts pickup_builder.json_pickup_request
      get_json_response PICKUP_PATH, pickup_builder.json_pickup_request
    end

    def pickup_cancel(pickup_builder = nil)      
      if pickup_builder.nil? && block_given?
        pickup_builder = UPS::Builders::PickupBuilder.new
        yield pickup_builder
      end
      
      get_json_response PICKUP_PATH, pickup_builder.json_pickup_cancel_request
    end


    def track(track_builder = nil)
      if track_builder.nil? && block_given?
        track_builder = UPS::Builders::TrackBuilder.new
        yield track_builder
      end         
      
      puts track_builder.json_track_request
      get_json_response TRACK_PATH, track_builder.json_track_request
    end
    # Makes a request to ship a package
    #
    # A pre-configured {Builders::ShipConfirmBuilder} object can be passed as
    # the first option or a block yielded to configure a new
    # {Builders::ShipConfirmBuilder} object.
    #
    # @param [Builders::ShipConfirmBuilder] confirm_builder A pre-configured
    #   {Builders::ShipConfirmBuilder} object to use
    # @yield [ship_confirm_builder] A ShipConfirmBuilder object for configuring
    #   the shipment information sent
    def ship(confirm_builder = nil)      
      if confirm_builder.nil? && block_given?        
        confirm_builder = Builders::ShipConfirmBuilder.new        
        yield confirm_builder        
      end      
      
      confirm_response = make_confirm_request(confirm_builder)  
      return confirm_response unless confirm_response.success?      
      accept_builder = build_accept_request_from_confirm(confirm_builder,
                                                         confirm_response)
      make_accept_request accept_builder      
    end

    def void(void_ship_builder = nil)
      if void_ship_builder.nil? && block_given?
        void_ship_builder = UPS::Builders::VoidShipBuilder.new
        yield void_ship_builder
      end         
      

      response = get_response_stream VOID_SHIP_PATH, void_ship_builder.to_xml
      UPS::Parsers::VoidShipParser.new.tap do |parser|        
        Ox.sax_parse(parser, response)
      end   
    end

    private

    def build_url(path)  
      puts url
      puts "***** url"    
      "#{url}#{path}"
    end

    def get_response_stream(path, body)            
      response = Typhoeus.post(build_url(path), body: body)                  
      StringIO.new(response.body)
    end

    def get_json_response(path, body)
      response = RestClient.post(build_url(path), body)
      JSON.parse(response)
    end

    def make_confirm_request(confirm_builder)
      make_ship_request confirm_builder,
                        SHIP_CONFIRM_PATH,
                        Parsers::ShipConfirmParser.new
    end

    def make_accept_request(accept_builder)
      make_ship_request accept_builder,
                        SHIP_ACCEPT_PATH,
                        Parsers::ShipAcceptParser.new
    end

    def make_ship_request(builder, path, ship_parser)              
      response = get_response_stream path, builder.to_xml            
      
      ship_parser.tap do |parser|
        Ox.sax_parse(parser, response)
      end
    end

    def build_accept_request_from_confirm(confirm_builder, confirm_response)
      UPS::Builders::ShipAcceptBuilder.new.tap do |builder|
        builder.add_access_request confirm_builder.license_number,
                                   confirm_builder.user_id,
                                   confirm_builder.password
        builder.add_shipment_digest confirm_response.shipment_digest        
      end
    end
  end
end
