💰 Dollar-Rate ETL Pipeline with Apache Airflow 🧩
Automates scraping of USD→IRR exchange rates using Selenium/BeautifulSoup, orchestrated by Airflow, and loads results into a SQL Server warehouse.

Table of Contents

Prerequisites
Setup Instructions
Usage
Configuration
Project Structure
Contributing
License
Acknowledgments


Prerequisites
Before you begin, ensure you have the following installed:

Docker
Docker Compose
Git


Setup Instructions

Clone the repository
git clone https://github.com/Alipira/web_scarping.git
cd web_scarping


Build image & spin up services
docker-compose up --build

This builds the Docker images and starts the containers, including Apache Airflow and the SQL Server database.

Access Airflow's web interface
Once running, access the Airflow web UI at http://localhost:8080 to manage the pipeline.

Stop the services
To shut down, run:
docker-compose down




Usage
Manage the pipeline via the Airflow web interface:

Enable the DAG: On the DAGs page, toggle the dollar_rate_etl DAG to "On".
Trigger manually: Select the DAG and click "Trigger DAG".
Monitor: View run statuses and logs to ensure successful execution.

Data is loaded into the SQL Server database, accessible with details from the configuration section.

Configuration
The pipeline connects to a SQL Server database. The default setup includes a containerized SQL Server with preset credentials. For an external database, edit docker-compose.yml under the airflow service with these variables:

SQL_SERVER_HOST: Hostname or IP (default: db)
SQL_SERVER_PORT: Port (default: 1433)
SQL_SERVER_USER: Username (default: sa)
SQL_SERVER_PASSWORD: Password (default: YourStrongPassword123)
SQL_SERVER_DATABASE: Database name (default: exchange_rates)

Use a strong password for security.

Project Structure
web_scarping/
├── dags/                   # Airflow DAG definitions
│   └── dollar_rate_etl.py  # Main ETL workflow
├── scripts/                # Scraping and processing scripts
│   └── scrape_exchange_rates.py  # Exchange rate scraper
├── Dockerfile              # Custom Airflow image
├── docker-compose.yml      # Service orchestration
├── README.md               # This file
└── requirements.txt        # Python dependencies


dags/: Airflow DAGs for the ETL process.
scripts/: Python code for scraping and transformation.
Dockerfile: Airflow image configuration.
docker-compose.yml: Multi-container setup.
requirements.txt: Project dependencies.


Contributing
Contributions are appreciated! Submit issues or pull requests for enhancements or fixes.

License
This project uses the MIT License for custom code—see LICENSE for details.
Dependencies:

Apache Airflow: Apache-2.0
Docker Compose: Apache-2.0


Acknowledgments
Built with these awesome tools:

Selenium
BeautifulSoup
Apache Airflow
Docker
