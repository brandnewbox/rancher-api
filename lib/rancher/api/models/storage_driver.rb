module Rancher
  module Api
    class StorageDriver
      include Her::Model
      include Helpers::Model

      collection_path '/v2-beta/storagedrivers'

      has_many :volumes

      def project_id
        accountId
      end

      def service
        serviceId ? Service.find(project_id: project_id, id: serviceId) : nil
      end
    end
  end
end
