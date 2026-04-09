# SPO - SmartPurchase Optimizer
## Next Session Knowledge Base

**Version:** 1.02  
**Repository:** https://github.com/rnweb/Benefits-optimizer  
**Supabase Project:** punwkcttppysvbmkmohj  
**Website:** https://punwkcttppysvbmkmohj.supabase.co

---

## 📋 Project Summary

SPO (SmartPurchase Optimizer) is a financial decision engine for the Brazilian market that calculates the **Effective Real Cost (ERC)** of purchases by subtracting the monetary value of credit card points and cashback from the retail price. The frontend is now running as a native DreamFlow MVP.

---

## 🗂️ Current Inventory

### Supabase Edge Functions (8 total)
| Function | Purpose |
|----------|---------|
| `calculate-erc` | Calculate ERC with no-auth support |
| `get-best-deals` | Get top 10 ranked deals with goal-based sorting |
| `get-products` | List/search products from database |
| `search-external-products` | Search external stores (mock data) |
| `add-product-with-prices` | Add product with auto-created prices |
| `wallet` | User wallet management |
| `watchlist` | Product watchlist |
| `_shared/erc-calculator.ts` | Shared ERC calculation logic |

### Database Tables
- `products` - Product catalog
- `prices` - Prices by store
- `stores` - Store information
- `credit_cards` - 4 cards (BRB DUX, Santander Unlimited, Amex Centurion, Bradesco Aeternum)
- `loyalty_programs` - 6 programs (AA, Iberia, TAP, LATAM, Azul, Gol)
- `cashback_programs` - 3 programs (Méliuz 5%, Cuponomia 3%, PicPay 2%)
- `transfer_bonuses` - Bank transfer bonuses
- `exchange_rates` - USD/BRL rate

### DreamFlow MVP (Local)
- **Location:** `C:\dreamflow`
- **Build:** `npm run build-native`
- **Serve:** `npm run serve-native` (port 8080)
- **Entry:** `native/dist/dreamflow-native.js` → `host.html`

---

## 🔑 Important IDs

### Credit Cards
| Name | ID |
|------|-----|
| BRB DUX | `91025215-1e2b-41ee-a902-49017f14171f` |
| Santander Unlimited | `018a7900-51e1-401f-a96d-53e490381300` |
| Amex Centurion | `650ce963-c18f-42fd-a8d1-c9406efb71d5` |
| Bradesco Aeternum | (not queried yet) |

### Loyalty Programs
| Name | ID | Value/1k |
|------|-----|----------|
| American Airlines AAdvantage | `017244af-72a7-4b2b-a898-546b16e729ce` | R$100 |
| Iberia Plus | `3a3aa2dd-e83f-498b-867e-4ecbce24a893` | R$53 |
| TAP Miles&Go | `79392c17-f561-4e0e-a7ce-0822cfd5377c` | R$40 |
| LATAM Pass | `54117213-7705-4844-a69e-12d26c37c91d` | R$25 |
| Azul TudoAzul | `9298b5c2-0705-405d-86f3-efdc79c33828` | R$17 |
| Gol Smiles | `0fc0bd8b-cb42-498d-89a9-bd253932e12f` | R$17 |

### Products (Sample)
| Name | ID |
|------|-----|
| iPhone 16 Pro Max 256GB | `1fc1356a-552e-403d-9a40-576b6db99047` |
| Samsung Galaxy S25 Ultra | `00f35efd-8f8f-4b5a-8405-ae1c5687fc8e` |
| MacBook Air M3 15" | `1450ca32-2835-486c-ad8d-c5aee6bee589` |
| Sony PlayStation 5 | `dde94648-b5a3-4920-9905-fd56028e1088` |

---

## ⚙️ Key Configurations

### Supabase Connection
- **URL:** https://punwkcttppysvbmkmohj.supabase.co
- **Anon Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64`

### RLS Policies (Public Access)
- `products` - SELECT, INSERT
- `prices` - SELECT, INSERT
- `stores` - SELECT
- `credit_cards` - SELECT
- `loyalty_programs` - SELECT
- `cashback_programs` - SELECT
- `transfer_bonuses` - SELECT
- `exchange_rates` - SELECT

---

## 🧠 Tips & Recommendations

### For Next Session
1. **Deploy via GitHub Actions** - Push to main triggers `deploy-functions.yml` which deploys all edge functions
2. **Test with curl first** - Before using UI, verify endpoints with:
   ```bash
   curl -X POST https://punwkcttppysvbmkmohj.supabase.co/functions/v1/calculate-erc -H Content-Type:application/json -d @payload.json
   ```
3. **Version increment** - Update `VERSION` in `dreamflow/native/app.ts` on each rebuild (currently 1.02)
4. **Category naming** - Use "Games" not "Gaming" to match existing DB

### Known Limitations
- External search uses mock data (needs real Google Shopping API integration)
- No authentication flow yet (token-based features not implemented)
- Prices for new products are estimated (need real scraper)

### Quick Local Testing
```powershell
cd C:\dreamflow
npm install
npm run build-native
npm run serve-native
# Open http://localhost:8080/host.html
```

---

## 🚀 Next Steps (Priority Order)

1. **Production-ready external search** - Integrate real Google Shopping API
2. **Price scraping** - Add real-time price updates from stores
3. **User authentication** - Implement Supabase Auth for wallet/watchlist
4. **Mobile app** - Port DreamFlow MVP to React Native or Flutter
5. **Notifications** - Add price alerts when deals drop below threshold

---

## 📝 Quick Commands Reference

```bash
# Deploy single function
supabase functions deploy calculate-erc --project-ref punwkcttppysvbmkmohj --use-api --no-verify-jwt

# Query database
supabase db query "SELECT * FROM products;" --linked

# Build DreamFlow
npm run build-native

# Start local server
npm run serve-native
```

---

*Last Updated: April 2026*