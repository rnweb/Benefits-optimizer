// =============================================
// SPO - Get Best Deals Edge Function
// GET /get-best-deals?product_id=xxx
// =============================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { calculateERC, ERCCalculationInput } from '../_shared/erc-calculator.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Optional authorization header: allow anonymous calls
    const authHeader = req.headers.get('Authorization');
    const globalHeaders: Record<string, string> = {};
    if (authHeader) {
      globalHeaders['Authorization'] = authHeader;
    }
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: globalHeaders,
        },
      }
    );

    const url = new URL(req.url);
    const product_id = url.searchParams.get('product_id');
    const goal = url.searchParams.get('goal') ?? 'CASH'; // CASH, FAMILY, LUXURY

    if (!product_id) {
      throw new Error('product_id is required');
    }

    // Fetch product prices, cards, loyalty programs
    const [pricesRes, cardsRes, loyaltyRes, bonusesRes, cashbackRes, rateRes] =
      await Promise.all([
        supabaseClient
          .from('prices')
          .select('*, stores(*)')
          .eq('product_id', product_id)
          .eq('is_available', true)
          .order('price_brl', { ascending: true }),
        supabaseClient.from('credit_cards').select('*').eq('is_active', true),
        supabaseClient
          .from('loyalty_programs')
          .select('*')
          .eq('is_active', true),
        supabaseClient
          .from('transfer_bonuses')
          .select('*')
          .eq('is_active', true),
        supabaseClient
          .from('cashback_programs')
          .select('*')
          .eq('is_active', true),
        supabaseClient
          .from('exchange_rates')
          .select('*')
          .order('fetched_at', { ascending: false })
          .limit(1)
          .single(),
      ]);

    const prices = pricesRes.data ?? [];
    const cards = cardsRes.data ?? [];
    const loyaltyPrograms = loyaltyRes.data ?? [];
    const bonuses = bonusesRes.data ?? [];
    const cashbacks = cashbackRes.data ?? [];
    const exchangeRate = rateRes.data?.rate_usd_brl ?? 5.15;

    // Calculate all combinations
    const scenarios: ERCCalculationInput[] = [];

    for (const price of prices) {
      for (const card of cards) {
        for (const loyalty of loyaltyPrograms) {
          const bonus = bonuses.find(
            (b) => b.loyalty_program_id === loyalty.id
          );
          for (const cashback of cashbacks) {
            scenarios.push({
              store_price: price.price_brl,
              card,
              loyalty_program: loyalty,
              transfer_bonus: bonus ?? undefined,
              cashback_program: cashback,
              exchange_rate_usd_brl: exchangeRate,
            });
          }
          // Scenario without cashback
          scenarios.push({
            store_price: price.price_brl,
            card,
            loyalty_program: loyalty,
            transfer_bonus: bonus ?? undefined,
            exchange_rate_usd_brl: exchangeRate,
          });
        }
      }
    }

    // Calculate ERC for all scenarios and rank based on goal
    const results = scenarios
      .map((input) => ({
        ...calculateERC(input),
        card_name: input.card.name,
        card_points: input.card.domestic_pts_per_dollar,
        loyalty_name: input.loyalty_program.name,
        loyalty_value: input.loyalty_program.value_per_1000_miles,
        cashback_name: input.cashback_program?.name ?? 'None',
        cashback_pct: input.cashback_program?.percentage ?? 0,
        store_name:
          prices.find((p) => p.price_brl === input.store_price)?.stores?.name ??
          'Unknown',
      }))
      .sort((a, b) => {
        // Goal-based ranking
        if (goal === 'CASH') {
          // Cash: prioritize highest cashback, then best points
          const aScore = (a.cashback_pct * 0.6) + (a.card_points * 0.4);
          const bScore = (b.cashback_pct * 0.6) + (b.card_points * 0.4);
          return bScore - aScore || a.erc - b.erc;
        } else if (goal === 'FAMILY') {
          // Family: prioritize high-volume loyalty (Azul/Gol), then points
          const aFamily = a.loyalty_name.includes('Azul') || a.loyalty_name.includes('Gol') ? 1 : 0;
          const bFamily = b.loyalty_name.includes('Azul') || b.loyalty_name.includes('Gol') ? 1 : 0;
          return bFamily - aFamily || a.erc - b.erc;
        } else if (goal === 'LUXURY') {
          // Luxury: prioritize highest value per mile (Iberia/AA), then card points
          const aLuxury = a.loyalty_value;
          const bLuxury = b.loyalty_value;
          return bLuxury - aLuxury || a.erc - b.erc;
        }
        // Default: lowest ERC
        return a.erc - b.erc;
      })
      .slice(0, 10); // Top 10

    return new Response(JSON.stringify({ goal, top_deals: results }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
