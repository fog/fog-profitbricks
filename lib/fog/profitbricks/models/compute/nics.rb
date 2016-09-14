require File.expand_path('../nic', __FILE__)
require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Nics < Fog::Collection
        include Fog::Helpers::ProfitBricks::DataHelper
        model Fog::Compute::ProfitBricks::Nic

        def all(datacenter_id, server_id)
          result = service.get_all_nic(datacenter_id, server_id)

          nics = result.body['items'].each do |nic|
            nic['datacenter_id'] = datacenter_id
            nic['server_id'] = server_id
          end

          result.body['items'] = nics

          load(result.body['items'].each { |nic| flatten(nic) })
        end

        def get(datacenter_id, server_id, nic_id)
          nic = service.get_nic(datacenter_id, server_id, nic_id).body

          Excon::Errors
          nic['datacenter_id'] = datacenter_id
          nic['server_id']      = server_id

          new(flatten(nic))
        rescue Excon::Errors::NotFound
          nil
        end
      end
    end
  end
end
