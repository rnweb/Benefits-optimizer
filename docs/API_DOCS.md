# SPO API Documentation for FlutterFlow

Base URL: `https://<project-ref>.functions.supabase.co`

## Authentication

All endpoints require Bearer token:
```
Authorization: Bearer <supabase_jwt_token>
```

---

## Endpoints

### 1. Calculate ERC

**POST** `/calculate-erc`

Calculate the Effective Real Cost for a specific purchase combination.

**Request Body:**
```json
{
  "product_id": "uuid",
  "store_id": "uuid",
  "store_price": 8499.00,
  "credit_card_id": "uuid",
  "loyalty_program_id": "uuid",
  "cashback_program_id": "uuid",    // optional
  "is_international": false
}
```

**Response:**
```json
{
  "erc": 5923.50,
  "store_price": 8499.00,
  "cashback_amount": 424.95,
  "miles_value": 2150.55,
  "transfer_bonus_value": 645.16,
  "total_benefits": 2575.50,
  "breakdown": {
    "price_store": 8499.00,
    "cashback_deduction": 424.95,
    "points_earned": 42495,
    "miles_after_bonus": 80740,
    "mile_value": 17.00,
    "miles_deduction": 2150.55
  },
  "recommendation": "EXCELLENT DEAL! Save 30.3% with Azul TudoAzul + 5.0% cashback. Earn 80740 miles."
}
```

---

### 2. Get Best Deals

**GET** `/get-best-deals?product_id={id}&goal={CASH|FAMILY|LUXURY}`

Returns top 10 ranked purchase scenarios for a product based on user goal.

| Goal | Strategy |
|------|----------|
| `CASH` | Max liquid return (highest cashback + best card) |
| `FAMILY` | Max seat volume for travel (Azul/Smiles) |
| `LUXURY` | Max value per point (Centurion → Accor/Iberia) |

**Response:**
```json
{
  "goal": "CASH",
  "top_deals": [
    {
      "erc": 5923.50,
      "store_price": 8499.00,
      "card_name": "BRB DUX",
      "loyalty_name": "Azul TudoAzul",
      "cashback_name": "Méliuz",
      "store_name": "Zoom.com.br",
      "recommendation": "EXCELLENT DEAL!..."
    }
  ]
}
```

---

### 3. Watchlist

Manage product radar.

**GET** `/watchlist`
Returns user's watched products with current prices.

**POST** `/watchlist`
```json
{
  "product_id": "uuid",
  "target_price": 7500.00
}
```

**DELETE** `/watchlist?id={watchlist_id}`

---

### 4. Wallet

Manage user's credit cards.

**GET** `/wallet`
Returns user's cards with full details.

**POST** `/wallet`
```json
{
  "credit_card_id": "uuid",
  "is_primary": true
}
```

**DELETE** `/wallet`
```json
{
  "credit_card_id": "uuid"
}
```

---

## Reference Data (Direct Supabase Tables)

These tables are public read-only:

| Table | Use Case |
|-------|----------|
| `loyalty_programs` | List available mile programs + values |
| `credit_cards` | List supported cards + point rates |
| `cashback_programs` | List cashback portals |
| `stores` | List tracked stores |
| `products` | Search product catalog |
| `prices` | Get current prices for a product |

**Example FlutterFlow Query:**
```sql
SELECT * FROM credit_cards WHERE is_active = true ORDER BY domestic_pts_per_dollar DESC
```

---

## FlutterFlow Integration Steps

1. **Create Supabase project** and get URL + anon key
2. **Add Supabase** in FlutterFlow → Integrations → Supabase
3. **Enable Auth** with Email provider
4. **Create API Calls:**
   - Type: `POST` → `https://<ref>.functions.supabase.co/calculate-erc`
   - Type: `GET` → `https://<ref>.functions.supabase.co/get-best-deals`
5. **Bind data** to widgets using the JSON responses
