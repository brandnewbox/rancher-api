module Rancher
  module Api
    class Stack
      include Her::Model
      include Helpers::Model

      belongs_to :project
      has_many :services
      has_many :volumes

      def project_id
        accountId
      end
    end
  end
end
