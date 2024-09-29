class ChatWorker
  include Sidekiq::Worker

  def perform(application_id, application_token, chat_number)
    ActiveRecord::Base.connection_pool.with_connection do
      chat = Chat.create!(
        number: chat_number,
        application_id: application_id,
      )
      # If creation is successful, cache the chat ID
      cache_key = "chat_#{application_token}_#{chat_number}"
      REDIS.set(cache_key, chat.id)

      Rails.logger.info("Chat created successfully with number #{chat_number}. Cached ID: #{chat.id}")
    end
  end
end
