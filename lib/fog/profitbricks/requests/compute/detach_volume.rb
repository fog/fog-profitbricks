module Fog
  module Compute
    class ProfitBricks
      class Real
        # Detach the volume from the server. Depending on the volume "HotUnplug" settings,
        # this may result in the server being rebooted.
        #
        # ==== Parameters
        # * datacenter_id<~String> - UUID of the data center
        # * server_id<~String>      - UUID of the virtual server
        # * volume_id<~String>      - UUID of the virtual storage
        #
        # ==== Returns
        # * response<~Excon::Response> - No response parameters
        #   (HTTP/1.1 202 Accepted)
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#detach-a-volume]
        def detach_volume(datacenter_id, server_id, volume_id)
          request(
              :expects => [202],
              :method  => 'DELETE',
              :path    => "/datacenters/#{datacenter_id}/servers/#{server_id}/volumes/#{volume_id}"
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def detach_volume(datacenter_id, server_id, volume_id)
          response = Excon::Response.new
          response.status = 202

          if server = self.data[:servers]['items'].find {
              |serv|  serv['datacenter_id'] == datacenter_id && serv['id'] == server_id
          }
          else
            raise Fog::Errors::NotFound.new("The server resource could not be found")
          end

          if volume = server['entities']['volumes']['items'].find {
              |vlm|  vlm['id'] == volume_id
          }
          else
            raise Fog::Errors::NotFound.new("The attached volume resource could not be found")
          end

          response
        end
      end
    end
  end
end
