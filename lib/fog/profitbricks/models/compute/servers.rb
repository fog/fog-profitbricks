require File.expand_path('../server', __FILE__)
require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Servers < Fog::Collection
        include Fog::Helpers::ProfitBricks::DataHelper
        model Fog::Compute::ProfitBricks::Server

        def all(datacenter_id)
          result = service.get_all_servers(datacenter_id)

          servers = result.body['items'].each {|server| server['datacenter_id'] = datacenter_id}
          result.body['items'] = servers

          load(result.body['items'].each {|dc| flatten(dc)})
        end

        def get(datacenter_id, server_id)
          server = service.get_server(datacenter_id, server_id).body
          server['datacenter_id'] = datacenter_id

          Excon::Errors
          new(flatten(server))
        rescue Excon::Errors::NotFound
          nil
        end
      end
    end
  end
end
