#!/usr/bin/env node

// =============================================
// SPO API Test Script
// Run: node scripts/test-api.js
// =============================================

const SUPABASE_URL = 'https://punwkcttppysvbmkmohj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1bndrY3R0cHB5c3ZibWttb2hqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNTMyNTksImV4cCI6MjA5MDcyOTI1OX0.dwAYotGaxP8NK8rqeEqlbVuDlbITOrUVDNTJC39pX64';

const headers = {
  'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
  'apikey': SUPABASE_ANON_KEY,
  'Content-Type': 'application/json',
};

async function testEndpoint(name, url, method = 'GET', body = null) {
  console.log(`\n🧪 Testing: ${name}`);
  console.log(`   ${method} ${url}`);
  
  try {
    const options = {
      method,
      headers,
    };
    
    if (body) {
      options.body = JSON.stringify(body);
    }
    
    const response = await fetch(url, options);
    const data = await response.json();
    
    if (response.ok) {
      console.log(`   ✅ Status: ${response.status}`);
      console.log(`   📦 Response:`, JSON.stringify(data, null, 2).substring(0, 500));
      return { success: true, data };
    } else {
      console.log(`   ❌ Status: ${response.status}`);
      console.log(`   📦 Error:`, JSON.stringify(data, null, 2));
      return { success: false, error: data };
    }
  } catch (error) {
    console.log(`   ❌ Error: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function runTests() {
  console.log('==========================================');
  console.log('SPO API Test Suite');
  console.log('==========================================');
  
  const results = [];
  
  // Test 1: Get Best Deals
  results.push(await testEndpoint(
    'Get Best Deals',
    `${SUPABASE_URL}/functions/v1/get-best-deals?goal=CASH`
  ));
  
  // Test 2: Calculate ERC
  results.push(await testEndpoint(
    'Calculate ERC',
    `${SUPABASE_URL}/functions/v1/calculate-erc`,
    'POST',
    {
      store_price: 8499.00,
      credit_card_id: 'test',
      loyalty_program_id: 'test',
      is_international: false
    }
  ));
  
  // Test 3: Get Watchlist (requires auth - will fail with 401 expected)
  results.push(await testEndpoint(
    'Get Watchlist',
    `${SUPABASE_URL}/functions/v1/watchlist`
  ));
  
  // Test 4: Get Wallet (requires auth - will fail with 401 expected)
  results.push(await testEndpoint(
    'Get Wallet',
    `${SUPABASE_URL}/functions/v1/wallet`
  ));
  
  // Summary
  console.log('\n==========================================');
  console.log('Test Summary');
  console.log('==========================================');
  
  const passed = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  
  console.log(`✅ Passed: ${passed}`);
  console.log(`❌ Failed: ${failed}`);
  console.log(`📊 Total: ${results.length}`);
  
  if (failed > 0) {
    console.log('\n⚠️  Note: Auth failures (401) are expected for Watchlist and Wallet');
    console.log('   These endpoints require user authentication.');
  }
}

runTests().catch(console.error);
