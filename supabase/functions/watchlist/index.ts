// =============================================
// SPO - Watchlist Management Edge Function
// CRUD /watchlist
// =============================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

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

    const {
      data: { user },
    } = await supabaseClient.auth.getUser();
    if (!user) {
      throw new Error('Unauthorized');
    }

    const url = new URL(req.url);

    switch (req.method) {
      case 'GET': {
        const { data, error } = await supabaseClient
          .from('watchlist')
          .select('*, products(*, prices(*, stores(*)))')
          .eq('user_id', user.id)
          .eq('is_active', true);

        if (error) throw error;
        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      case 'POST': {
        const body = await req.json();
        const { data, error } = await supabaseClient
          .from('watchlist')
          .insert({
            user_id: user.id,
            product_id: body.product_id,
            target_price: body.target_price,
          })
          .select()
          .single();

        if (error) throw error;
        return new Response(JSON.stringify(data), {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      case 'DELETE': {
        const id = url.searchParams.get('id');
        if (!id) throw new Error('Watchlist item id required');

        const { error } = await supabaseClient
          .from('watchlist')
          .update({ is_active: false })
          .eq('id', id)
          .eq('user_id', user.id);

        if (error) throw error;
        return new Response(JSON.stringify({ success: true }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }

      default:
        throw new Error('Method not allowed');
    }
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
