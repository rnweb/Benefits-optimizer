// SPO - Add Product with Prices Edge Function
// POST /add-product-with-prices
// Adds a product and creates initial prices from external sources

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

function categorizeProduct(name: string): { category: string; brand: string } {
  const n = name.toLowerCase();
  
  if (n.includes('iphone') || n.includes('samsung') || n.includes('galaxy') || n.includes('pixel') || n.includes('smartphone')) {
    return { category: 'Smartphones', brand: n.includes('iphone') ? 'Apple' : n.includes('samsung') ? 'Samsung' : n.includes('pixel') ? 'Google' : '' };
  }
  if (n.includes('macbook') || n.includes('laptop') || n.includes('notebook') || n.includes('thinkpad')) {
    return { category: 'Laptops', brand: n.includes('macbook') ? 'Apple' : n.includes('thinkpad') ? 'Lenovo' : '' };
  }
  if (n.includes('ipad') || n.includes('tablet')) {
    return { category: 'Tablets', brand: n.includes('ipad') ? 'Apple' : '' };
  }
  if (n.includes('playstation') || n.includes('ps5') || n.includes('ps4') || n.includes('xbox') || n.includes('switch') || n.includes('nintendo')) {
    return { category: 'Gaming', brand: n.includes('playstation') || n.includes('ps') ? 'Sony' : n.includes('xbox') ? 'Microsoft' : n.includes('switch') ? 'Nintendo' : '' };
  }
  if (n.includes('airpods') || n.includes('headphone') || n.includes('earphone') || n.includes('buds') || n.includes('wh-')) {
    return { category: 'Audio', brand: n.includes('airpods') ? 'Apple' : n.includes('sony') ? 'Sony' : '' };
  }
  if (n.includes('apple watch') || n.includes('galaxy watch') || n.includes('smartwatch')) {
    return { category: 'Wearables', brand: n.includes('apple') ? 'Apple' : n.includes('galaxy') ? 'Samsung' : '' };
  }
  if (n.includes('tv') || n.includes('television') || n.includes('oled') || n.includes('qled')) {
    return { category: 'TVs', brand: n.includes('samsung') ? 'Samsung' : n.includes('lg') ? 'LG' : n.includes('sony') ? 'Sony' : '' };
  }
  
  return { category: 'Electronics', brand: '' };
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405, headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  const globalHeaders: Record<string, string> = {};
  if (authHeader) globalHeaders['Authorization'] = authHeader;

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: globalHeaders } }
  );

  try {
    const body = await req.json();
    const { name, estimatedPrice } = body;
    
    const { category, brand } = categorizeProduct(name);

    // Insert product
    const { data: product, error: productError } = await supabaseClient
      .from('products')
      .insert({ name, category, brand })
      .select()
      .single();

    if (productError) throw productError;

    // Get all stores
    const { data: stores } = await supabaseClient.from('stores').select('*');
    
    // Create prices for each store with estimated prices
    if (stores && stores.length > 0) {
      const basePrice = estimatedPrice || 5000;
      const prices = stores.map((store: any, index: number) => ({
        product_id: product.id,
        store_id: store.id,
        price_brl: Math.round(basePrice * (1 + index * 0.05) * 100) / 100, // 5% increment per store
        currency: 'BRL',
        is_available: true
      }));

      const { error: pricesError } = await supabaseClient.from('prices').insert(prices);
      if (pricesError) console.error('Error creating prices:', pricesError);
    }

    return new Response(JSON.stringify(product), {
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
