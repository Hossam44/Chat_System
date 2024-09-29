class ApplicationController < ActionController::API

  # Catch all ActiveRecord exceptions and return a generic error message
  # rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  # rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  # rescue_from ActiveRecord::RecordNotUnique, with: :render_conflict
  # rescue_from StandardError, with: :render_internal_server_error

  # private

  # def render_not_found
  #   render json: { error: 'Resource not found' }, status: :not_found
  # end

  # def render_unprocessable_entity(exception)
  #   render json: { error: exception.message }, status: :unprocessable_entity
  # end

  # def render_conflict
  #   render json: { error: 'Conflict occurred while creating the resource' }, status: :conflict
  # end

  # def render_internal_server_error
  #   render json: { error: 'Failed to create resource' }, status: :internal_server_error
  # end
end
