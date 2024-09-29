class MessageWorker
  include Sidekiq::Worker

  def perform(application_token, chat_id, message_number, body)
    ActiveRecord::Base.connection_pool.with_connection do
      Message.create!(
        number: message_number,
        chat_id: chat_id,
        body: body,
      )

      cache_key = "app_#{application_token}_chat_#{chat_number}_message_#{message_number}"
      REDIS.set(cache_key, message.id)

      Rails.logger.info("Message created successfully with number #{message_number} for chat #{chat_number}. Cached ID: #{message.id}")

    end
  end
end
