require 'nokogiri'
require 'open-uri'
require 'rest-client'

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(task_id, url)
    doc = parse_html(url)

    # Extração de dados
    brand = extract_data(doc, '.vehicle-name__brand')
    model = extract_data(doc, '.vehicle-name__model')
    price = extract_data(doc, '.offer-price__number')

    # Armazena os dados
    scraped_data = save_data(task_id, url, brand, model, price)

    # Notifica o Microserviço de Notificações
    notify_completion(task_id, scraped_data)
  rescue StandardError => e
    handle_error(task_id, url, e)
  end

  private

  def parse_html(url)
    Nokogiri::HTML(OpenURI.open_uri(url))
  end

  def extract_data(doc, selector)
    doc.css(selector).text.strip
  end

  def save_data(task_id, url, brand, model, price)
    ScrapedDatum.create!(
      task_id: task_id,
      url: url,
      brand: brand,
      model: model,
      price: price
    )
  end

  def notify_completion(task_id, scraped_data)
    payload = {
      task_id: task_id,
      event_type: 'scrape_completed',
      details: "Scraping completed for #{scraped_data.brand} #{scraped_data.model} at #{scraped_data.price}"
    }
    send_notification(payload)
  end

  def notify_failure(task_id, error_message)
    payload = {
      task_id: task_id,
      event_type: 'scrape_failed',
      details: "Scraping failed with error: #{error_message}"
    }
    send_notification(payload)
  end

  def send_notification(payload)
    main_app_url = 'http://main_app:3000/notifications/update_task_status'
  
    begin
      if service_available?('main_app', 3000)
        RestClient.post(main_app_url, payload.to_json, { content_type: :json, accept: :json })
      else
        Rails.logger.error("Main app service is not available. Payload: #{payload}")
      end
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("Failed to send notification to main app: #{e.response}")
    rescue StandardError => e
      Rails.logger.error("Unexpected error while sending notification: #{e.message}")
    end
  end

  def service_available?(host, port)
    Net::HTTP.start(host, port) {}
    true
  rescue Errno::ECONNREFUSED, SocketError
    false
  end

  def handle_error(task_id, url, error)
    Rails.logger.error("Error scraping URL #{url}: #{error.message}")
    notify_failure(task_id, error.message)
  end
end
