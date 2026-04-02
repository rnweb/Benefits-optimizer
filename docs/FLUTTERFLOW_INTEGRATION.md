# FlutterFlow Integration Guide - SPO App

## App Structure

```
SPO App
├── Auth
│   ├── LoginScreen
│   └── RegisterScreen
├── Main
│   ├── HomeScreen (The Radar)
│   ├── GoalSelectorScreen
│   ├── WalletScreen
│   └── SettingsScreen
├── Product
│   ├── ProductDetailScreen
│   ├── CompareDealsScreen
│   └── BestDealScreen
└── Watchlist
    ├── WatchlistScreen
    └── AddToWatchlistScreen
```

## Screen Definitions

### 1. HomeScreen (The Radar)
**Purpose:** Product watchlist with price comparison

**Widgets:**
- AppBar: "SPO Radar" with goal badge (CASH/FAMILY/LUXURY)
- SearchBar: Product search input
- ListView: Watched products
  - ProductCard
    - ProductImage
    - ProductName
    - CurrentLowestPrice
    - SPOBestPrice (with savings %)
    - TrendIcon (up/down/stable)
- FAB: Add product to watchlist

**Data Bindings:**
- Supabase Query: `watchlist` table joined with `products` and `prices`
- Real-time: Enable Supabase Realtime on watchlist table

---

### 2. GoalSelectorScreen
**Purpose:** Set optimization strategy

**Widgets:**
- 3 Large Cards (selectable):
  - **CASH** 💰
    - Title: "Maximum Cash Return"
    - Description: "Optimize for liquid savings via cashback + high-pts cards"
    - Best for: General purchases
  - **FAMILY** ✈️
    - Title: "Maximum Travel Volume"
    - Description: "Maximize seats for family trips via Azul/Smiles"
    - Best for: Flights
  - **LUXURY** 🏨
    - Title: "Maximum Point Value"
    - Description: "Highest value per point via Accor/Iberia transfers"
    - Best for: Hotels & Premium experiences
- Confirm Button

**Action:** Update `user_profiles.goal_preference`

---

### 3. WalletScreen
**Purpose:** Manage credit card portfolio

**Widgets:**
- Section: "Your Cards"
- ListView: User's cards
  - CardTile
    - CardName (BRB DUX, Santander Unlimited, etc.)
    - PointsRate (5pts/$ domestic, 7pts/$ intl)
    - PrimaryBadge (if is_primary)
    - DeleteIcon
- Section: "Available Cards"
- ListView: All credit_cards (filter out user's)
  - AddButton on each

**Data Bindings:**
- GET `/wallet` → user's cards
- POST `/wallet` → add card
- DELETE `/wallet` → remove card

---

### 4. ProductDetailScreen
**Purpose:** View product and best purchase options

**Widgets:**
- ProductImage (large)
- ProductName, Brand, Category
- Section: "Current Prices"
  - ListView: Prices from stores
    - StoreName
    - Price
    - LinkIcon
- Section: "Best Deal with SPO"
  - BestDealCard
    - Recommended Card
    - Loyalty Program
    - Cashback Portal
    - Effective Cost (ERC)
    - Savings Amount & %
    - CTA: "Calculate Full Breakdown"
- Button: "Add to Watchlist"

**Data Bindings:**
- GET `/get-best-deals?product_id={id}&goal={goal}`

---

### 5. CompareDealsScreen
**Purpose:** Side-by-side comparison of top deals

**Widgets:**
- GoalSelector (toggle CASH/FAMILY/LUXURY)
- DataTable or ListView:
  | Card | Loyalty | Cashback | Store | ERC | Savings |
- Highlight: Best option (lowest ERC)
- Detail expansion on tap

**Data Bindings:**
- GET `/get-best-deals?product_id={id}&goal={goal}`

---

### 6. BestDealScreen (Deep Dive)
**Purpose:** Full calculation breakdown for single deal

**Widgets:**
- Header: "SPO Recommendation"
- CalculationCard:
  - Store Price: R$ 8,499.00
  - Cashback (5%): -R$ 424.95
  - Points Earned: 42,495 pts
  - Transfer Bonus (100%): +42,495 pts
  - Total Miles: 84,990
  - Mile Value (@R$17/1k): R$ 1,444.83
  - **Effective Real Cost: R$ 6,629.22**
  - **Total Savings: R$ 1,869.78 (22%)**
- RecommendationText
- Button: "Buy Now" (opens store URL)

**Action:** POST `/calculate-erc` with specific params

---

### 7. WatchlistScreen
**Purpose:** Manage watched products with target prices

**Widgets:**
- ListView: Watched products
  - WatchlistTile
    - ProductName
    - TargetPrice (user set)
    - CurrentBestPrice
    - StatusBadge (Below Target / Above Target)
    - DeleteIcon

**Data Bindings:**
- GET `/watchlist`
- DELETE `/watchlist?id={id}`

---

## Navigation Flow

```
LoginScreen
    ↓
HomeScreen (Radar)
    ↓
ProductDetailScreen
    ↓
CompareDealsScreen → BestDealScreen
    ↓
HomeScreen (updated)

BottomNav:
- Home (Radar)
- Wallet
- Watchlist
- Settings/Goal
```

## FlutterFlow Configuration Steps

### Step 1: Create Project
1. Go to https://app.flutterflow.io
2. Create new project: "SPO - SmartPurchase Optimizer"
3. Select "Android" platform

### Step 2: Connect Supabase
1. Settings → Integrations → Supabase
2. Project URL: `https://punwkcttppysvbmkmohj.supabase.co`
3. Anon Key: (from Supabase Dashboard → API)
4. Enable Authentication
5. Sync Data Schema (auto-import tables)

### Step 3: Configure API Calls
1. Settings → API Calls
2. Add each endpoint (see API Endpoints section)

### Step 4: Build Pages
1. Create pages per Screen Definitions
2. Add widgets and bind data
3. Configure navigation

### Step 5: Test & Export
1. Run in FlutterFlow Preview
2. Export APK when ready

## API Endpoints for FlutterFlow

| Method | URL | Parameters | Description |
|--------|-----|------------|-------------|
| POST | `/functions/v1/calculate-erc` | product_id, store_id, store_price, credit_card_id, loyalty_program_id, cashback_program_id, is_international | Calculate ERC |
| GET | `/functions/v1/get-best-deals` | product_id, goal (CASH/FAMILY/LUXURY) | Get ranked deals |
| GET | `/functions/v1/watchlist` | - | Get user watchlist |
| POST | `/functions/v1/watchlist` | product_id, target_price | Add to watchlist |
| DELETE | `/functions/v1/watchlist` | id | Remove from watchlist |
| GET | `/functions/v1/wallet` | - | Get user cards |
| POST | `/functions/v1/wallet` | credit_card_id, is_primary | Add card |
| DELETE | `/functions/v1/wallet` | credit_card_id | Remove card |

## Color Scheme

- Primary: #1E88E5 (Blue - Trust)
- Secondary: #4CAF50 (Green - Savings)
- Accent: #FF9800 (Orange - Deals)
- Background: #FAFAFA (Light gray)
- Card: #FFFFFF
- Text Primary: #212121
- Text Secondary: #757575
