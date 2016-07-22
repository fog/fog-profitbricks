module Fog
  module Compute
    class ProfitBricks
      class Real
        # Deletes the specified IP Block
        #
        # ==== Parameters
        # * ip_block_id<~String> - UUID of the IP Block
        #
        # ==== Returns
        # * response<~Excon::Response> - No response parameters
        #   (HTTP/1.1 202 Accepted)
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#delete-ip-block]
        def delete_ip_block(ip_block_id)
          request(
              :expects => [202],
              :method  => 'DELETE',
              :path    => "/ipblocks/#{ip_block_id}"
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def delete_ip_block(ip_block_id)
          response = Excon::Response.new
          response.status = 202

          if ip_block = self.data[:ip_blocks]["items"].find {
              |attribute| attribute["id"] == ip_block_id
          }
          else
            raise Fog::Errors::NotFound.new("The requested IP Block could not be found")
          end

          response
        end
      end
    end
  end
end