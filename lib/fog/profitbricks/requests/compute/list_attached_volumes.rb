module Fog
  module Compute
    class ProfitBricks
      class Real
        # Get a list of volumes attached to the server
        #
        # ==== Parameters
        # * datacenter_id<~String> - Required - UUID of the datacenter
        # * server_id<~String>      - Required - UUID of the server
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * id<~String>                   - Id of the requested resource
        #     * type<~String>                 - type of the requested resource
        #     * href<~String>                 - url to the requested resource
        #     * items<~Array>
        #       * id<~String>                   - The resource's unique identifier
        #       * type<~String>                 - The type of the requested resource
        #       * href<~String>                 - URL to the object’s representation (absolute path)
        #       * metadata<~Hash>               - Hash containing the volume metadata
        #         * createdDate<~String>        - The date the resource was created
        #         * createdBy<~String>          - The user who created the resource
        #         * etag<~String>               - The etag for the resource
        #         * lastModifiedDate<~String>   - The last time the resource has been modified
        #         * lastModifiedBy<~String>     - The user who last modified the resource
        #         * state<~String>              - Volume state
        #       * properties<~Hash>             - Hash containing the volume properties
        #         * name<~String>               - The name of the volume.
        #         * type<~String>               - The volume type, HDD or SSD.
        #         * size<~Integer>              - The size of the volume in GB.
        #         * image<~String>              - The image or snapshot ID.
        #         * imagePassword<~Boolean>     - Indicates if a password is set on the image.
        #         * bus<~String>                - The bus type of the volume (VIRTIO or IDE). Default: VIRTIO.
        #         * licenceType<~String>        - Volume licence type. ( WINDOWS, LINUX, OTHER, UNKNOWN)
        #         * cpuHotPlug<~Boolean>        - This volume is capable of CPU hot plug (no reboot required)
        #         * cpuHotUnplug<~Boolean>      - This volume is capable of CPU hot unplug (no reboot required)
        #         * ramHotPlug<~Boolean>        - This volume is capable of memory hot plug (no reboot required)
        #         * ramHotUnplug<~Boolean>      - This volume is capable of memory hot unplug (no reboot required)
        #         * nicHotPlug<~Boolean>        - This volume is capable of nic hot plug (no reboot required)
        #         * nicHotUnplug<~Boolean>      - This volume is capable of nic hot unplug (no reboot required)
        #         * discVirtioHotPlug<~Boolean> - This volume is capable of Virt-IO drive hot plug (no reboot required)
        #         * discVirtioHotPlug<~Boolean> - This volume is capable of Virt-IO drive hot unplug (no reboot required)
        #         * discScsiHotPlug<~Boolean>   - This volume is capable of Scsi drive hot plug (no reboot required)
        #         * discScsiHotUnplug<~Boolean> - This volume is capable of Scsi drive hot unplug (no reboot required)
        #         * deviceNumber<~Integer>      - The LUN ID of the storage volume
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#list-attached-volumes]
        def list_attached_volumes(datacenter_id, server_id)
          request(
              :expects => [200],
              :method  => 'GET',
              :path    => "/datacenters/#{datacenter_id}/servers/#{server_id}/volumes?depth=1"
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def list_attached_volumes(datacenter_id, server_id)
          if server = self.data[:servers]['items'].find {
              |serv|  serv['datacenter_id'] == datacenter_id && serv['id'] == server_id
          }
          else
            raise Fog::Errors::NotFound.new("The server resource could not be found")
          end

          response        = Excon::Response.new
          response.status = 200
          if server['entities'] && server['entities']['volumes']
            response.body   = server['entities']['volumes']
          else
            response.body   = {
                                'id'    => "#{server_id}/volumes",
                                'type'  => 'collection',
                                'href'  => "https=>//api.profitbricks.com/rest/v2/datacenters/#{datacenter_id}/servers/#{server_id}/volumes",
                                'items' => []
                              }
          end

          response
        end
      end
    end
  end
end
