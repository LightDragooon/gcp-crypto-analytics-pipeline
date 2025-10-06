select
    distinct coin_id,
    case
        when coin_id = 'bitcoin' then 'Bitcoin'
        when coin_id = 'ethereum' then 'Ethereum'
        when coin_id = 'solana' then 'Solana'
        when coin_id = 'cardano' then 'Cardano'
        when coin_id = 'ripple' then 'XRP'
        else initcap(coin_id)
    end as coin_name
from {{ ref('stg_price_data') }}