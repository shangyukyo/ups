# frozen_string_literal: true

require 'base64'
require 'tempfile'

module UPS
  module Parsers
    class ShipAcceptParser < ParserBase
      attr_accessor :label_url,
                    :form,
                    :package_results,
                    :identification_number

      def initialize
        super
        self.package_results = []        
        self.form = {}
        @current_package = {}        
      end

      def start_element(name)  
        super
      end

      def end_element(name)        
        super
        return unless name == :PackageResults
        package_results << @current_package
        @current_package = {}
      end      

      # def value(value)
      #   parse_graphic_image(value)
      #   parse_html_image(value)
      #   parse_tracking_number(value)
      #   parse_graphic_extension(value)
      #   super
      # end

      def value(value)
        super
        if switch_active?(:ShipmentResults, :PackageResults)
          parse_package value
        end

        if switch_active?(:ShipmentResults, :Form)
          parse_form value
        end

        if switch_active?(:ShipmentResults, :ShipmentIdentificationNumber)
          parse_identification_number value
        end

        if switch_active?(:ShipmentResults, :LabelURL)
          parse_label_url value
        end
      end  


      def parse_package(value)
        if switch_active?(:PackageResults, :LabelImage, :GraphicImage)
          @current_package[:graphic_image] = value.as_s
        end

        if switch_active?(:PackageResults, :LabelImage, :HTMLImage)
          @current_package[:html_image] = value.as_s
        end

        if switch_active?(:PackageResults, :LabelImage, :InternationalSignatureGraphicImage)
          @current_package[:signature_image] = value.as_s
        end

        if switch_active?(:PackageResults, :TrackingNumber)
          @current_package[:tracking_number] = value.as_s
        end

        if switch_active?(:PackageResults, :LabelImage, :LabelImageFormat, :Code)
          @current_package[:graphic_extension] = value.as_s
        end
      end  

      def parse_form(value)  
        if switch_active?(:Form, :Image, :GraphicImage)
          self.form[:graphic_image] = value.as_s
        end

        if switch_active?(:Form, :Image, :ImageFormat, :Code)
          self.form[:image_format] = value.as_s
        end
      end

      def parse_identification_number(value)        
        self.identification_number = value.as_s        
      end

      def parse_label_url(value)        
        self.label_url = value.as_s                
      end


      def base64_to_file(contents)
        file_config = ['ups', @current_package[:graphic_extension] ]
        Tempfile.new(file_config, nil, encoding: 'ascii-8bit').tap do |file|
          begin
            file.write Base64.decode64(contents)
          ensure
            file.rewind
          end
        end        
      end
    end
  end
end
