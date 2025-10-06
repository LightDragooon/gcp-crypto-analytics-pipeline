{{
  config(
    materialized='table'
  )
}}

-- Seleccionamos los datos exactos que necesita el modelo ARIMA_PLUS
SELECT
  snapshot_timestamp,
  price_usd,
  coin_id
FROM
  {{ ref('fct_price_snapshots') }}