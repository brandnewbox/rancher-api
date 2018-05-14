require 'eventmachine'

module Rancher
  module Api
    module Helpers
      module Model
        module ClassMethods
          def actions_without_params(actions)
            actions.to_a.each do |action|
              define_method :"run_#{action}" do
                run(action)
              end
            end
          end
          def actions_with_params(actions)
            actions.to_a.each do |action|
              define_method :"run_#{action}" do |params = {}|
                params = self.send("default_#{action}_params").deep_merge(params) if self.respond_to?("default_#{action}_params")
                run(action,params: params)
              end
            end
          end
        end
        class RancherWaitTimeOutError < StandardError; end
        class RancherModelError < StandardError; end
        class RancherActionNotAvailableError < StandardError; end

        TIMEOUT_LIMIT = 900
        DEFAULT_BATCH_SIZE = 1
        DEFAULT_INTERVAL_MILLIS = 10_000

        def self.included base
          # base.send :include, InstanceMethods
          base.extend ClassMethods
        end

        def self_url
          links['self']
        end

        def reload(path_parameters: nil)
          assign_attributes(self.class.find(id, path_parameters).attributes)
        end

        def run(action, params: {})
          url = actions[action.to_s]
          puts '*'*88
          puts url.inspect
          puts '*'*88
          puts params.inspect
          puts '*'*88
          raise RancherActionNotAvailableError, "Available actions: '#{actions.inspect}'" if url.blank?
          handle_response(self.class.post(url,params))
        end

        def delete
          handle_response(self.class.delete(self_url))
        end

        # def post_link(link)
        #   url = links[link.to_s]
        #   raise RancherActionNotAvailableError, "Available actions: '#{links.inspect}'" if url.blank?
        #   handle_response(self.class.post(url))
        # end

        def handle_response(response)
          case response
          when Her::Collection
            response
          when Her::Model
            raise RancherModelError, response.inspect if response.type.eql?('error')
            response
          else
            raise RancherModelError, response.inspect
          end
        end

        def wait_for_state(desired_state, path_parameters: nil)
          EM.run do
            EM.add_timer(TIMEOUT_LIMIT) do
              raise RancherWaitTimeOutError, "Timeout while waiting for transition to: #{desired_state}"
            end
            EM.tick_loop do
              reload(path_parameters: path_parameters)
              current_state = state
              if current_state.eql?(desired_state.to_s)
                Logger.log.info "state changed from: #{current_state} => #{desired_state}"
                EM.stop
              else
                Logger.log.info "waiting for state change: #{current_state} => #{desired_state}"
                sleep(1)
              end
            end
          end
        end
      end
    end
  end
end
