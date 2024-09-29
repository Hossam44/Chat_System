module Api
  module V1
    class ApplicationsController < ApplicationController
      before_action :set_application, only: %i(show update destroy)
    
      def index
        @applications = Application.all
        render json: ApplicationBlueprint.render_as_hash(@applications)
      end
    
      def show
        render json: ApplicationBlueprint.render_as_hash(@application)
      end
    
      def create
        @application = ApplicationService::CreateApplication.new(params[:name]).call
      
        if @application.errors.present?
          render json: @application.errors, status: :unprocessable_entity
        else
          # Cache the application ID for the token
          REDIS.set("application_id_for_token_#{@application.token}", @application.id)
          render json: ApplicationBlueprint.render_as_hash(@application), status: :created
        end
      end
    
      def update
        if @application.update(application_params)
          render json: ApplicationBlueprint.render_as_hash(@application), status: :ok
        else
          render json: @application.errors, status: :unprocessable_entity
        end
      end
    
      def destroy
        token = @application.token  
        cached_id_key = "application_id_for_token_#{token}"  
      
        if @application.destroy  
          # If successful, remove the cached ID from Redis
          REDIS.del(cached_id_key)
          render json: { message: 'Application successfully deleted' }, status: :no_content
        else
          render json: { error: 'Failed to delete application' }, status: :unprocessable_entity
        end      
      end
    
      private
    
      def application_params
        params.require(:application).permit(:name)
      end
    
    
      def set_application
        token = params[:token]
        cached_id = REDIS.get("application_id_for_token_#{token}")
      
        if cached_id
          Rails.logger.info("Cache hit for token: #{token}")
          @application = Application.find_by(id: cached_id)
          return
        end
      
        Rails.logger.info("Cache miss for token: #{token}, querying database")
        @application = Application.find_by(token: token)
      
        if @application
          REDIS.set("application_id_for_token_#{token}", @application.id)
        else
          render json: { error: 'Application not found' }, status: :not_found
        end
      end
    end
  end
end
