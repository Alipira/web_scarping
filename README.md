# 💰 Dollar‑Rate ETL Pipeline with Apache Airflow 🧩

Automates scraping of USD→IRR exchange rates using Selenium/BeautifulSoup, orchestrated by Airflow, and loads results into a SQL Server warehouse.

---

## 📁 Repo Structure

.
├── dags/
│ └── dollar_rate_dag.py
├── scraper/
│ └── scrape_dollar_rate.py
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── README.md
└── .github/
└── workflows/
└── license-check.yml
---

## 🚀 Setup Instructions

1. **Clone repo**  
   `git clone https://github.com/Alipira/web_scarping.git && cd web_scarping`

2. **Review licenses**  
   - Apache Airflow and Docker Compose are Apache‑2.0 licensed :contentReference[oaicite:22]{index=22}  
   - Custom code is yours—choose your license (e.g. MIT, Apache‑2.0)

3. **Build image & spin up services**
   ```bash
   docker-compose up --build
