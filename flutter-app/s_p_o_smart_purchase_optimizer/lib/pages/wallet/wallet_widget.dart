import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletModel extends FlutterFlowModel {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

class WalletWidget extends StatefulWidget {
  const WalletWidget({super.key});

  static String routeName = 'Wallet';
  static String routePath = '/wallet';

  @override
  State<WalletWidget> createState() => _WalletWidgetState();
}

class _WalletWidgetState extends State<WalletWidget> {
  late WalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _userCards = [];
  List<dynamic> _availableCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WalletModel());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load all credit cards
      final cardsResponse = await Supabase.instance.client
          .from('credit_cards')
          .select()
          .eq('is_active', true);

      // Load user's wallet
      final walletResponse = await Supabase.instance.client
          .from('user_wallet')
          .select('*, credit_cards(*)')
          .eq('user_id', user.id);

      final userCardIds = (walletResponse as List)
          .map((w) => w['credit_card_id'])
          .where((id) => id != null)
          .toSet();

      setState(() {
        _userCards = walletResponse;
        _availableCards = (cardsResponse as List)
            .where((card) => !userCardIds.contains(card['id']))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading wallet: $e');
    }
  }

  Future<void> _addCard(String cardId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('user_wallet').upsert({
      'user_id': user.id,
      'credit_card_id': cardId,
      'is_primary': false,
    });
    _loadData();
  }

  Future<void> _removeCard(String cardId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client
        .from('user_wallet')
        .delete()
        .eq('user_id', user.id)
        .eq('credit_card_id', cardId);
    _loadData();
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
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.wallet,
              color: Colors.white,
              size: 24.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'My Wallet',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.interTight(
                      fontWeight: FontWeight.bold,
                    ),
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
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Cards (${_userCards.length})',
                      style:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                ),
                                fontSize: 18.0,
                              ),
                    ),
                    SizedBox(height: 12.0),
                    if (_userCards.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.credit_card_off,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 48.0,
                            ),
                            SizedBox(height: 12.0),
                            Text(
                              'No cards added yet',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                  ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._userCards.map((wallet) => _buildUserCard(wallet)),
                    SizedBox(height: 24.0),
                    Text(
                      'Available Cards',
                      style:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w600,
                                ),
                                fontSize: 18.0,
                              ),
                    ),
                    SizedBox(height: 12.0),
                    ..._availableCards.map((card) => _buildAvailableCard(card)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed('HomePage');
              break;
            case 1:
              break;
            case 2:
              context.goNamed('GoalSelector');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goal',
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic wallet) {
    final card = wallet['credit_cards'] ?? {};
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.credit_card,
              color: FlutterFlowTheme.of(context).primary,
              size: 24.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['name'] ?? 'Unknown Card',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                ),
                SizedBox(height: 4.0),
                Text(
                  '${card['domestic_pts_per_dollar'] ?? 0} pts/\$ domestic - ${card['intl_pts_per_dollar'] ?? 0} pts/\$ intl',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                      ),
                ),
                if (card['points_program'] != null)
                  Text(
                    card['points_program'],
                    style: FlutterFlowTheme.of(context).labelSmall.override(
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 11.0,
                        ),
                  ),
              ],
            ),
          ),
          if (wallet['is_primary'] == true)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).success,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                'Primary',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: FlutterFlowTheme.of(context).error,
              size: 24.0,
            ),
            onPressed: () => _removeCard(wallet['credit_card_id']),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCard(dynamic card) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).alternate.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.add_card,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['name'] ?? 'Unknown Card',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                ),
                SizedBox(height: 4.0),
                Text(
                  '${card['domestic_pts_per_dollar'] ?? 0} pts/\$ domestic - ${card['intl_pts_per_dollar'] ?? 0} pts/\$ intl',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                      ),
                ),
              ],
            ),
          ),
          FFButtonWidget(
            onPressed: () => _addCard(card['id']),
            text: 'Add',
            icon: Icon(Icons.add, size: 16.0),
            options: FFButtonOptions(
              height: 32.0,
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              iconPadding: EdgeInsets.zero,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }
}
