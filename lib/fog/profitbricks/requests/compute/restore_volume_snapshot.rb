module Fog
  module Compute
    class ProfitBricks
      class Real
        # Restores a snapshot onto a volume.
        # A snapshot is created as just another image that can be used to create new volumes or to restore an existing volume.
        #
        # ==== Parameters
        # * datacenter_id<~String> - Required, UUID of virtual data center
        # * volume_id<~String>      - Required, UUID of the snapshot
        # * options<~Hash>:
        #   * snapshotId<~String>   - Required, The ID of the snapshot
        #
        # ==== Returns
        # * response<~Excon::Response> - No response parameters
        #   * status<~Integer>  - HTTP status for the request
        #   * headers<~Array>   - The response headers
        #     * Location<~String>         - URL of a request resource which should be used for operation's status polling
        #     * Date<~String>
        #     * Content-Length<~Integer>
        #     * Connection<~String>
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#create-volume-snapshot]
        def restore_volume_snapshot(datacenter_id, volume_id, options={})
          request(
              :expects  => [202],
              :method   => 'POST',
              :path     => "/datacenters/#{datacenter_id}/volumes/#{volume_id}/restore-snapshot",
              :headers => { "Content-Type" => "application/x-www-form-urlencoded" },
              :body => URI.encode_www_form("snapshotId" => options[:snapshot_id])
          )
        rescue => error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def restore_volume_snapshot(datacenter_id, volume_id, options={})
          response = Excon::Response.new
          response.status = 202

          if datacenter = self.data[:datacenters]['items'].find {
              |attrib| attrib['id'] == datacenter_id
          }
          else
            raise Fog::Errors::NotFound.new('Data center resource could not be found')
          end

          if volume = self.data[:volumes]['items'].find {
              |attrib| attrib['id'] == volume_id && attrib['datacenter_id'] == datacenter_id
          }
          else
            raise Fog::Errors::NotFound.new('Volume resource could not be found')
          end

          response
        end
      end
    end
  end
end
