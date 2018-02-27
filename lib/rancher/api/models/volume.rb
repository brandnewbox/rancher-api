module Rancher
  module Api
    class Volume
      include Her::Model
      include Helpers::Model

      collection_path '/v2-beta/projects/:project_id/volumes'

      belongs_to :project

      def project_id
        accountId
      end

      def stack
        stackId ? Stack.find(project_id: project.id, id: stackId) : nil
      end
    end
  end
end
