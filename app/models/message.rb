require 'elasticsearch/model'
class Message < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  validates :body, presence: true

  belongs_to :chat

  after_commit :reindex

  settings index: {
    number_of_shards: 1,
    number_of_replicas: 0,
    analysis: {
      analyzer: {
        trigram: {
          tokenizer: 'trigram'
        }
      },
      tokenizer: {
        trigram: {
          type: 'ngram',
          min_gram: 3,
          max_gram: 3,
          token_chars: %w(letter digit)
        }
      }
    }
  } do
    mappings dynamic: false do
      indexes :body, type: :text, analyzer: 'trigram'
      indexes :chat_id, type: :integer
    end
  end

  def self.partial_search(value, chat)
    __elasticsearch__.search(
      query: {
        bool: {
          must: {
            match: {
              body: {
                query: value,
                analyzer: 'trigram'
              }
            }
          },
          filter: [
            { term: { chat_id: chat.id } },
          ]
        }
      },
    )
  end

  def update_and_reindex(params)
    # Delete the old document from Elasticsearch if it exists
    __elasticsearch__.delete_document if persisted?

    # Update the message attributes
    update(params)

    # Reindex the new message if valid
    __elasticsearch__.index_document if valid?
  end

  private

  def reindex
    __elasticsearch__.index_document
  end
end
