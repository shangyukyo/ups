# frozen_string_literal: true

module UPS
  module Parsers
    class VoidShipParser < ParserBase
      attr_accessor :status, :package_level_results

      def initialize
        super
        self.package_level_results = []
        @current_package = {}
      end

      def start_element(name)          
        super
      end

      def end_element(name)        
        super
        return unless name == :PackageLevelResults
        self.package_level_results << @current_package
        @current_package = {}        
      end        

      def value(value)        
        super
        if switch_active?(:VoidShipmentResponse, :Status, :StatusCode)          
          return if switch_active?(:VoidShipmentResponse, :PackageLevelResults)
          self.status = success?(value.as_s)
        elsif switch_active?(:VoidShipmentResponse, :PackageLevelResults)          
          parse_package value
        end        
      end

      def parse_package(value)        
        if switch_active?(:VoidShipmentResponse, :PackageLevelResults, :TrackingNumber)          
          @current_package[:tracking_number] = value.as_s
        elsif switch_active?(:VoidShipmentResponse, :PackageLevelResults, :StatusCode)          
          @current_package[:status] = success?(value.as_s)
        end        
      end


      def success?(status_code)
        ['1', 1].include? status_code
      end

    end
  end
end
