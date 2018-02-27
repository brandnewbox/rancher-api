module Rancher
  module Api
    class RegistrationToken
      include Her::Model
      include Helpers::Model

      collection_path '/v2-beta/projects/:project_id/registrationtokens'

      belongs_to :project
    end
  end
end
