---

# Scraping Microservice

The **Scraping Microservice** is a dedicated service within a multi-service architecture designed to handle scraping tasks and update task statuses. It communicates seamlessly with other services, such as the Notifications and Main App, to process and provide scraping data. Built using Ruby on Rails, it is fully containerized for ease of deployment and scalability.

---

## Features

- **Scraping Task Management**:
  - Processes scraping tasks requested by the Main App.
- **Task Status Updates**:
  - Updates the task status in the Main App based on the scraping results.
- **Inter-Service Communication**:
  - Communicates with the Notifications Service and Main App to notify users of scraping progress.
- **Dockerized Deployment**:
  - Easy to set up and deploy using Docker Compose.

---

## Architecture

The **Scraping Microservice** plays a vital role in the ecosystem by handling all scraping-related operations. It interacts with other services over a shared Docker network (`app_network`) to ensure smooth operation.

---

## Prerequisites

Before setting up the Scraping Microservice, ensure you have:

- [Docker](https://www.docker.com/get-started) installed (Version 20.10 or higher).
- [Docker Compose](https://docs.docker.com/compose/) installed (Version 2.x or higher).
- PostgreSQL (via Docker).
- Access to other repositories in the ecosystem:
  - [Main App](https://github.com/joaoguiIherme/Main-Tasks-App)
  - [Auth Service](https://github.com/joaoguiIherme/Auth-Microservice)
  - [Notifications Service](https://github.com/joaoguiIherme/Notifications-Microservice)

---

## Installation

### 1. Clone the Repository

Clone this repository into your workspace:
```bash
git clone https://github.com/joaoguiIherme/Scraping-Microservice.git
cd Scraping-Microservice
```

### 2. File Structure Adjustment

Ensure this microservice is placed in the same directory as the other services. The recommended directory structure is as follows:

```plaintext
Main-Root Dir/
├── auth_service/
├── main_app/
├── notifications_service/
├── scraping_service/ (this repository)
└── docker-compose.yml
```

Ensure the `docker-compose.yml` file is located in the root directory for multi-service orchestration.

### 3. Build and Start Services

Use Docker Compose to build and run all services:
```bash
docker-compose up --build
```

### 4. Access the Scraping Service

The Scraping Microservice runs on [http://localhost:4002](http://localhost:4002).

---

## API Endpoints

The following endpoints are exposed by the Scraping Microservice:

### POST `/scraping/start`
- **Description**: Starts a new scraping task.
- **Request Body**:
  - `task_id` (Integer): ID of the task to scrape.
  - `scraping_parameters` (Hash): Parameters for the scraping task.
- **Response**:
  - `200 OK`: Scraping task successfully started.
  - `400 Bad Request`: Invalid parameters.

### GET `/scraping/status/:task_id`
- **Description**: Retrieves the status of a scraping task.
- **Parameters**:
  - `task_id` (Integer): ID of the task.
- **Response**:
  - `200 OK`: Task status retrieved successfully.
  - `404 Not Found`: Task not found.

### POST `/scraping/complete`
- **Description**: Updates the task status to `completed` after scraping is done.
- **Request Body**:
  - `task_id` (Integer): ID of the task.
  - `result` (Hash): Scraping results.
- **Response**:
  - `200 OK`: Task status updated.
  - `404 Not Found`: Task not found.

---

## Configuration

### Environment Variables

This service relies on environment variables, which are defined in the `docker-compose.yml` file:

- `DATABASE_URL`: Connection string for the PostgreSQL database.

### Network Configuration

The service uses the `app_network` Docker network to communicate with other services. Ensure that the service names in your code (e.g., `main_app`, `notifications_service`) match those defined in `docker-compose.yml`.

---

## Testing

Run the following commands to test the Scraping Microservice:

### 1. Access the Container

```bash
docker exec -it scraping_service bash
```

### 2. Run Tests

Run RSpec tests to validate functionality:
```bash
bundle exec rspec
```

---

## Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Ensure the `db` service is running and the `DATABASE_URL` is correctly set.

2. **Task Status Not Updating**:
   - Verify that the Main App and Notifications Service are running and accessible.

3. **Host Authorization Errors**:
   - Add `config.hosts << "scraping_service"` in `config/application.rb` if needed.

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes and push to your fork.
4. Submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

---

## Acknowledgments

The Scraping Microservice demonstrates the power of modular design and microservices architecture. It integrates seamlessly with other services to provide a scalable and efficient solution for task scraping.

--- 

Feel free to request any specific adjustments or additional details for the README!
