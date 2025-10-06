import base64
import json
import os
from datetime import datetime, timezone
from google.cloud import bigquery

# --- Configuración ---
PROJECT_ID = "data-engineer-demo-a"
DATASET_ID = "crypto_data_warehouse"
TABLE_ID = "raw_price_data"

# --- Cliente ---
client = bigquery.Client()

def pubsub_to_bigquery(event, context):
    """
    Función activada por un mensaje de Pub/Sub.
    Decodifica el mensaje y lo inserta en BigQuery vía streaming.
    """
    # Decodifica el mensaje de Pub/Sub
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    message_data = json.loads(pubsub_message)

    # Prepara la fila a insertar
    rows_to_insert = [
        {
            "payload": json.dumps(message_data),
            "ingestion_timestamp": datetime.now(timezone.utc).isoformat()
        }
    ]

    table_ref = client.dataset(DATASET_ID).table(TABLE_ID)

    try:
        # Inserta la fila usando streaming inserts
        errors = client.insert_rows_json(table_ref, rows_to_insert)
        if errors == []:
            print("Nueva fila ha sido añadida a BigQuery.")
        else:
            print(f"Errores encontrados al insertar filas: {errors}")
    except Exception as e:
        print(f"Error al insertar en BigQuery: {e}")