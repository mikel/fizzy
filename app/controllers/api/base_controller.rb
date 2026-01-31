# frozen_string_literal: true

module Api
  class BaseController < ActionController::Base
    # Skip CSRF protection for API endpoints
    skip_before_action :verify_authenticity_token

    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

    private

    def not_found
      render json: { error: "Not found" }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
