require File.expand_path('../location', __FILE__)
require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Locations < Fog::Collection
        include Fog::Helpers::ProfitBricks::DataHelper
        model Fog::Compute::ProfitBricks::Location

        def all
          result = service.get_all_locations

          load(result.body['items'].each {|location| flatten(location)})
        end

        def get(id)
          location = service.get_location(id).body

          Excon::Errors
          new(flatten(location))
        rescue Excon::Errors::NotFound
          nil
        end
      end
    end
  end
end
