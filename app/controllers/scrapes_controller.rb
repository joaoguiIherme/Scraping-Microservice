class ScrapesController < ApplicationController
  def create
    task_id = params[:task_id]
    url = params[:url]

    if task_id.blank? || url.blank?
      render json: { error: 'Task ID and URL are required' }, status: :unprocessable_entity
      return
    end

    # Dispara o Job de Scraping
    ScrapeJob.perform_later(task_id, url)
    render json: { message: 'Scraping started successfully' }, status: :accepted
  end

  def completed
    task_id = params[:task_id]
    scraped_data = ScrapedDatum.where(task_id: task_id)

    if scraped_data.exists?
      render json: scraped_data, status: :ok
    else
      render json: { error: 'No data found for the provided task ID' }, status: :not_found
    end
  end

  def notify
    payload = params.permit(:task_id, :event_type, details: {})
    Rails.logger.info("Notification received: #{payload}")

    # Simplesmente loga por enquanto
    render json: { message: 'Notification received' }, status: :ok
  rescue StandardError => e
    Rails.logger.error("Error processing notification: #{e.message}")
    render json: { error: 'Error processing notification' }, status: :internal_server_error
  end
end
