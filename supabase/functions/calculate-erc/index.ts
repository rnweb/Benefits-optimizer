// =============================================
// SPO - Calculate ERC Edge Function
// POST /calculate-erc
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
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    );

    const {
      product_id,
      store_id,
      store_price,
      credit_card_id,
      loyalty_program_id,
      cashback_program_id,
      is_international = false,
    } = await req.json();

    // Fetch required data
    const [cardRes, loyaltyRes, bonusRes, cashbackRes, rateRes] =
      await Promise.all([
        supabaseClient
          .from('credit_cards')
          .select('*')
          .eq('id', credit_card_id)
          .single(),
        supabaseClient
          .from('loyalty_programs')
          .select('*')
          .eq('id', loyalty_program_id)
          .single(),
        supabaseClient
          .from('transfer_bonuses')
          .select('*')
          .eq('loyalty_program_id', loyalty_program_id)
          .eq('is_active', true)
          .single(),
        cashback_program_id
          ? supabaseClient
              .from('cashback_programs')
              .select('*')
              .eq('id', cashback_program_id)
              .single()
          : Promise.resolve({ data: null }),
        supabaseClient
          .from('exchange_rates')
          .select('*')
          .order('fetched_at', { ascending: false })
          .limit(1)
          .single(),
      ]);

    if (!cardRes.data || !loyaltyRes.data) {
      throw new Error('Card or loyalty program not found');
    }

    const input: ERCCalculationInput = {
      store_price,
      card: cardRes.data,
      loyalty_program: loyaltyRes.data,
      transfer_bonus: bonusRes.data ?? undefined,
      cashback_program: cashbackRes.data ?? undefined,
      exchange_rate_usd_brl: rateRes.data?.rate_usd_brl ?? 5.15,
      is_international,
    };

    const result = calculateERC(input);

    // Store calculation
    const {
      data: { user },
    } = await supabaseClient.auth.getUser();
    if (user) {
      await supabaseClient.from('erc_calculations').insert({
        user_id: user.id,
        product_id,
        store_id,
        credit_card_id,
        cashback_program_id,
        loyalty_program_id,
        store_price,
        cashback_amount: result.cashback_amount,
        miles_value: result.miles_value,
        transfer_bonus: result.transfer_bonus_value,
        erc: result.erc,
        calculation_details: result.breakdown,
      });
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
