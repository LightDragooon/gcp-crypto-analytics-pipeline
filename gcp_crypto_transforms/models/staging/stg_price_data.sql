with source as (
    select
        json_extract_scalar(payload, '$.coin_id') as coin_id,
        json_extract_scalar(payload, '$.data.usd') as price_usd,
        json_extract_scalar(payload, '$.data.usd_market_cap') as market_cap_usd,
        json_extract_scalar(payload, '$.data.usd_24h_vol') as volume_24h_usd,
        json_extract_scalar(payload, '$.data.usd_24h_change') as change_24h_usd,
        json_extract_scalar(payload, '$.data.last_updated_at') as last_updated_at,
        ingestion_timestamp
    from {{ source('raw_data', 'raw_price_data') }}
),

renamed as (
    select
        coin_id,
        safe_cast(price_usd as numeric) as price_usd,
        safe_cast(market_cap_usd as numeric) as market_cap_usd,
        safe_cast(volume_24h_usd as numeric) as volume_24h_usd,
        safe_cast(change_24h_usd as numeric) as change_24h_usd,
        timestamp_seconds(safe_cast(last_updated_at as int64)) as last_updated_at_ts,
        ingestion_timestamp
    from source
)

select * from renamed