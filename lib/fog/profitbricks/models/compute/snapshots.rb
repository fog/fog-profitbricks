require File.expand_path('../snapshot', __FILE__)
require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Snapshots < Fog::Collection
        include Fog::Helpers::ProfitBricks::DataHelper
        model Fog::Compute::ProfitBricks::Snapshot

        def all
          result = service.get_all_snapshots

          load(result.body['items'].each {|snapshot| flatten(snapshot)})
        end

        def get(id)
          snapshot = service.get_snapshot(id).body

          Excon::Errors
          new(flatten(snapshot))
        rescue Excon::Errors::NotFound
          nil
        end
      end
    end
  end
end