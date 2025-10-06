-- depends on: {{ ref('fct_training_data') }}

{{
  config(
    materialized='table'
  )
}}

-- Ejecutamos la función de pronóstico usando una referencia al modelo de ML
SELECT
  *
FROM
  ML.FORECAST(MODEL `{{ target.project }}.{{ target.dataset }}.{{ var('ml_model_name') }}`,
              STRUCT(30 AS horizon, 0.8 AS confidence_level))