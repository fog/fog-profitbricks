require File.expand_path('../image', __FILE__)
require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Images < Fog::Collection
        include Fog::Helpers::ProfitBricks::DataHelper
        model Fog::Compute::ProfitBricks::Image

        def all
          result = service.get_all_images

          load(result.body['items'].each {|img| flatten(img)})
        end

        def get(id)
          image = service.get_image(id).body

          Excon::Errors
          new(flatten(image))
        rescue Excon::Errors::NotFound
          nil
        end
      end
    end
  end
end
