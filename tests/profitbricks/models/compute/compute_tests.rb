Shindo.tests('Fog::Compute[:profitbricks] | compute models', ['profitbricks', 'compute']) do

	compute = Fog::Compute[:profitbricks]

	tests('success') do

		Excon.defaults[:connection_timeout] = 500

		tests('should create a datacenter').succeeds do
	  	datacenter = compute.datacenters.create(:name => 'fog-demo',
                                        		:location => 'de/fra',
                                       			:description => 'testing fog rest implementation')
			datacenter.wait_for { ready? }

			@datacenter_id = datacenter.id

			datacenter.name == 'fog-demo'
			datacenter.location == 'de/fra'
			datacenter.description == 'testing fog rest implementation'
    end

    tests('should retrieve a datacenter by id').succeeds do
	  	datacenter = compute.datacenters.get(@datacenter_id)

	  	datacenter.id != nil
    end

    tests('should update a datacenter').succeeds do
	  	datacenter = compute.datacenters.get(@datacenter_id)
	  	datacenter.name = datacenter.name + ' - updated'
	  	datacenter.description = datacenter.description + ' - updated'
	  	datacenter.update

	  	datacenter.wait_for { ready? }

	  	datacenter.name = 'fog-demo - updated'
	  	datacenter.description = 'testing fog rest implementation - updated'
    end

		tests('should retrieve all datacenters').succeeds do
	  	datacenters = compute.datacenters.all

	  	datacenters.length > 0
    end

    tests('should retrieve all locations').succeeds do
	  	locations = compute.locations.all

	  	locations.length > 0
    end

    tests('should retrieve a location by id').succeeds do
	  	location = compute.locations.get('us/las')

	  	location.name == 'lasvegas'
    end

    tests('should delete a datacenter').succeeds do
	  	datacenter = compute.datacenters.get(@datacenter_id)

	  	datacenter.delete
    end
    	
	end
end