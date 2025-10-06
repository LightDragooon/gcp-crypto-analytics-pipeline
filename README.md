# Proyecto End-to-End de Ingeniería de Datos en GCP

<p align="center">
  <img src="https://img.shields.io/badge/Google%20Cloud-4285F4?logo=googlecloud&logoColor=fff&style=plastic" alt="Google Cloud"/>
  <img src="https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=fff&style=plastic" alt="Terraform"/>
  <img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff&style=plastic" alt="Python"/>
  <img src="https://img.shields.io/badge/dbt-FF694B?logo=dbt&logoColor=fff&style=plastic" alt="dbt"/>
</p>
<p align="center">
  <img src="https://img.shields.io/badge/Cloud_Functions-4285F4?style=plastic&logo=google-cloud&logoColor=fff" alt="Cloud Functions"/>
  <img src="https://img.shields.io/badge/Google%20Pub%2FSub-4285F4?logo=googlepubsub&logoColor=fff&style=plastic" alt="Pub/Sub"/>
  <img src="https://img.shields.io/badge/Google%20BigQuery-4285F4?logo=googlebigquery&logoColor=fff&style=plastic" alt="BigQuery"/>
  <img src="https://img.shields.io/badge/Looker-4285F4?logo=looker&logoColor=fff&style=plastic" alt="Looker Studio"/>
</p>


## 📊 Dashboard Interactivo

La mejor forma de ver el proyecto en acción es a través del dashboard interactivo en vivo. Este informe presenta los resultados finales del pipeline, incluyendo los pronósticos generados por el modelo de Machine Learning.

### [Ver el Dashboard en Looker Studio](https://lookerstudio.google.com/reporting/ff1ce20d-1a1e-4431-807f-b9cf01e8921b)

<img width="583" height="415" alt="LookerDashboard" src="https://github.com/user-attachments/assets/6282bc9f-fba5-450b-9060-60b32a95315c" />

---

## 📝 Resumen del Proyecto

Este proyecto implementa un pipeline de datos **end-to-end, serverless y en tiempo real** en Google Cloud Platform. La solución completa está diseñada para operar íntegramente dentro de los límites del **nivel gratuito (Free Tier) de GCP**.

El pipeline ingiere datos de precios de criptomonedas desde la API de **Coin Gecko**, los procesa a través de un flujo de eventos, los modela en un esquema analítico dentro de **BigQuery**, entrena un modelo de **Machine Learning** para realizar pronósticos de series temporales, y finalmente visualiza tanto los datos históricos como las predicciones en un dashboard interactivo de **Looker Studio**.

## 🏛️ Arquitectura de la Solución

La arquitectura es 100% serverless y se basa en eventos, lo que garantiza una alta escalabilidad y un bajo mantenimiento operativo.

`Cloud Scheduler` ➔ `Cloud Function (Ingesta)` ➔ `Pub/Sub` ➔ `Cloud Function (Carga)` ➔ `BigQuery (Datos Crudos)` ➔ `dbt` ➔ `BigQuery (Marts Analíticos)` ➔ `BigQuery ML` ➔ `Looker Studio`

---

## ✨ Características Principales

* **Infraestructura como Código (IaC):** Toda la infraestructura de GCP es aprovisionada y gestionada de forma declarativa con **Terraform**.
* **Pipeline de Ingesta Automatizado:** Un job de **Cloud Scheduler** invoca periódicamente una **Cloud Function** en Python para consultar la API de CoinGecko.
* **Procesamiento de Eventos en Tiempo Real:** **Pub/Sub** actúa como un buffer de mensajes desacoplado y escalable, activando una segunda **Cloud Function** que carga los datos en BigQuery en modo streaming.
* **Modelado de Datos Robusto:** **dbt Core** se utiliza para transformar los datos crudos en un esquema de estrella optimizado para el análisis, con tablas de hechos y dimensiones, y aplicando pruebas de calidad de datos.
* **Análisis Predictivo con ML:** Se entrena y ejecuta un modelo de pronóstico de series temporales **(ARIMA_PLUS)** directamente en el data warehouse usando **BigQuery ML**.
* **Visualización Interactiva:** Un dashboard en **Looker Studio** permite a los usuarios finales explorar los datos históricos y las predicciones del modelo, con filtros interactivos y KPIs.
* **Optimización de Costos:** Todos los servicios y el volumen de datos están cuidadosamente seleccionados para operar sin generar ningún costo dentro del **GCP Free Tier**.

