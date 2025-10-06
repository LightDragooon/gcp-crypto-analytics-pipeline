select
    ingestion_timestamp as snapshot_timestamp,
    coin_id,
    price_usd,
    market_cap_usd,
    volume_24h_usd,
    change_24h_usd,
    last_updated_at_ts
from {{ ref('stg_price_data') }}