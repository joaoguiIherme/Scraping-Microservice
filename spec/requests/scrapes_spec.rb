require 'rails_helper'

RSpec.describe 'Scrapes', type: :request do
  let(:valid_params) do
    {
      task_id: 1,
      url: 'https://www.webmotors.com.br/comprar/lamborghini/revuelto/65-v12-phev-amt/2-portas/2024/55331657?pos=p55331657g:&np=1'
    }
  end

  describe 'POST /scrapes' do
    it 'starts a scraping task with valid parameters' do
      post '/scrapes', params: valid_params
      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)['message']).to eq('Scraping started successfully')
    end

    it 'returns an error for missing task_id or URL' do
      post '/scrapes', params: { task_id: nil, url: nil }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Task ID and URL are required')
    end
  end

  describe 'POST /scrapes/completed' do
    before do
      ScrapedDatum.create!(
        task_id: 1,
        url: 'https://example.com',
        brand: 'Lamborghini',
        model: 'Revuelto',
        price: 'R$ 5.000.000'
      )
    end

    it 'returns scraped data for a valid task_id' do
      post '/scrapes/completed', params: { task_id: 1 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.first['brand']).to eq('Lamborghini')
      expect(json.first['model']).to eq('Revuelto')
      expect(json.first['price']).to eq('R$ 5.000.000')
    end

    it 'returns an error for an invalid task_id' do
      post '/scrapes/completed', params: { task_id: 999 }
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('No data found for the provided task ID')
    end
  end
end
