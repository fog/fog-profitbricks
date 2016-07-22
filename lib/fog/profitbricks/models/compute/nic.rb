require File.expand_path('../../helpers/compute/data_helper', __dir__)

module Fog
  module Compute
    class ProfitBricks
      class Nic < Fog::Models::ProfitBricks::Base
        include Fog::Helpers::ProfitBricks::DataHelper

        identity  :id

        # properties
        attribute :name
        attribute :mac
        attribute :ips
        attribute :dhcp
        attribute :lan
        attribute :firewall_active, :aliases => 'firewallActive'

        # metadata
        attribute :created_date,       :aliases => 'createdDate', :type => :time
        attribute :created_by, 	       :aliases => 'createdBy'
        attribute :last_modified_date, :aliases => 'lastModifiedDate', :type => :time
        attribute :last_modified_by,   :aliases => 'lastModifiedBy'
        attribute :request_id,         :aliases => 'requestId'
        attribute :state

        # entities
        attribute :firewallrules

        attribute :datacenter_id
        attribute :server_id

        attr_accessor :options

        def save
          requires :datacenter_id, :server_id, :lan

          properties = {}
          properties[:name]           = name if name
          properties[:ips]            = ips if ips
          properties[:dhcp]           = dhcp if dhcp
          properties[:lan]            = lan if lan
          properties[:firewallActive] = firewall_active if firewall_active

          entities = {}
          entities[:firewallrules] = firewallrules if firewallrules

          data = service.create_nic(datacenter_id, server_id, properties, entities)
          merge_attributes(flatten(data.body))
        end

        def update
          requires :datacenter_id, :server_id, :id

          properties = {}
          properties[:name] = name if name
          properties[:ips]  = ips if ips
          properties[:dhcp] = dhcp if dhcp
          properties[:lan]  = lan if lan

          data = service.update_nic(datacenter_id, server_id, id, properties)
          merge_attributes(data.body)
        end

        def delete
          requires :datacenter_id, :server_id, :id
          service.delete_nic(datacenter_id, server_id, id)
          true
        end

        def reload
          requires :datacenter_id, :server_id, :id

          data = begin
            collection.get(datacenter_id, server_id, id)
          rescue Excon::Errors::SocketError
            nil
          end

          return unless data

          new_attributes = data.attributes
          merge_attributes(new_attributes)
          self
        end
      end
    end
  end
end
