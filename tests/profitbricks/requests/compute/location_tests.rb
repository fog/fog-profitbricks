Shindo.tests('Fog::Compute[:profitbricks] | location request', ['profitbricks', 'compute']) do

  @locations_schema = {
    'id'          => String,
    'type'        => String,
    'href'        => String,
    'items'       => Array
  }

  @location_schema = {
      'id'          => String,
      'type'        => String,
      'href'        => String,
      'properties'  => {
          'name'      => String,
          'features'  => Array
      }
  }

  service = Fog::Compute[:profitbricks]

  tests('success') do

    Excon.defaults[:connection_timeout] = 500

    tests('#get_all_locations').data_matches_schema(@locations_schema) do
      data = service.get_all_locations
      @location_id = data.body['items'][0]['id']

      data.body
    end

    tests('#get_location').data_matches_schema(@location_schema) do
      data = service.get_location(@location_id)
      data.body
    end

  end

  tests('failure') do
    tests('#get_location').raises(Fog::Errors::NotFound) do
      data = service.get_location('00000000-0000-0000-0000-000000000000')
    end
  end
end
