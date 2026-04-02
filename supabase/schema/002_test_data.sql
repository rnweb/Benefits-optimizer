-- =============================================
-- SPO Test Data - Run in Supabase SQL Editor
-- =============================================

-- Insert sample stores
INSERT INTO stores (name, url, is_trusted) VALUES
    ('Zoom.com.br', 'https://www.zoom.com.br', true),
    ('Google Shopping', 'https://shopping.google.com.br', true),
    ('Amazon BR', 'https://www.amazon.com.br', true),
    ('Magazine Luiza', 'https://www.magazineluiza.com.br', true),
    ('Casas Bahia', 'https://www.casasbahia.com.br', true);

-- Insert sample product
INSERT INTO products (name, category, brand, sku, description) VALUES
    ('iPhone 16 Pro Max 256GB', 'Smartphones', 'Apple', 'IPHONE16PM256', 'Apple iPhone 16 Pro Max 256GB'),
    ('Samsung Galaxy S25 Ultra', 'Smartphones', 'Samsung', 'S25U256', 'Samsung Galaxy S25 Ultra 256GB'),
    ('MacBook Air M3 15"', 'Laptops', 'Apple', 'MBA15M3', 'Apple MacBook Air 15" M3'),
    ('Sony PlayStation 5', 'Games', 'Sony', 'PS5', 'Sony PlayStation 5 Console');

-- Insert sample prices for iPhone 16 Pro Max
INSERT INTO prices (product_id, store_id, price_brl, is_available)
SELECT 
    p.id,
    s.id,
    CASE s.name
        WHEN 'Zoom.com.br' THEN 8499.00
        WHEN 'Google Shopping' THEN 8599.00
        WHEN 'Amazon BR' THEN 8699.00
        WHEN 'Magazine Luiza' THEN 8799.00
        WHEN 'Casas Bahia' THEN 8999.00
    END,
    true
FROM products p, stores s
WHERE p.name = 'iPhone 16 Pro Max 256GB';

-- Insert sample prices for Samsung Galaxy S25 Ultra
INSERT INTO prices (product_id, store_id, price_brl, is_available)
SELECT 
    p.id,
    s.id,
    CASE s.name
        WHEN 'Zoom.com.br' THEN 7299.00
        WHEN 'Google Shopping' THEN 7399.00
        WHEN 'Amazon BR' THEN 7499.00
        WHEN 'Magazine Luiza' THEN 7599.00
        WHEN 'Casas Bahia' THEN 7699.00
    END,
    true
FROM products p, stores s
WHERE p.name = 'Samsung Galaxy S25 Ultra';

-- Insert sample prices for MacBook Air M3
INSERT INTO prices (product_id, store_id, price_brl, is_available)
SELECT 
    p.id,
    s.id,
    CASE s.name
        WHEN 'Zoom.com.br' THEN 10499.00
        WHEN 'Google Shopping' THEN 10599.00
        WHEN 'Amazon BR' THEN 10699.00
        WHEN 'Magazine Luiza' THEN 10799.00
        WHEN 'Casas Bahia' THEN 10899.00
    END,
    true
FROM products p, stores s
WHERE p.name = 'MacBook Air M3 15"';

-- Insert sample prices for PlayStation 5
INSERT INTO prices (product_id, store_id, price_brl, is_available)
SELECT 
    p.id,
    s.id,
    CASE s.name
        WHEN 'Zoom.com.br' THEN 3299.00
        WHEN 'Google Shopping' THEN 3399.00
        WHEN 'Amazon BR' THEN 3499.00
        WHEN 'Magazine Luiza' THEN 3599.00
        WHEN 'Casas Bahia' THEN 3699.00
    END,
    true
FROM products p, stores s
WHERE p.name = 'Sony PlayStation 5';

-- Insert exchange rate
INSERT INTO exchange_rates (rate_usd_brl, source) VALUES
    (5.15, 'BCB');

-- Verify data
SELECT 'Products:' as info, COUNT(*) as count FROM products
UNION ALL
SELECT 'Stores:', COUNT(*) FROM stores
UNION ALL
SELECT 'Prices:', COUNT(*) FROM prices
UNION ALL
SELECT 'Credit Cards:', COUNT(*) FROM credit_cards
UNION ALL
SELECT 'Loyalty Programs:', COUNT(*) FROM loyalty_programs
UNION ALL
SELECT 'Transfer Bonuses:', COUNT(*) FROM transfer_bonuses
UNION ALL
SELECT 'Cashback Programs:', COUNT(*) FROM cashback_programs;
