module Rancher
  module Api
    class Container
      include Her::Model
      include Helpers::Model


      collection_path '/v2-beta/projects/:project_id/containers'

      belongs_to :project

      actions_without_params [:console,:execute,:logs,:proxy,:restart,:start, :stop]

    end
  end
end