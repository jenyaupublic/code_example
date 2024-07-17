class BaseService
  def self.call(*args)
    new(*args).call
  end
end

module Api
  module V2
    module Clients
      class FilterClients < BaseService
        def initialize(store, params)
          @store = store
          @params = params
          @clients = store.clients
          @store_names = store_names_by_uid
        end

        def call
          filter_clients!
          order_clients!
        end

        private

        attr_accessor :clients
        attr_reader :current_user, :store, :params, :store_names

        def filter_clients!
          return self.clients if params.blank?

          filter_by_profile_created!
          filter_by_lead_type!
          filter_by_membership_type!
          filter_by_first_visit_date!
        end

        def order_clients!
          self.clients = clients.order(:last_name, :first_name)
        end

        def filter_by_profile_created!
          start_date = params[:created_start_date].to_date
          end_date = params[:created_end_date].to_date

          return self.clients if start_date.blank? || end_date.blank?

          self.clients = clients.where("clients.profile_created_at::DATE BETWEEN ? AND ?", start_date, end_date)
        end

        def filter_by_lead_type!
          return self.clients if (query_params = params[:lead_types].to_s.split(',')).empty?

          self.clients = clients.where(client_lead_type: query_params)
        end

        def filter_by_membership_type!
          return self.clients if (query_params = params[:membership_types].to_s.split(',')).empty?

          self.clients = clients.where(membership_type: query_params)
        end

        def filter_by_first_visit_date!
          start_date = params[:first_visit_start_date].to_date
          end_date = params[:first_visit_end_date].to_date

          return self.clients if start_date.blank? || end_date.blank?

          self.clients = clients.where("clients.first_visit_date::DATE BETWEEN ? AND ?", start_date, end_date)
        end
      end
    end
  end
end