---

## 🛠️ Stack Tecnológico y Habilidades Demostradas

| Dominio                   | Herramientas y Tecnologías                                 | Habilidades Aplicadas                                                               |
| :------------------------ | :--------------------------------------------------------- | :---------------------------------------------------------------------------------- |
| **Plataforma Cloud** | Google Cloud Platform (GCP)                                | Arquitectura de soluciones en la nube, gestión de servicios.                        |
| **Infraestructura** | Terraform                                                  | Infraestructura como Código (IaC), gestión declarativa de recursos.                 |
| **Ingesta y Orquestación**| Cloud Functions (Python), Pub/Sub, Cloud Scheduler         | Desarrollo serverless, arquitectura basada en eventos, orquestación de tareas.      |
| **Almacenamiento (DWH)** | Google BigQuery                                            | Data Warehousing, SQL, tablas particionadas, optimización de consultas.             |
| **Transformación (ELT)** | dbt Core                                                   | Modelado de datos (Esquema de Estrella), SQL analítico, pruebas de calidad de datos. |
| **Machine Learning** | BigQuery ML (ARIMA_PLUS)                                   | MLOps (Models-as-Code), pronóstico de series temporales, entrenamiento en DWH.      |
| **Visualización (BI)** | Looker Studio                                              | Creación de dashboards, diseño de KPIs, visualización de datos.                     |

---

## 🔐 Gestión de Permisos (IAM)

Para que el pipeline funcione correctamente, las Cuentas de Servicio (Service Accounts) utilizadas por los diferentes componentes necesitan los siguientes roles de IAM:

| Componente / Cuenta de Servicio | Rol de IAM Requerido | Propósito |
| :--- | :--- | :--- |
| **Cloud Function (`ingest-api-data`)** | **`Accesor de Secretos de Secret Manager`** | Para leer la API Key de CoinGecko desde Secret Manager. |
| | **`Publicador de Pub/Sub`** | Para publicar los datos de la API en el tema de Pub/Sub. |
| **Cloud Function (`load-data-to-bq`)** | **`Usuario de BigQuery`** | Para ejecutar trabajos de inserción en BigQuery. |
| | **`Editor de Datos de BigQuery`** | Para escribir (insertar) filas en las tablas de BigQuery. |
| **Cuenta de Servicio para `dbt`** | **`Usuario de BigQuery`** | Para ejecutar consultas, leer y crear tablas/vistas durante `dbt run`. |
| | **`Editor de Datos de BigQuery`** | Para modificar y eliminar tablas y datasets. |

---

## 📂 Estructura del Repositorio

```
.
├── functions/
│   ├── ingest/
│   └── load/
├── gcp_crypto_transforms/
│   ├── models/
│   └── ...
├── terraform/
│   ├── main.tf
│   └── terraform.tfvars
├── .gitignore
└── README.md
```

---

## 🚀 Cómo Desplegar el Proyecto

### Prerrequisitos
1.  Cuenta de Google Cloud con facturación habilitada (se mantendrá en el nivel gratuito).
2.  `gcloud` CLI instalado y configurado.
3.  `Terraform` instalado.
4.  `Python 3.9+` instalado.
5.  `dbt-core` y `dbt-bigquery` instalados.
6.  API Key de CoinGecko.

### Pasos para el Despliegue
1.  **Clonar el Repositorio:**
    ```bash
    git clone https://github.com/LightDragooon/gcp-crypto-analytics-pipeline.git
    cd gcp-crypto-analytics-pipeline
    ```
2.  **Aprovisionar la Infraestructura:**
    * Navega al directorio `/terraform`.
    * Renombra `terraform.tfvars.example` a `terraform.tfvars` y rellena tu `gcp_project_id` y `gcp_region`.
    * Ejecuta `terraform init` y luego `terraform apply`.
3.  **Configurar Secretos:**
    * Añade tu API Key de CoinGecko a Secret Manager usando el comando `gcloud secrets versions add...`
4.  **Desplegar las Cloud Functions:**
    * Navega a cada directorio en `/functions` y despliega la función usando el comando `gcloud functions deploy...`
