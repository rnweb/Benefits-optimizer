# SPO - SmartPurchase Optimizer

Version: 1.02

## Overview

SPO (SmartPurchase Optimizer) is a financial decision engine for the Brazilian market that helps users find the best deals by calculating the Effective Real Cost (ERC) of purchases using credit card points, cashback, and loyalty program miles.

## Features

- **Product Search**: Search products from local database or external stores
- **Goal-Based Recommendations**: Three optimization strategies:
  - 💰 CASH - Maximum cash return
  - ✈️ FAMILY - Maximum travel volume  
  - 💎 LUXURY - Maximum point value
- **Best Deals**: Shows top 5 ranked purchase options
- **Price Comparison**: Compares prices across multiple stores

## Tech Stack

- **Frontend**: DreamFlow (native DOM-based MVP)
- **Backend**: Supabase Edge Functions
- **Database**: Supabase PostgreSQL

## Supabase Edge Functions

| Function | Description |
|----------|-------------|
| `calculate-erc` | Calculate Effective Real Cost |
| `get-best-deals` | Get top ranked deals for a product |
| `get-products` | List/search products |
| `search-external-products` | Search external product sources |
| `add-product-with-prices` | Add product with prices from stores |
| `wallet` | User wallet management |
| `watchlist` | Product watchlist |

## Getting Started

### Prerequisites

- Node.js 18+
- Supabase CLI

### Build & Run

```bash
# Install dependencies
cd dreamflow
npm install

# Build native MVP
npm run build-native

# Start local server
npm run serve-native
```

Open http://localhost:8080/host.html

### Deploy Edge Functions

```bash
cd ../Benefits-optimizer/supabase/functions

# Deploy all functions
supabase functions deploy calculate-erc
supabase functions deploy get-best-deals
supabase functions deploy get-products
supabase functions deploy search-external-products
supabase functions deploy add-product-with-prices
supabase functions deploy wallet
supabase functions deploy watchlist
```

## API Endpoints

### Calculate ERC

```bash
curl -X POST https://punwkcttppysvbmkmohj.supabase.co/functions/v1/calculate-erc \
  -H "Content-Type: application/json" \
  -d '{
    "store_price": 8499,
    "credit_card_id": "91025215-1e2b-41ee-a902-49017f14171f",
    "loyalty_program_id": "9298b5c2-0705-405d-86f3-efdc79c33828"
  }'
```

### Get Best Deals

```bash
curl "https://punwkcttppysvbmkmohj.supabase.co/functions/v1/get-best-deals?product_id=1fc1356a-552e-403d-9a40-576b6db99047&goal=CASH"
```

## Database Schema

### Tables

- `products` - Product catalog
- `prices` - Product prices by store
- `stores` - Store information
- `credit_cards` - Credit card profiles
- `loyalty_programs` - Mile programs (Azul, LATAM, TAP, Iberia, AA)
- `cashback_programs` - Cashback portals
- `transfer_bonuses` - Bank transfer bonuses
- `exchange_rates` - USD/BRL exchange rates

### Credit Card Profiles

| Card | Domestic pts/$ | Points Program |
|------|----------------|----------------|
| BRB DUX | 5.0 | Curtaí |
| Santander Unlimited | 2.6 | Esfera |
| Amex Centurion | 2.5 | Membership Rewards |
| Bradesco Aeternum | 4.0 | Livelo |

### Mile Values (BRL/1k)

| Program | Value |
|---------|-------|
| American Airlines | 100 |
| Iberia Plus | 53 |
| TAP Miles&Go | 40 |
| LATAM Pass | 25 |
| Azul TudoAzul | 17 |
| Gol Smiles | 17 |

## ERC Formula

```
ERC = Store_Price - Cashback - Miles_Value

Miles_Value = (Points_Earned × (1 + Transfer_Bonus%)) × Mile_Value_per_1000
```

## License

MIT
