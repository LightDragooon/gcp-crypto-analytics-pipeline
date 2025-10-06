import os
import json
import requests
from google.cloud import pubsub_v1
from google.cloud import secretmanager

# --- Configuración ---
PROJECT_ID = "data-engineer-demo-a"
TOPIC_ID = "crypto-ingest-topic"
SECRET_ID = "coingecko-api-key"
API_URL = "https://api.coingecko.com/api/v3/simple/price"

# Parámetros para la API de CoinGecko
# Monedas a consultar y moneda de cotización (USD)
COIN_IDS = "bitcoin,ethereum,solana,cardano,ripple"
VS_CURRENCIES = "usd"
INCLUDE_MARKET_CAP = "true"
INCLUDE_24HR_VOL = "true"
INCLUDE_24HR_CHANGE = "true"
INCLUDE_LAST_UPDATED_AT = "true"

# --- Clientes ---
publisher = pubsub_v1.PublisherClient()
secret_client = secretmanager.SecretManagerServiceClient()

def get_api_key():
    """Accede a Secret Manager para obtener la API key."""
    name = f"projects/{PROJECT_ID}/secrets/{SECRET_ID}/versions/latest"
    response = secret_client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

def ingest_api_data(request):
    """
    Función principal activada por HTTP (Cloud Scheduler).
    Consulta la API de CoinGecko y publica el resultado en Pub/Sub.
    """
    topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
    api_key = get_api_key()

    params = {
        "ids": COIN_IDS,
        "vs_currencies": VS_CURRENCIES,
        "include_market_cap": str(INCLUDE_MARKET_CAP).lower(),
        "include_24hr_vol": str(INCLUDE_24HR_VOL).lower(),
        "include_24hr_change": str(INCLUDE_24HR_CHANGE).lower(),
        "include_last_updated_at": str(INCLUDE_LAST_UPDATED_AT).lower(),
        "x_cg_demo_api_key": api_key
    }

    try:
        response = requests.get(API_URL, params=params, timeout=10)
        response.raise_for_status()  # Lanza una excepción para errores HTTP 4xx/5xx
        data = response.json()

        # Publica cada resultado de moneda como un mensaje separado
        for coin, payload in data.items():
            message_data = {
                "coin_id": coin,
                "data": payload
            }
            message_json = json.dumps(message_data)
            future = publisher.publish(topic_path, message_json.encode("utf-8"))
            future.result() # Espera a que la publicación sea exitosa

        print(f"Datos publicados exitosamente para: {list(data.keys())}")
        return ("OK", 200)

    except requests.exceptions.RequestException as e:
        print(f"Error al llamar a la API de CoinGecko: {e}")
        return ("Error de API", 500)
    except Exception as e:
        print(f"Ocurrió un error inesperado: {e}")
        return ("Error interno", 500)