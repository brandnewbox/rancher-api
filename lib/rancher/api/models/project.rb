# These are 'Stacks' in the UI
module Rancher
  module Api
    class Project
      include Her::Model
      include Helpers::Model

      has_many :machines
      has_many :hosts
      has_many :stacks
      has_many :services
      has_many :containers
      has_many :registration_tokens, path: '/registrationtokens', data_key: 'registrationtokens'
      has_many :settings
      has_many :schemas
      has_many :registry, path: '/registries', data_key: 'registries'


      actions_without_params [:activate,:deactivate,:defaultNetworkId,:setmembers,:upgrade]

    end
  end
end