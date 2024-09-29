class Application < ApplicationRecord
  has_many :chats, dependent: :destroy
  validates :name, presence: true
  validates :token, presence: true
end
