require 'ox'

module UPS
  module Builders

    class PickupBuilder
      attr_accessor :pickup_options,
                    :ups_security,
                    :pickup_creation_request,
                    :pickup_cancel_request,
                    :pickup_pieces                 

      def initialize  
        @pickup_options = {} 
        @ups_security = {}       
        @pickup_creation_request = {}        
        @pickup_cancel_request = {}                

        add_request
        add_rate_pickup_indicator
        add_tax_information_indicator
        add_payment_method
        add_over_weight_indicator
      end      

      def add_security(license_number, user_id, password)
        @ups_security["UPSSecurity"] = {
          "UsernameToken" => {
            "Username" => user_id,
            "Password" => password
          },

          "ServiceAccessToken" => {
            "AccessLicenseNumber" => license_number
          }
        }     
      end

      def add_request
        @pickup_creation_request["Request"] = {
          "TransactionReference" => { 
            "CustomerContext" => "..."
          }          
        }
      end

      def add_rate_pickup_indicator        
        @pickup_creation_request['RatePickupIndicator'] = 'Y'
      end

      def add_tax_information_indicator        
        @pickup_creation_request['TaxInformationIndicator'] = 'Y'
      end

      def add_pickup_date_info(close_time, ready_time, pickup_date)
        @pickup_creation_request["PickupDateInfo"] = {
          "CloseTime" => close_time,
          "ReadyTime" => ready_time,
          "PickupDate" => pickup_date
        }
      end

      def add_pickup_address(opts = {})
        address_line = [ opts[:address_line_1], opts[:address_line_2], opts[:address_line_3] ].join(',')
        @pickup_creation_request["PickupAddress"] = {
          "CompanyName" => opts[:company_name],
          "ContactName" => opts[:name],
          "AddressLine" => address_line,
          "City"  => opts[:city],
          "StateProvince" => opts[:state],
          "PostalCode"  => opts[:postal_code],
          "CountryCode" => opts[:country],
          "ResidentialIndicator" => 'N',          
          "Phone" => {
            "Number"  => opts[:phone_number]
          }
        }
        @pickup_creation_request["SpecialInstruction"]  = opts[:package_location]
      end

      def add_alternate_address_indicator        
        @pickup_creation_request["AlternateAddressIndicator"] = 'N'
      end

      def add_piece(pieces)        
        @pickup_creation_request['PickupPiece'] = pieces.map{ |piece|
          {
            'ServiceCode' => '%03d' % piece[:service_token].to_i,
            'Quantity' => piece[:quantity].to_s,
            'DestinationCountryCode' => piece[:country],
            'ContainerCode' => piece[:packing_type]
          }
        }
      end

      def add_payment_method        
        @pickup_creation_request["PaymentMethod"] = '00'
      end

      def add_over_weight_indicator
        @pickup_creation_request["OverweightIndicator"] = 'N'
      end

      def add_pickup_cancel_request(confirm_number)
        @pickup_cancel_request["Request"] = {
          "TransactionReference" => {
            "CustomerContext" => "cancel pickup"
          }
        }

        @pickup_cancel_request["CancelBy"] = '02'
        @pickup_cancel_request["PRN"] = confirm_number
      end

      def json_pickup_request
        @pickup_options.merge! @ups_security
        @pickup_options.merge!({
          "PickupCreationRequest" => @pickup_creation_request
        })
        @pickup_options.to_json        
      end      

      def json_pickup_cancel_request
        @pickup_options.merge! @ups_security
        @pickup_options.merge!({
          "PickupCancelRequest" => @pickup_cancel_request
        })
        @pickup_options.to_json                
      end

    end
  end
end