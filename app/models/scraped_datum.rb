class ScrapedDatum < ApplicationRecord
  validates :task_id, :url, :brand, :model, :price, presence: true
end
