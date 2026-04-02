// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetailModel extends FlutterFlowModel {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

class ProductDetailWidget extends StatefulWidget {
  const ProductDetailWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<ProductDetailWidget> createState() => _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends State<ProductDetailWidget> {
  late ProductDetailModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? _product;
  List<dynamic> _prices = [];
  List<dynamic> _deals = [];
  String _selectedGoal = 'CASH';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductDetailModel());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load user's goal preference
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          final profile = await Supabase.instance.client
              .from('user_profiles')
              .select('goal_preference')
              .eq('id', user.id)
              .single();
          if (profile != null && profile['goal_preference'] != null) {
            _selectedGoal = profile['goal_preference'];
          }
        } catch (e) {}
      }

      // Load first product with prices (for MVP demo)
      final products = await Supabase.instance.client
          .from('products')
          .select()
          .limit(1);

      if (products != null && products.isNotEmpty) {
        _product = products[0];

        // Load prices for this product
        final prices = await Supabase.instance.client
            .from('prices')
            .select('*, stores(*)')
            .eq('product_id', _product!['id'])
            .eq('is_available', true)
            .order('price_brl');

        _prices = prices ?? [];

        // Load credit cards, loyalty programs for ERC calculation
        final cards = await Supabase.instance.client
            .from('credit_cards')
            .select()
            .eq('is_active', true);

        final loyalty = await Supabase.instance.client
            .from('loyalty_programs')
            .select()
            .eq('is_active', true);

        final bonuses = await Supabase.instance.client
            .from('transfer_bonuses')
            .select()
            .eq('is_active', true);

        final cashbacks = await Supabase.instance.client
            .from('cashback_programs')
            .select()
            .eq('is_active', true);

        // Calculate best deals
        _deals = _calculateBestDeals(
          prices: _prices,
          cards: cards ?? [],
          loyaltyPrograms: loyalty ?? [],
          bonuses: bonuses ?? [],
          cashbacks: cashbacks ?? [],
        );
      }
    } catch (e) {
      print('Error loading product: $e');
    }

    setState(() => _isLoading = false);
  }

  List<dynamic> _calculateBestDeals({
    required List<dynamic> prices,
    required List<dynamic> cards,
    required List<dynamic> loyaltyPrograms,
    required List<dynamic> bonuses,
    required List<dynamic> cashbacks,
  }) {
    final List<dynamic> deals = [];
    final exchangeRate = 5.15; // Default USD/BRL

    for (final price in prices) {
      for (final card in cards) {
        for (final loyalty in loyaltyPrograms) {
          final bonus = bonuses.firstWhere(
            (b) => b['loyalty_program_id'] == loyalty['id'],
            orElse: () => null,
          );

          // Calculate ERC without cashback
          final erc = _calculateERC(
            storePrice: (price['price_brl'] ?? 0).toDouble(),
            domesticPts: (card['domestic_pts_per_dollar'] ?? 0).toDouble(),
            mileValue: (loyalty['value_per_1000_miles'] ?? 17).toDouble(),
            bonusPct: bonus != null ? (bonus['bonus_percentage'] ?? 0).toDouble() : 0.0,
            exchangeRate: exchangeRate,
          );

          deals.add({
            'store_name': price['stores']?['name'] ?? 'Unknown',
            'store_price': price['price_brl'],
            'card_name': card['name'],
            'loyalty_name': loyalty['name'],
            'loyalty_code': loyalty['code'],
            'erc': erc,
            'savings': (price['price_brl'] ?? 0) - erc,
            'savings_pct': ((price['price_brl'] ?? 0) - erc) / (price['price_brl'] ?? 1) * 100,
          });
        }
      }
    }

    // Sort by ERC (lowest = best)
    deals.sort((a, b) => (a['erc'] as double).compareTo(b['erc'] as double));

    return deals.take(5).toList();
  }

  double _calculateERC({
    required double storePrice,
    required double domesticPts,
    required double mileValue,
    required double bonusPct,
    required double exchangeRate,
  }) {
    final points = (storePrice / exchangeRate) * domesticPts;
    final milesAfterBonus = points * (1 + bonusPct / 100);
    final milesValue = milesAfterBonus * (mileValue / 1000);
    return storePrice - milesValue;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Product Detail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64.0,
                  color: FlutterFlowTheme.of(context).secondaryText),
              SizedBox(height: 16.0),
              Text('No products yet',
                  style: FlutterFlowTheme.of(context).titleMedium),
              SizedBox(height: 8.0),
              Text('Add products via Supabase dashboard',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                      )),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        title: Text(
          'Product Detail',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!['name'] ?? 'Unknown Product',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                          fontSize: 20.0,
                        ),
                  ),
                  if (_product!['brand'] != null)
                    Text(
                      _product!['brand'],
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  SizedBox(height: 12.0),
                  Row(
                    children: [
                      Icon(Icons.store, size: 16.0,
                          color: FlutterFlowTheme.of(context).primary),
                      SizedBox(width: 4.0),
                      Text(
                        '${_prices.length} stores tracking',
                        style: FlutterFlowTheme.of(context).bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),

            // Best Deal Section
            if (_deals.isNotEmpty) ...[
              Text(
                'Best Deal (Goal: $_selectedGoal)',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      fontSize: 18.0,
                    ),
              ),
              SizedBox(height: 12.0),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Store Price',
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    color: Colors.white70,
                                    fontSize: 12.0,
                                  ),
                            ),
                            Text(
                              'R\$ ${(_deals[0]['store_price'] as num).toStringAsFixed(2)}',
                              style: FlutterFlowTheme.of(context).titleLarge.override(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.white54,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).success,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            '-${(_deals[0]['savings_pct'] as num).toStringAsFixed(1)}%',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'SPO Best Price',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: Colors.white70,
                            fontSize: 12.0,
                          ),
                    ),
                    Text(
                      'R\$ ${(_deals[0]['erc'] as num).toStringAsFixed(2)}',
                      style: FlutterFlowTheme.of(context).headlineLarge.override(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32.0,
                          ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        _buildDealChip(context, _deals[0]['card_name']),
                        SizedBox(width: 8.0),
                        _buildDealChip(context, _deals[0]['loyalty_code']),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'via ${_deals[0]['store_name']}',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0),
            ],

            // Top 5 Deals Table
            if (_deals.length > 1) ...[
              Text(
                'Top Deals Comparison',
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      fontSize: 18.0,
                    ),
              ),
              SizedBox(height: 12.0),
              ..._deals.asMap().entries.map((entry) {
                final index = entry.key;
                final deal = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? FlutterFlowTheme.of(context).primary.withOpacity(0.1)
                        : FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: index == 0
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.0,
                        height: 32.0,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? FlutterFlowTheme.of(context).primary
                              : FlutterFlowTheme.of(context).alternate,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  color: index == 0 ? Colors.white : null,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${deal['card_name']} + ${deal['loyalty_code']}',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0,
                                  ),
                            ),
                            Text(
                              deal['store_name'],
                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${(deal['erc'] as num).toStringAsFixed(2)}',
                            style: FlutterFlowTheme.of(context).titleSmall.override(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Save R\$ ${(deal['savings'] as num).toStringAsFixed(2)}',
                            style: FlutterFlowTheme.of(context).labelSmall.override(
                                  color: FlutterFlowTheme.of(context).success,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // Current Prices Section
            SizedBox(height: 24.0),
            Text(
              'Current Prices',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                    fontSize: 18.0,
                  ),
            ),
            SizedBox(height: 12.0),
            ..._prices.map((price) => Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store_outlined,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0),
                          SizedBox(width: 8.0),
                          Text(
                            price['stores']?['name'] ?? 'Unknown',
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ],
                      ),
                      Text(
                        'R\$ ${(price['price_brl'] as num).toStringAsFixed(2)}',
                        style: FlutterFlowTheme.of(context).titleSmall.override(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDealChip(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: FlutterFlowTheme.of(context).labelSmall.override(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
