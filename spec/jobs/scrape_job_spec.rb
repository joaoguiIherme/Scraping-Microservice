require 'rails_helper'

RSpec.describe ScrapeJob, type: :job do
  let(:task_id) { 1 }
  let(:valid_url) { 'https://example.com' }
  let(:invalid_url) { 'https://invalid-url.com' }
  let(:html_content) do
    '<html>
      <div class="vehicle-name__brand">Lamborghini</div>
      <div class="vehicle-name__model">Revuelto</div>
      <div class="offer-price__number">R$ 5.000.000</div>
    </html>'
  end

  before do
    # Configuração global para logs
    allow(Rails.logger).to receive(:error)

    # Mock para chamadas ao serviço de notificações
    allow(RestClient).to receive(:post).and_return(true)
  end

  describe '#perform' do
    context 'with a valid URL' do
      before do
        # Simula a resposta da página HTML
        allow(OpenURI).to receive(:open_uri).and_return(double(read: html_content))
      end

      it 'successfully scrapes the data' do
        expect {
          described_class.perform_now(task_id, valid_url)
        }.to change(ScrapedDatum, :count).by(1)

        scraped_data = ScrapedDatum.last
        expect(scraped_data.brand).to eq('Lamborghini')
        expect(scraped_data.model).to eq('Revuelto')
        expect(scraped_data.price).to eq('R$ 5.000.000')
      end
    end

    context 'with an invalid URL' do
      before do
        # Simula erro ao acessar a URL
        allow(OpenURI).to receive(:open_uri).and_raise(StandardError.new('Connection failed'))
      end

      it 'logs an error and does not create a record' do
        expect {
          described_class.perform_now(task_id, invalid_url)
        }.not_to change(ScrapedDatum, :count)

        expect(Rails.logger).to have_received(:error).with(/Error scraping URL https:\/\/invalid-url\.com: Connection failed/)
      end
    end

    context 'when notification service is unavailable' do
      before do
        # Simula o conteúdo da página HTML
        allow(OpenURI).to receive(:open_uri).and_return(double(read: html_content))

        # Simula que o serviço de notificações está indisponível
        allow_any_instance_of(ScrapeJob).to receive(:service_available?).and_return(false)
      end

      it 'logs an error instead of sending a notification' do
        described_class.perform_now(task_id, valid_url)

        expect(RestClient).not_to have_received(:post)
        expect(Rails.logger).to have_received(:error).with(/Notification service is not available/)
      end
    end
  end
end
