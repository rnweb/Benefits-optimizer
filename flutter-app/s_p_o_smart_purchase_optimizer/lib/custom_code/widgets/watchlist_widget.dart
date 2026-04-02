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

class WatchlistModel extends FlutterFlowModel {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

class WatchlistWidget extends StatefulWidget {
  const WatchlistWidget({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<WatchlistWidget> createState() => _WatchlistWidgetState();
}

class _WatchlistWidgetState extends State<WatchlistWidget> {
  late WatchlistModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _watchlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WatchlistModel());
    _loadWatchlist();
  }

  Future<void> _loadWatchlist() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load watchlist with product and price info
      final watchlist = await Supabase.instance.client
          .from('watchlist')
          .select('*, products(*)')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      // Get prices for each product
      for (var item in (watchlist ?? [])) {
        if (item['product_id'] != null) {
          final prices = await Supabase.instance.client
              .from('prices')
              .select('price_brl')
              .eq('product_id', item['product_id'])
              .eq('is_available', true)
              .order('price_brl')
              .limit(1);

          item['current_best_price'] =
              prices != null && prices.isNotEmpty ? prices[0]['price_brl'] : null;
        }
      }

      setState(() {
        _watchlist = watchlist ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFromWatchlist(String id) async {
    await Supabase.instance.client
        .from('watchlist')
        .update({'is_active': false})
        .eq('id', id);
    _loadWatchlist();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.bookmark, color: Colors.white, size: 24.0),
            SizedBox(width: 8.0),
            Text(
              'Watchlist',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                    color: Colors.white,
                    fontSize: 22.0,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _watchlist.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadWatchlist,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _watchlist.length,
                    itemBuilder: (context, index) =>
                        _buildWatchlistItem(_watchlist[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 72.0,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          SizedBox(height: 16.0),
          Text(
            'No products watching',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Add products from the Radar\nto track price changes',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistItem(dynamic item) {
    final product = item['products'] ?? {};
    final targetPrice = (item['target_price'] as num?)?.toDouble();
    final currentPrice = (item['current_best_price'] as num?)?.toDouble();
    final isBelowTarget =
        targetPrice != null && currentPrice != null && currentPrice <= targetPrice;

    return Dismissible(
      key: Key(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        margin: EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).error,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeFromWatchlist(item['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isBelowTarget
                ? FlutterFlowTheme.of(context).success
                : FlutterFlowTheme.of(context).alternate,
            width: isBelowTarget ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: FlutterFlowTheme.of(context).primary,
                size: 28.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown Product',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  if (product['brand'] != null)
                    Text(
                      product['brand'],
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                    ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      if (currentPrice != null)
                        Text(
                          'R\$ ${currentPrice.toStringAsFixed(2)}',
                          style:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      if (targetPrice != null) ...[
                        SizedBox(width: 8.0),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isBelowTarget
                                ? FlutterFlowTheme.of(context).success
                                : FlutterFlowTheme.of(context).alternate,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Target: R\$ ${targetPrice.toStringAsFixed(2)}',
                            style:
                                FlutterFlowTheme.of(context).labelSmall.override(
                                      color: isBelowTarget
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context)
                                              .secondaryText,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isBelowTarget)
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).success,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 20.0),
              )
            else
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: FlutterFlowTheme.of(context).secondaryText),
                onPressed: () => _removeFromWatchlist(item['id']),
              ),
          ],
        ),
      ),
    );
  }
}
