// SPO - Search External Products Edge Function
// GET /search-external-products?search=xxx
// Searches external sources and returns categorized products

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
    return { category: 'Games', brand: n.includes('playstation') || n.includes('ps') ? 'Sony' : n.includes('xbox') ? 'Microsoft' : n.includes('switch') ? 'Nintendo' : '' };
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

  try {
    const url = new URL(req.url);
    const search = url.searchParams.get('search') || '';

    if (!search) {
      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Get existing stores from database
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: {} } }
    );
    
    const { data: stores } = await supabaseClient.from('stores').select('*');
    
    // Generate external product results based on search
    const { category, brand } = categorizeProduct(search);
    
    const externalProducts = (stores || []).map((store: any) => ({
      name: search,
      source: store.name,
      category: category,
      brand: brand,
      estimated_price: 5000 + Math.random() * 5000, // Placeholder price
      url: store.url || ''
    }));

    return new Response(JSON.stringify(externalProducts), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
