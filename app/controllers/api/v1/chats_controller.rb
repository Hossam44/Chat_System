module Api
  module V1
    class ChatsController < ApplicationController
      before_action :set_application, only: %i(index create)
      before_action :set_chat, only: %i(show)

      def index
        @chats = @application.chats
        render json: ChatBlueprint.render_as_hash(@chats)
      end

      def show
        render json: ChatBlueprint.render_as_hash(@chat)
      end

      def create
        @chat = @application.chats.build
        @chat.number = new_chat_number
        if @chat.valid?
          ChatWorker.perform_async(@application.id, @application.token, @chat.number)
          render json: ChatBlueprint.render_as_hash(@chat), status: :accepted
        else
          render json: @chat.errors, status: :unprocessable_entity
        end
      end

      # def destroy
      #   @chat.destroy
      # end

      private

      def set_chat

        application_token = params[:application_token]
        chat_number = params[:number]
        cache_key = "chat_#{application_token}_#{chat_number}"

        cached_chat_id = REDIS.get(cache_key)

        if cached_chat_id
          Rails.logger.info("Cache hit for chat: #{cache_key}")
          @chat = Chat.find_by(id: cached_chat_id)
      
          render json: { error: 'Chat Not Found' }, status: 404 unless @chat
          return
        end

        Rails.logger.info("Cache miss for chat: #{cache_key}, querying database")
  
        # Fallback to DB query with a join if not found in cache
        @chat = Chat.joins(:application).find_by(chats: { number: chat_number }, applications: { token: application_token })
      
        if @chat
          # Cache the chat ID for future requests
          REDIS.set(cache_key, @chat.id)
        else
          render json: { error: 'Chat Not Found' }, status: 404
        end
      end

      def new_chat_number
        REDIS.incr("chat_counter_for_application_#{@application.token}")
      end

      def chat_params
        params.require(:chat).permit
      end

      def set_application
        token = params[:application_token]
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
