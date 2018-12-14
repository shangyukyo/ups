# frozen_string_literal: true

require 'ox'

module UPS
  module Builders
    # The {ShipAcceptBuilder} class builds UPS XML ShipAccept Objects.
    #
    # @author Paul Trippett
    # @since 0.1.0
    class VoidShipBuilder < BuilderBase
      include Ox      

      # Initializes a new {ShipAcceptBuilder} object
      #
      def initialize
        # super 'VoidShipmentRequest'
        self.document = Document.new(encoding: 'UTF-8', version: '1.0')        
        self.root = Element.new('VoidShipmentRequest')        
        self.access_request = Element.new('AccessRequest')        
        document << access_request
        document << root                              
        add_request
      end

      def add_request
        self.root << Element.new('Request').tap do |req|
          req << Element.new('TransactionReference').tap do |tr|
            tr << element_with_value('CustomerContext', 'test')
          end

          req << element_with_value('RequestAction', '1')
        end
      end

      # Adds a ShipmentDigest section to the XML document being built
      #
      # @param [String] digest The UPS Shipment Digest returned from the
      #   ShipConfirm request
      # @return [void]
      def add_tracking_number(tracking_number)
        root << element_with_value('ShipmentIdentificationNumber', tracking_number)
      end

      def to_xml
        s = '<?xml version="1.0" encoding="UTF-8"?>'
        s += Ox.to_xml access_request
        s += '<?xml version="1.0" encoding="UTF-8"?>'
        s+= Ox.to_xml root
        s
      end
    end
  end
end
