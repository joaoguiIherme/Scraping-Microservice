require 'rails_helper'

RSpec.describe ScrapedDatum, type: :model do
  it 'is valid with valid attributes' do
    scraped_data = ScrapedDatum.new(
      task_id: 1,
      url: 'https://example.com',
      brand: 'Lamborghini',
      model: 'Revuelto',
      price: 'R$ 5.000.000'
    )
    expect(scraped_data).to be_valid
  end

  it 'is invalid without a task_id' do
    scraped_data = ScrapedDatum.new(task_id: nil)
    expect(scraped_data).to_not be_valid
    expect(scraped_data.errors[:task_id]).to include("can't be blank")
  end

  it 'is invalid without a URL' do
    scraped_data = ScrapedDatum.new(url: nil)
    expect(scraped_data).to_not be_valid
    expect(scraped_data.errors[:url]).to include("can't be blank")
  end
end
