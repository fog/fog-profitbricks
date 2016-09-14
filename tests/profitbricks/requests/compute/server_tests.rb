Shindo.tests('Fog::Compute[:profitbricks] | server request', ['profitbricks', 'compute']) do

  @resource_schema = {
      'id'                  => String,
      'type'                => String,
      'href'                => String,
      'metadata'            => Hash,
      'properties'          => Hash
  }

  @minimal_schema_with_items = {
      'id'    => String,
      'type'  => String,
      'href'  => String,
      'items' => Array
  }

  service = Fog::Compute[:profitbricks]

  tests('success') do

    Excon.defaults[:connection_timeout] = 500

    tests('#create_datacenter').data_matches_schema(@resource_schema) do
      options = {}
      options[:name]        = 'FogDataCenter'
      options[:location]    = 'us/las'
      options[:description] = 'Part of server tests suite'

      createDatacenterResponse = service.create_datacenter(options)
      @datacenter_id = createDatacenterResponse.body['id']

      if ENV["FOG_MOCK"] != "true"
        service.datacenters.get(@datacenter_id).wait_for { ready? }
      end

      createDatacenterResponse.body
    end

    tests('#get_datacenter').data_matches_schema(@resource_schema) do
      getDatacenterResponse = service.get_datacenter(@datacenter_id)
      getDatacenterResponse.body
    end

    tests('#get_all_datacenters').data_matches_schema(@minimal_schema_with_items) do
      getAllDatacentersResponse = service.get_all_datacenters
      getAllDatacentersResponse.body
    end

    tests('#update_datacenter').data_matches_schema(@resource_schema) do
      options = {}
      options[:name] = 'FogDataCenterRename'
      options[:description] = 'FogDataCenterDescriptionUpdated'

      updateDatacenterResponse = service.update_datacenter(
        @datacenter_id, options
      )

      if ENV["FOG_MOCK"] != "true"
        service.datacenters.get(@datacenter_id).wait_for { ready? }
      end

      updateDatacenterResponse.body
    end

    tests('#get_all_images').data_matches_schema(@minimal_schema_with_items) do
      getAllImagesResponse = service.get_all_images
      data = service.get_all_images.body['items'].find { |image|
        image['properties']['location'] == 'us/las' &&
        image['properties']['imageType'] == 'CDROM' &&
        image['properties']['licenceType'] == 'LINUX'
      }
      @image_id = data['id']
      getAllImagesResponse.body
    end

    tests('#get_image').data_matches_schema(@resource_schema) do
      getImageResponse = service.get_image(@image_id)
      getImageResponse.body
    end

    if ENV["FOG_MOCK"] == "true"
      tests('#update_image').data_matches_schema(@resource_schema) do
        options = {}
        options[:name]                = 'FogImageRename'
        options[:description]         = 'FogImageDescriptionUpdated'

        updateImageResponse = service.update_image(
            @image_id, options
        )

        updateImageResponse.body
      end
    end

    tests('#get_all_volumes').data_matches_schema(@minimal_schema_with_items) do
      if dc = service.get_all_datacenters.body["items"].find {
          |datacenter| datacenter["id"] == @datacenter_id
      }
      else
        raise Fog::Errors::NotFound.new("The requested resource could not be found")
      end

      getAllVolumesResponse = service.get_all_volumes(dc['id'])
      getAllVolumesResponse.body
    end

    tests('#create_volume').data_matches_schema(@resource_schema) do
      options = {}
      options[:name]        = 'FogRestTestVolume'
      options[:size]        = 5
      options[:licenceType] = 'LINUX'
      options[:type]        = 'HDD'

      createVolumeResponse = service.create_volume(@datacenter_id, options)
      @volume_id = createVolumeResponse.body['id']

      if ENV["FOG_MOCK"] != "true"
        loop do
          sleep(5)
          vlm = service.volumes.get(@datacenter_id, @volume_id)
          break unless !vlm.ready?
        end
      end

      # Calling wait_for causes ArgumentError
      # vlm.wait_for { ready? }

      createVolumeResponse.body
    end

    tests('#get_volume').data_matches_schema(@resource_schema) do
      getVolumeResponse = service.get_volume(@datacenter_id, @volume_id)
      getVolumeResponse.body
    end

    tests('#create_volume_snapshot').data_matches_schema(@resource_schema) do
      options = {}
      options[:name]        = 'FogRestTestSnapshot'
      options[:description] = 'Testing fog create snapshot'

      createVolumeSnapshotResponse = service.create_volume_snapshot(@datacenter_id, @volume_id, options)
      @snapshot_id = createVolumeSnapshotResponse.body['id']

      if ENV["FOG_MOCK"] != "true"
        sleep(5)
        snapshot = service.snapshots.get(@snapshot_id)
        snapshot.wait_for { ready? }
      end

      createVolumeSnapshotResponse.body
    end

    tests('#update_volume').data_matches_schema(@resource_schema) do
      options = {}
      options[:name] = 'FogRestTestVolumeRenamed'
      options[:size] = 6

      updateVolumeResponse = service.update_volume(@datacenter_id, @volume_id, options)

      if ENV["FOG_MOCK"] != "true"
        loop do
          sleep(1)
          vlm = service.volumes.get(@datacenter_id, @volume_id)
          break unless !vlm.ready?
        end
      end

      # Calling wait_for causes ArgumentError
      # vlm.wait_for { ready? }

      updateVolumeResponse.body
    end

    tests('#update_snapshot').data_matches_schema(@resource_schema) do
      options = {}
      options[:name]        = 'FogRestTestSnapshotRename'
      options[:description] = 'Testing fog create snapshot - updated description'
      options[:ramHotPlug]  = true

      updateSnapshotResponse = service.update_snapshot(@snapshot_id, options)

      if ENV["FOG_MOCK"] != "true"
        snapshot = service.snapshots.get(@snapshot_id)
        snapshot.wait_for { ready? }
      end
      updateSnapshotResponse.body
    end

    tests('#get_snapshot').data_matches_schema(@resource_schema) do
      getSnapshotResponse = service.get_snapshot(@snapshot_id)
      getSnapshotResponse.body
    end

    tests('#restore_volume_snapshot').succeeds do
      options = {}
      options[:snapshot_id] = @snapshot_id

      restoreVolumeSnapshotResponse = service.restore_volume_snapshot(@datacenter_id, @volume_id, options)
      restoreVolumeSnapshotResponse.status == 202
    end

    tests('#get_all_snapshots').data_matches_schema(@minimal_schema_with_items) do
      getAllSnapshotsResponse = service.get_all_snapshots
      getAllSnapshotsResponse.body
    end

    tests('#create_server').data_matches_schema(@resource_schema) do
      properties = {}
      properties[:name]             = 'FogTestServer_2'
      properties[:cores]            = 1
      properties[:ram]              = 1024
      properties[:availabilityZone] = 'ZONE_1'
      properties[:cpuFamily]        = 'INTEL_XEON'

      entities = {}
      entities[:volumes] = {}
      entities[:volumes]['items'] = [
        {
          'id' => @volume_id
        }
      ]

      createServerResponse = service.create_server(@datacenter_id, properties, entities)
      @server_id = createServerResponse.body['id']

      if ENV["FOG_MOCK"] != "true"
        loop do
          sleep(480)
          server = service.servers.get(@datacenter_id, @server_id)
          break unless !server.ready?
        end
      end

      # Calling wait_for causes ArgumentError
      # server.wait_for { ready? }

      createServerResponse.body
    end

    tests('#get_server').data_matches_schema(@resource_schema) do
      getServerResponse = service.get_server(@datacenter_id, @server_id)
      getServerResponse.body
    end

    tests('#list_attached_volumes').data_matches_schema(@minimal_schema_with_items) do
      listAttachedVolumesResponse = service.list_attached_volumes(@datacenter_id, @server_id)
      listAttachedVolumesResponse.body
    end

    tests('#attach_volume').data_matches_schema(@resource_schema) do
      attachVolumeResponse = service.attach_volume(@datacenter_id, @server_id, @volume_id)

      if ENV["FOG_MOCK"] != "true"
        loop do
          vlm = service.volumes.get(@datacenter_id, @volume_id)
          sleep(1)
          break unless !vlm.ready?
        end
      end

      # Calling wait_for causes ArgumentError
      # vlm.wait_for { ready? }

      attachVolumeResponse.body
    end

    tests('#get_attached_volume').data_matches_schema(@resource_schema) do
      getAttachedVolumeResponse = service.get_attached_volume(@datacenter_id, @server_id, @volume_id)
      getAttachedVolumeResponse.body
    end

    tests('#detach_volume').succeeds do
      detachVolumeResponse = service.detach_volume(@datacenter_id, @server_id, @volume_id)
      detachVolumeResponse.status == 202
    end

    tests('#attach_cdrom').data_matches_schema(@resource_schema) do
      attachCdromResponse = service.attach_cdrom(@datacenter_id, @server_id, @image_id)

      if ENV["FOG_MOCK"] != "true"
        cd = service.images.get(@image_id)
        cd.wait_for { ready? }
      end

      @cdrom_id = attachCdromResponse.body['id']

      attachCdromResponse.body
    end

    tests('#get_attached_cdrom').data_matches_schema(@resource_schema) do
      if ENV["FOG_MOCK"] != "true"
        sleep(240)
      end
      getAttachedVolumeResponse = service.get_attached_cdrom(@datacenter_id, @server_id, @cdrom_id)
      getAttachedVolumeResponse.body
    end

    tests('#list_attached_cdroms').data_matches_schema(@minimal_schema_with_items) do
      listAttachedCdromsResponse = service.list_attached_cdroms(@datacenter_id, @server_id)

      listAttachedCdromsResponse.body
    end

    tests('#detach_cdrom').succeeds do
      detachVolumeResponse = service.detach_cdrom(@datacenter_id, @server_id, @cdrom_id)
      detachVolumeResponse.status == 202
    end

    tests('#update_server').data_matches_schema(@resource_schema) do
      updateServerResponse = service.update_server(@datacenter_id, @server_id, { 'name' => 'FogServerRename' })

      if ENV["FOG_MOCK"] != "true"
        loop do
          server = service.servers.get(@datacenter_id, @server_id)
          sleep(1)
          break unless !server.ready?
        end
      end

      # Calling wait_for causes ArgumentError
      # server.wait_for { ready? }

      updateServerResponse.body
    end

    tests('#get_all_servers').data_matches_schema(@minimal_schema_with_items) do
      getAllServersResponse = service.get_all_servers(@datacenter_id)

      getAllServersResponse.body
    end

    tests('#stop_server').succeeds do
      stopServerResponse = service.stop_server(@datacenter_id, @server_id)

      if ENV["FOG_MOCK"] != "true"
        loop do
          server = service.servers.get(@datacenter_id, @server_id)
          sleep(1)
          break unless !server.shutoff?
        end
      end

      # Calling wait_for causes ArgumentError
      # server.wait_for { shutoff? }

      stopServerResponse.status == 202
    end

    tests('#start_server').succeeds do
      startServerResponse = service.start_server(@datacenter_id, @server_id)

      if ENV["FOG_MOCK"] != "true"
        loop do
          server = service.servers.get(@datacenter_id, @server_id)
          sleep(1)
          break unless !server.running?
        end
      end

      # Calling wait_for causes ArgumentError
      # server.wait_for { running? }

      startServerResponse.status == 202
    end

    tests('#reboot_server').succeeds do
      rebootServerResponse = service.reboot_server(@datacenter_id, @server_id)

      if ENV["FOG_MOCK"] != "true"
        loop do
          server = service.servers.get(@datacenter_id, @server_id)
          sleep(1)
          break unless !server.running?
        end
      end

      rebootServerResponse.status == 202
    end

    tests('#delete_server').succeeds do
      deleteServerResponse = service.delete_server(@datacenter_id, @server_id)
      deleteServerResponse.status == 202
    end

    tests('#delete_snapshot').succeeds do
      deleteSnapshotResponse = service.delete_snapshot(@snapshot_id)
      deleteSnapshotResponse.status == 202
    end

    tests('#delete_volume').succeeds do
      deleteVolumeResponse = service.delete_volume(@datacenter_id, @volume_id)
      deleteVolumeResponse.status == 202
    end

    if ENV["FOG_MOCK"] == "true"
      tests('#delete_image').succeeds do
        deleteImageResponse = service.delete_image(@image_id)
        deleteImageResponse.status == 202
      end
    end

    tests('#delete_datacenter').succeeds do
      deleteDatacenterResponse = service.delete_datacenter(@datacenter_id)
      deleteDatacenterResponse.status == 202
    end
  end

  tests('failure') do

    tests('#get_datacenter').raises(Fog::Errors::NotFound) do
      service.get_datacenter('00000000-0000-0000-0000-000000000000')
    end

    tests('#update_datacenter').raises(Fog::Errors::NotFound) do
      service.update_datacenter('00000000-0000-0000-0000-000000000000',
                    { 'name' => 'FogTestDCRename' })
    end

    tests('#delete_datacenter').raises(Fog::Errors::NotFound) do
      service.delete_datacenter('00000000-0000-0000-0000-000000000000')
    end

    tests('#get_image').raises(Fog::Errors::NotFound) do
      service.get_image('00000000-0000-0000-0000-000000000000')
    end

    tests('#update_image').raises(Fog::Errors::NotFound) do
      service.update_image('00000000-0000-0000-0000-000000000000', {})
    end

    tests('#create_volume').raises(ArgumentError) do
      service.create_volume
    end

    tests('#create_volume_snapshot').raises(ArgumentError) do
      service.create_volume_snapshot
    end

    tests('#create_volume_snapshot').raises(Fog::Errors::NotFound) do
      service.create_volume_snapshot('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', {})
    end

    tests('#get_snapshot').raises(Fog::Errors::NotFound) do
      service.get_snapshot('00000000-0000-0000-0000-000000000000')
    end

    tests('#get_snapshot').raises(ArgumentError) do
      service.get_snapshot
    end

    tests('#restore_volume_snapshot').raises(ArgumentError) do
      service.restore_volume_snapshot
    end

    tests('#restore_volume_snapshot').raises(Fog::Errors::NotFound) do
      service.restore_volume_snapshot('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000', {})
    end

    tests('#get_volume').raises(Fog::Errors::NotFound) do
      service.get_volume('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
    end

    tests('#update_volume').raises(Fog::Errors::NotFound) do
      service.update_volume('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
    end

    tests('#delete_volume').raises(Fog::Errors::NotFound) do
      service.delete_volume('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000')
    end
  end
end
