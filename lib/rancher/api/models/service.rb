module Rancher
  module Api
    class Service
      include Her::Model
      include Helpers::Model

      belongs_to :project
      has_many :instances

      def stack
        stackId ? Stack.find(project_id: accountId, id: stackId) : nil
      end
    end
  end
end
