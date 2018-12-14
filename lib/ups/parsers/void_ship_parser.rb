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
        puts "********* value"
        super
        if switch_active?(:VoidShipmentResponse, :Status, :StatusCode)
          puts "********* value11"
          return if switch_active?(:VoidShipmentResponse, :PackageLevelResults)
          puts "*********** value 22"
          puts "*******5"
          self.status = success?(value.as_s)
        elsif switch_active?(:VoidShipmentResponse, :PackageLevelResults)
          puts "*******6"
          parse_package value
        end        
      end

      def parse_package(value)
        puts "*******1"
        if switch_active?(:VoidShipmentResponse, :PackageLevelResults, :TrackingNumber)
          puts "*******2"
          @current_package[:tracking_number] = value.as_s
        elsif switch_active?(:VoidShipmentResponse, :PackageLevelResults, :StatusCode)
          puts "*******3"
          @current_package[:status] = success?(value.as_s)
        end
        puts "*******4"
      end


      def success?(status_code)
        ['1', 1].include? status_code
      end

    end
  end
end
