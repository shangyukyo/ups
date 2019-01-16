require 'ox'

module UPS
  module Builders

    class TrackBuilder
      attr_accessor :track_request,
                    :ups_security             

      def initialize          
        @ups_security = {}
        @track_request = {} 
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

      def add_track_request(tracking_number)
        @track_request["TrackRequest"] = {          
          "Request": {
            "RequestOption": "15",
            "TransactionReference": {
              "CustomerContext": "..."
            }
          },
          "InquiryNumber": tracking_number,
          "TrackingOption": "02"
        }
        
      end

      def json_track_request
        {}.merge(@ups_security).merge(@track_request).to_json                
      end

    end
  end
end