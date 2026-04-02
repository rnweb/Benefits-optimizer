-- =============================================
-- SPO (SmartPurchase Optimizer) Database Schema
-- Supabase PostgreSQL
-- =============================================

-- 1. LOYALTY PROGRAMS (Mile Value Reference)
-- =============================================
CREATE TABLE IF NOT EXISTS loyalty_programs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE,
    value_per_1000_miles DECIMAL(10,2) NOT NULL, -- R$ per 1,000 miles
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed loyalty programs
INSERT INTO loyalty_programs (name, code, value_per_1000_miles) VALUES
    ('American Airlines AAdvantage', 'AA', 100.00),
    ('Iberia Plus', 'IB', 53.00),
    ('TAP Miles&Go', 'TAP', 40.00),
    ('LATAM Pass', 'LATAM', 25.00),
    ('Azul TudoAzul', 'AZUL', 17.00),
    ('Gol Smiles', 'SMILES', 17.00);

-- 2. TRANSFER BONUSES (Bank to Loyalty Program)
-- =============================================
CREATE TABLE IF NOT EXISTS transfer_bonuses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bank_name VARCHAR(100) NOT NULL,
    loyalty_program_id UUID REFERENCES loyalty_programs(id) ON DELETE CASCADE,
    bonus_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed transfer bonuses
INSERT INTO transfer_bonuses (bank_name, loyalty_program_id, bonus_percentage)
SELECT 'Livelo', lp.id, 100.0 FROM loyalty_programs lp WHERE lp.code = 'AZUL'
UNION ALL
SELECT 'Livelo', lp.id, 90.0 FROM loyalty_programs lp WHERE lp.code = 'SMILES'
UNION ALL
SELECT 'Livelo', lp.id, 30.0 FROM loyalty_programs lp WHERE lp.code = 'LATAM'
UNION ALL
SELECT 'Esfera', lp.id, 100.0 FROM loyalty_programs lp WHERE lp.code = 'AZUL'
UNION ALL
SELECT 'Esfera', lp.id, 90.0 FROM loyalty_programs lp WHERE lp.code = 'SMILES'
UNION ALL
SELECT 'Esfera', lp.id, 30.0 FROM loyalty_programs lp WHERE lp.code = 'LATAM';

-- 3. CREDIT CARDS (Titans)
-- =============================================
CREATE TABLE IF NOT EXISTS credit_cards (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    issuer VARCHAR(100) NOT NULL,
    points_program VARCHAR(100) NOT NULL,
    domestic_pts_per_dollar DECIMAL(5,2) NOT NULL,
    intl_pts_per_dollar DECIMAL(5,2) NOT NULL,
    cashback_percentage DECIMAL(5,2) DEFAULT 0,
    annual_fee DECIMAL(10,2) DEFAULT 0,
    special_rules TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed credit cards
INSERT INTO credit_cards (name, issuer, points_program, domestic_pts_per_dollar, intl_pts_per_dollar, special_rules) VALUES
    ('BRB DUX', 'BRB', 'Curtaí', 5.0, 7.0, 'Highest domestic accumulation rate'),
    ('Santander Unlimited', 'Santander', 'Esfera', 2.6, 3.6, 'Monitor Bateu Ganhou campaigns'),
    ('Amex Centurion', 'American Express', 'Membership Rewards', 2.5, 2.5, '1:1 Parity to ALL Accor & Iberia'),
    ('Bradesco Aeternum', 'Bradesco', 'Livelo', 4.0, 4.0, 'Points never expire');

-- 4. EXCHANGE RATES (USD/BRL)
-- =============================================
CREATE TABLE IF NOT EXISTS exchange_rates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rate_usd_brl DECIMAL(10,4) NOT NULL,
    source VARCHAR(50) DEFAULT 'BCB',
    fetched_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. CASHBACK PROGRAMS
-- =============================================
CREATE TABLE IF NOT EXISTS cashback_programs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    percentage DECIMAL(5,2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO cashback_programs (name, percentage, description) VALUES
    ('Méliuz', 5.00, 'Cashback via Méliuz portal'),
    ('Cuponomia', 3.00, 'Cashback via Cuponomia portal'),
    ('PicPay', 2.00, 'Cashback via PicPay');

-- 6. STORES
-- =============================================
CREATE TABLE IF NOT EXISTS stores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    url VARCHAR(500),
    is_trusted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. PRODUCTS
-- =============================================
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    category VARCHAR(100),
    brand VARCHAR(100),
    sku VARCHAR(100),
    image_url VARCHAR(500),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. PRICES (Real-time from scrapers)
-- =============================================
CREATE TABLE IF NOT EXISTS prices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    price_brl DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'BRL',
    url VARCHAR(500),
    scraped_at TIMESTAMPTZ DEFAULT NOW(),
    is_available BOOLEAN DEFAULT true
);

CREATE INDEX idx_prices_product ON prices(product_id);
CREATE INDEX idx_prices_scraped ON prices(scraped_at DESC);

-- 9. USER PROFILES (Wallet)
-- =============================================
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    goal_preference VARCHAR(20) DEFAULT 'CASH', -- CASH, FAMILY, LUXURY
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. USER WALLET (Selected Cards)
-- =============================================
CREATE TABLE IF NOT EXISTS user_wallet (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    credit_card_id UUID REFERENCES credit_cards(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, credit_card_id)
);

-- 11. WATCHLIST (Product Radar)
-- =============================================
CREATE TABLE IF NOT EXISTS watchlist (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    target_price DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 12. ERC CALCULATIONS (Cache results)
-- =============================================
CREATE TABLE IF NOT EXISTS erc_calculations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    credit_card_id UUID REFERENCES credit_cards(id) ON DELETE CASCADE,
    cashback_program_id UUID REFERENCES cashback_programs(id),
    loyalty_program_id UUID REFERENCES loyalty_programs(id),
    store_price DECIMAL(10,2) NOT NULL,
    cashback_amount DECIMAL(10,2) DEFAULT 0,
    miles_value DECIMAL(10,2) DEFAULT 0,
    transfer_bonus DECIMAL(5,2) DEFAULT 0,
    erc DECIMAL(10,2) NOT NULL, -- Effective Real Cost
    calculation_details JSONB,
    calculated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_erc_user ON erc_calculations(user_id);
CREATE INDEX idx_erc_product ON erc_calculations(product_id);
CREATE INDEX idx_erc_value ON erc_calculations(erc ASC);

-- 13. PRICE ALERTS (Notifications)
-- =============================================
CREATE TABLE IF NOT EXISTS price_alerts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES user_profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    target_price DECIMAL(10,2) NOT NULL,
    is_triggered BOOLEAN DEFAULT false,
    triggered_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS POLICIES
-- =============================================
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_wallet ENABLE ROW LEVEL SECURITY;
ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE erc_calculations ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can manage own wallet" ON user_wallet
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own watchlist" ON watchlist
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own calculations" ON erc_calculations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own alerts" ON price_alerts
    FOR ALL USING (auth.uid() = user_id);

-- Public read access for reference data
ALTER TABLE loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE cashback_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read loyalty" ON loyalty_programs FOR SELECT USING (true);
CREATE POLICY "Public read cards" ON credit_cards FOR SELECT USING (true);
CREATE POLICY "Public read cashback" ON cashback_programs FOR SELECT USING (true);
CREATE POLICY "Public read stores" ON stores FOR SELECT USING (true);
CREATE POLICY "Public read products" ON products FOR SELECT USING (true);
CREATE POLICY "Public read prices" ON prices FOR SELECT USING (true);
