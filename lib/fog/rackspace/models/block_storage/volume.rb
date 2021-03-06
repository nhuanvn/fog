require 'fog/core/model'

module Fog
  module Rackspace
    class BlockStorage
      class Volume < Fog::Model
        AVAILABLE = 'available'
        ATTACHING = 'attaching'
        CREATING = 'creating'
        DELETING = 'deleting'
        ERROR = 'error'
        ERROR_DELETING = 'error_deleting'
        IN_USE = 'in-use'

        identity :id

        attribute :created_at, :aliases => 'createdAt'
        attribute :state, :aliases => 'status'
        attribute :display_name
        attribute :display_description
        attribute :size
        attribute :attachments
        attribute :volume_type
        attribute :availability_zone

        def ready?
          state == AVAILABLE
        end

        def attached?
          state == IN_USE
        end

        def snapshots
          service.snapshots.select { |s| s.volume_id == identity }
        end

        def create_snapshot(options={})
          requires :identity
          service.snapshots.create(options.merge(:volume_id => identity))
        end

        def save
          requires :size
          raise IdentifierTaken.new('Resaving may cause a duplicate volume to be created') if persisted?
          data = service.create_volume(size, {
            :display_name => display_name,
            :display_description => display_description,
            :volume_type => volume_type,
            :availability_zone => availability_zone
          })
          merge_attributes(data.body['volume'])
          true
        end

        def destroy
          requires :identity
          service.delete_volume(identity)
          true
        end
      end
    end
  end
end
