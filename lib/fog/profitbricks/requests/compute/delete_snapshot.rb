module Fog
  module Compute
    class ProfitBricks
      class Real
        # Delete virtual data center
        #
        # ==== Parameters
        # * snapshot_id<~String> - UUID of the snapshot
        #
        # ==== Returns
        # * response<~Excon::Response>
        #
        # {ProfitBricks API Documentation}[https://devops.profitbricks.com/api/cloud/v2/#delete-snapshot]
        def delete_snapshot(snapshot_id)
          request(
              :expects => [202],
              :method  => 'DELETE',
              :path    => "/snapshots/#{snapshot_id}"
          )
        rescue => error
          puts error
          Fog::Errors::NotFound.new(error)
        end
      end

      class Mock
        def delete_snapshot(snapshot_id)
          response = Excon::Response.new
          response.status = 202

          if snapshot = self.data[:snapshots]['items'].find {
              |attrib| attrib['id'] == snapshot_id
          }
          else
            raise Fog::Errors::NotFound.new('The requested resource could not be found')
          end

          response
        end
      end
    end
  end
end
