module Fog
  module Compute
    class ProfitBricks
      class Real
        # Attach a CD-ROM to an existing server.
        #
        # ==== Parameters
        # * datacenter_id          - Required - The unique ID of the data center
        # * server_id<~String>      - Required - The unique ID of the server
        # * cdrom_image_id<~String> - Required - The unique ID of a CD-ROM image
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * id<~String>                   - The resource's unique identifier
        #     * type<~String>                 - The type of the requested resource
        #     * href<~String>                 - URL to the object’s representation (absolute path)
        #     * metadata<~Hash>               - Hash containing the image metadata
        #       * createdDate<~String>        - The date the resource was created
        #       * createdBy<~String>          - The user who created the resource
        #       * etag<~String>               - The etag for the resource
        #       * lastModifiedDate<~String>   - The last time the resource has been modified
        #       * lastModifiedBy<~String>     - The user who last modified the resource
        #       * state<~String>              - Volume state
        #     * properties<~Hash>             - Hash containing the volume properties
        #       * name<~String>               - The name of the image
        #       * description<~String>        - The description of the image
        #       * location<~String>           - The image's location
        #       * size<~Integer>              - The size of the image in GB
        #       * cpuHotPlug<~Boolean>        - This image is capable of CPU hot plug (no reboot required)
        #       * cpuHotUnplug<~Boolean>      - This image is capable of CPU hot unplug (no reboot required)
        #       * ramHotPlug<~Boolean>        - This image is capable of memory hot plug (no reboot required)
        #       * ramHotUnplug<~Boolean>      - This image is capable of memory hot unplug (no reboot required)
        #       * nicHotPlug<~Boolean>        - This image is capable of nic hot plug (no reboot required)
        #       * nicHotUnplug<~Boolean>      - This image is capable of nic hot unplug (no reboot required)
        #       * discVirtioHotPlug<~Boolean> - This image is capable of Virt-IO drive hot plug (no reboot required)
        #       * discVirtioHotPlug<~Boolean> - This image is capable of Virt-IO drive hot unplug (no reboot required)
        #       * discScsiHotPlug<~Boolean>   - This image is capable of Scsi drive hot plug (no reboot required)
        #       * discScsiHotUnplug<~Boolean> - This image is capable of Scsi drive hot unplug (no reboot required)
        #       * licenceType<~String>        - The image's licence type: LINUX, WINDOWS, or UNKNOWN
        #       * imageType<~String>          - The type of image: HDD, CDROM
        #       * public<~String>             - Indicates if the image is part of the public repository or not
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#attach-a-cd-rom]
        def attach_cdrom(datacenter_id, server_id, cdrom_image_id)
          volume = {
              :id => cdrom_image_id
          }

          request(
              :expects  => [202],
              :method   => 'POST',
              :path     => "/datacenters/#{datacenter_id}/servers/#{server_id}/cdroms",
              :body     => Fog::JSON.encode(volume)
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def attach_cdrom(datacenter_id, server_id, cdrom_image_id)
          if cdrom = self.data[:images]['items'].find {
              |cd| cd["id"] == cdrom_image_id
          }
          else
            raise Fog::Errors::NotFound.new("The requested resource could not be found")
          end

          if server = self.data[:servers]['items'].find {
              |serv|  serv['datacenter_id'] == datacenter_id && serv['id'] == server_id
          }
          else
            raise Fog::Errors::NotFound.new("The server resource could not be found")
          end

          server['entities']['cdroms']['items'] << cdrom

          response        = Excon::Response.new
          response.status = 202
          response.body   = cdrom

          response
        end
      end
    end
  end
end
