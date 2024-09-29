module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_chat
      before_action :set_message, only: %i(show update)
      def index
        @messages = @chat.messages
        render json: MessageBlueprint.render_as_hash(@messages), status: :ok
      end

      def create
        @message = @chat.messages.build(message_params)
        @message.number = new_message_number
        if @message.valid?
          MessageWorker.perform_async(params[:application_token], @chat.id, @message.number, @message.body)
          render json: MessageBlueprint.render_as_hash(@message), status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      def search
        @messages = Message.partial_search(params['query'], @chat).results.to_a
        render json: MessageBlueprint.render_as_hash(@messages)
      end

      def show
        render json: MessageBlueprint.render_as_hash(@message), status: :ok
      end

      def update
        if @message.valid?
          MessageUpdateWorker.perform_async(@message.id, message_params.to_h)
          render json: { id: @message.id }, status: :ok
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      # def destroy
      #   @message.destroy
      # end

      private


      def set_chat
        @chat = find_chat_in_cache || find_chat_in_database
    
        unless @chat
          render json: { error: 'Chat Not Found' }, status: 404
        end
      end

      def find_chat_in_cache
        cache_key = chat_cache_key
        cached_chat_id = REDIS.get(cache_key)
    
        if cached_chat_id
          Rails.logger.info("Cache hit for chat: #{cache_key}")
          chat = Chat.find_by(id: cached_chat_id)
          return chat if chat
    
          # If the chat was removed from the DB but still in cache, invalidate cache
          REDIS.del(cache_key)
          Rails.logger.info("Invalidated stale cache for chat: #{cache_key}")
        end
    
        nil
      end
    

      def find_chat_in_database
        Rails.logger.info("Cache miss, querying database for chat: #{chat_cache_key}")
    
        chat = Chat.joins(:application)
                   .find_by(chats: { number: params[:chat_number] }, applications: { token: params[:application_token] })
    
        if chat
          # Cache the chat ID for future requests
          REDIS.set(chat_cache_key, chat.id)
          Rails.logger.info("Chat ID cached: #{chat_cache_key} => #{chat.id}")
        end
    
        chat
      end

      def chat_cache_key
        "chat_#{params[:application_token]}_#{params[:chat_number]}"
      end



      def set_message
        @message = find_message_in_cache || find_message_in_database
    
        unless @message
          render json: { error: 'Message Not Found' }, status: :not_found
        end
      end

      def find_message_in_cache
        cache_key = message_cache_key
        message_id = REDIS.get(cache_key)
    
        if message_id
          Rails.logger.info("Cache hit for message: #{cache_key}")
          
          return Message.find_by(id: message_id)  
          Rails.logger.info("Cache hit for message: #{cache_key}")

        else
          Rails.logger.info("Cache miss for message: #{cache_key}")
          nil
        end
      end
    
      def find_message_in_database
        # Assuming `params[:message_number]` holds the message number
        Message.find_by(chat_id: @chat.id, number: params[:number]).tap do |message|

          if message
            # Cache the message ID for future requests
            cache_key = message_cache_key
            REDIS.set(cache_key, message.id)
            return message
          end
        end
      end

      def message_cache_key 
        "app_#{params[:application_token]}_chat_#{params[:chat_number]}_message_#{params[:number]}"
      end

      def message_params
        params.require(:message).permit(:body)
      end

      def new_message_number
        REDIS.incr(message_cache_key)
      end
    end
  end
end
