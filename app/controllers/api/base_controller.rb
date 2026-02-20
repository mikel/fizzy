# frozen_string_literal: true

module Api
  class BaseController < ActionController::Base
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token

    # Require Bearer token authentication
    before_action :authenticate_api_request

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

    private

    def authenticate_api_request
      authenticate_or_request_with_http_token do |token, options|
        if identity = Identity.find_by_permissable_access_token(token, method: request.method)
          Current.identity = identity
          
          # For API requests, use the identity's first user/account if Current.account not set
          user = if Current.account
            identity.users.find_by(account: Current.account)
          else
            identity.users.first
          end
          
          if user
            Current.account ||= user.account
            Current.user = user
          end
          
          identity.present? && user.present?
        end
      end
    end

    def not_found
      render json: { error: "Not found" }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
