module Fog
  module Compute
    class ProfitBricks
      class Real
        # Detach a CD-ROM from the server
        #
        # ==== Parameters
        # * datacenter_id<~String> - UUID of the data center
        # * server_id<~String>      - UUID of the virtual server
        # * cdrom_id<~String>       - UUID of the CD-ROM image
        #
        # ==== Returns
        # * response<~Excon::Response> - No response parameters
        #   (HTTP/1.1 202 Accepted)
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#detach-a-cd-rom]
        def detach_cdrom(datacenter_id, server_id, cdrom_id)
          request(
              :expects => [202],
              :method  => 'DELETE',
              :path    => "/datacenters/#{datacenter_id}/servers/#{server_id}/cdroms/#{cdrom_id}"
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def detach_cdrom(datacenter_id, server_id, cdrom_id)
          response = Excon::Response.new
          response.status = 202

          if server = self.data[:servers]['items'].find {
              |serv|  serv['datacenter_id'] == datacenter_id && serv['id'] == server_id
          }
          else
            raise Fog::Errors::NotFound.new("The server resource could not be found")
          end

          if cdrom = server['entities']['cdroms']['items'].find {
              |cd|  cd['id'] == cdrom_id
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
