module Rancher
  module Api
    class Service
      include Her::Model
      include Helpers::Model

      collection_path '/v2-beta/projects/:project_id/services'

      belongs_to :project
      belongs_to :stack
      has_many :instances

      actions_without_params [:activate,:cancelupgrade,:continueupgrade,
        :deactivate,:finishupgrade,:rollback]
      actions_with_params [:addservicelink,:removeservicelink,:restart,
        :setservicelinks,:upgrade]

      # smart_upgrade Action inspired by gaucho
      # https://github.com/etlweather/gaucho/blob/master/services.py
      # smart_upgrade(params: {inServiceStrategy: {launchConfig: {imageUuid: 'alpine:3.4'}}})
      def smart_upgrade(params: {}, finishupgrade_on_previous: true, finishupgrade_on_current: true)
        # Let's finish the upgrade
        # on the previous upgrade if we need to / want to
        if finishupgrade_on_previous && state == 'upgraded'
          puts "--> Finishing upgrade on previous upgrade"
          run_finishupgrade
          wait_for_state_with_params('active')
        end        

        # Can't upgrade a service if it's not in active state
        if state != 'active'
          puts "--> Service cannot be updated due to its current state: #{state}"
          return state          
        end

        puts "--> Upgrading"
        run_upgrade(default_upgrade_params.merge(params))
        wait_for_state_with_params('upgraded')

        if finishupgrade_on_current && state == 'upgraded'
          puts "--> Finishing upgrade"
          run_finishupgrade
          wait_for_state_with_params('active')
          return 'active'
        else
          return 'upgraded'
        end
      end

      def wait_for_state_with_params(state)
        # I wish accountId was actually projectId
        wait_for_state(state, path_parameters: {_project_id: accountId})
      end

      def containers
        project.containers.select {|c| c.serviceIds.to_a.include?(self.id)}
      end

      # Default Params for Actions
      def default_addservicelink_params
        {
          serviceLink: {}
        }
      end
      def default_removeservicelink_params
        {
          serviceLink: {}
        }
      end
      def default_restart_params
        {
          rollingRestartStrategy: {
            batchSize: DEFAULT_BATCH_SIZE,
            intervalMillis: DEFAULT_INTERVAL_MILLIS
          }
        }
      end
      def default_setservicelinks_params
        {
          serviceLinks: []
        }
      end
      def default_upgrade_params
        {
          inServiceStrategy: {
            batchSize: DEFAULT_BATCH_SIZE,
            intervalMillis: DEFAULT_INTERVAL_MILLIS,
            launchConfig: self.launchConfig.symbolize_keys,
            previousSecondaryLaunchConfigs: [],
            secondaryLaunchConfigs: [],
            startFirst: false
          }
        }
      end

    end
  end
end