5.  **Ejecutar las Transformaciones y Entrenar el Modelo:**
    * Navega al directorio `/dbt_project`.
    * Configura tu `profiles.yml` para conectar a BigQuery.
    * Ejecuta `dbt deps` para instalar los paquetes.
    * Ejecuta `dbt run` para materializar los modelos, entrenar el modelo de ML y generar el pronóstico.
    * Ejecuta `dbt test` para verificar la calidad de los datos.
6.  **Visualizar en Looker Studio:**
    * Conecta Looker Studio a la vista `v_price_history_and_forecasts` en BigQuery y replica el dashboard.

---

## Referencia Rápida de Comandos (Cheat Sheet)

Una referencia rápida de los comandos utilizados a lo largo de este proyecto.

### 🐍 Python & Entorno Virtual
| Comando | Descripción |
| :--- | :--- |
| `python -m venv dbt-env` | Crea un nuevo entorno virtual de Python llamado `dbt-env`. |
| `source dbt-env/bin/activate` | Activa el entorno virtual (en macOS/Linux). |
| `dbt-env\Scripts\activate.bat`| Activa el entorno virtual (en Windows CMD). |
| `dbt-env\Scripts\Activate.ps1`| Activa el entorno virtual (en Windows PowerShell). |
| `pip install -r requirements.txt`| Instala las dependencias de Python listadas en un archivo. |

### ☁️ gcloud (Google Cloud SDK)
| Comando | Descripción |
| :--- | :--- |
| `gcloud auth application-default login` | Autentica tu máquina para que las librerías cliente puedan usar tus credenciales. |
| `gcloud functions deploy ingest-api-data ...` | Despliega la función de ingesta. **Ver comando detallado abajo.** |
| `gcloud functions deploy load-data-to-bq ...` | Despliega la función de carga a BigQuery. **Ver comando detallado abajo.** |
| `gcloud secrets versions add ...` | Añade una nueva versión (valor) a un secreto en Secret Manager. |
| `gcloud scheduler jobs pause ...` | Pausa un trabajo programado en Cloud Scheduler. |

#### Comandos de Despliegue Detallados
```bash
# Comando para la función de INGESTA (API -> Pub/Sub)
gcloud functions deploy ingest-api-data \
  --gen2 \
  --runtime=python311 \
  --region=<YOUR_REGION> \
  --source=./functions/ingest \
  --entry-point=ingest_api_data \
  --trigger-http \
  --allow-unauthenticated

# Comando para la función de CARGA (Pub/Sub -> BigQuery)
gcloud functions deploy load-data-to-bq \
  --gen2 \
  --runtime=python311 \
  --region=<YOUR_REGION> \
  --source=./functions/load \
  --entry-point=pubsub_to_bigquery \
  --trigger-topic=crypto-ingest-topic
```

### 🏛️ Terraform (Infraestructura como Código)
| Comando | Descripción |
| :--- | :--- |
| `terraform init` | Inicializa el directorio de trabajo, descargando los proveedores necesarios. |
| `terraform plan` | Crea un plan de ejecución, mostrando qué cambios se aplicarán. |
| `terraform apply` | Aplica los cambios para crear o actualizar la infraestructura. |
| `terraform destroy` | Elimina toda la infraestructura gestionada por Terraform. |

### 🌱 dbt (Data Build Tool)
| Comando | Descripción |
| :--- | :--- |
| `dbt init [nombre_proyecto]` | Inicializa un nuevo proyecto de dbt. |
| `dbt deps` | Descarga e instala los paquetes definidos en `packages.yml`. |
| `dbt run` | Ejecuta todos los modelos de tu proyecto, materializando tablas/vistas. |
| `dbt test` | Ejecuta todas las pruebas de calidad de datos definidas en los archivos `.yml`. |
| `dbt build` | Ejecuta `dbt run` y `dbt test` en secuencia, construyendo solo los recursos que han cambiado. |
| `dbt debug` | Prueba la conexión con el data warehouse y muestra información de configuración. |

---
### Ingesta de datos en Pub/Sub - Frecuencia 2 min

<img width="445" height="156" alt="PubSub-Every2min-ingest" src="https://github.com/user-attachments/assets/4f9f82be-b32f-45f0-86d1-b3326a1fd136" />

---
### Autor

**Esteban Chavarría Fallas**
* [LinkedIn](https://www.linkedin.com/in/esteban-chavarria-fallas)
* [GitHub](https://github.com/LightDragooon)
