// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoalSelectorModel extends FlutterFlowModel {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

class GoalSelectorWidget extends StatefulWidget {
  const GoalSelectorWidget({super.key});

  static String routeName = 'GoalSelector';
  static String routePath = '/goalSelector';

  @override
  State<GoalSelectorWidget> createState() => _GoalSelectorWidgetState();
}

class _GoalSelectorWidgetState extends State<GoalSelectorWidget> {
  late GoalSelectorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedGoal = 'CASH';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GoalSelectorModel());
    _loadCurrentGoal();
  }

  Future<void> _loadCurrentGoal() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_profiles')
            .select('goal_preference')
            .eq('id', user.id)
            .single();
        if (response != null && response['goal_preference'] != null) {
          setState(() {
            _selectedGoal = response['goal_preference'];
          });
        }
      } catch (e) {
        // Profile might not exist yet
      }
    }
  }

  Future<void> _saveGoal(String goal) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': user.id,
        'email': user.email,
        'goal_preference': goal,
      });
      setState(() {
        _selectedGoal = goal;
      });
    }
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
        automaticallyImplyLeading: true,
        title: Text(
          'Choose Your Goal',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.interTight(
                  fontWeight: FontWeight.bold,
                ),
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: false,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'How do you want to optimize your purchases?',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 16.0,
                    ),
              ),
              SizedBox(height: 32.0),
              _buildGoalCard(
                context,
                goal: 'CASH',
                icon: Icons.attach_money,
                title: 'Maximum Cash Return',
                description:
                    'Optimize for liquid savings via cashback + high-pts cards',
                bestFor: 'Best for: General purchases',
                color: FlutterFlowTheme.of(context).success,
              ),
              SizedBox(height: 16.0),
              _buildGoalCard(
                context,
                goal: 'FAMILY',
                icon: Icons.flight,
                title: 'Maximum Travel Volume',
                description: 'Maximize seats for family trips via Azul/Smiles',
                bestFor: 'Best for: Flights',
                color: FlutterFlowTheme.of(context).info,
              ),
              SizedBox(height: 16.0),
              _buildGoalCard(
                context,
                goal: 'LUXURY',
                icon: Icons.hotel,
                title: 'Maximum Point Value',
                description:
                    'Highest value per point via Accor/Iberia transfers',
                bestFor: 'Best for: Hotels & Premium',
                color: FlutterFlowTheme.of(context).tertiary,
              ),
              SizedBox(height: 32.0),
              FFButtonWidget(
                onPressed: () {
                  context.pop();
                },
                text: 'Confirm Selection',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 48.0,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.interTight(),
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String goal,
    required IconData icon,
    required String title,
    required String description,
    required String bestFor,
    required Color color,
  }) {
    final isSelected = _selectedGoal == goal;

    return GestureDetector(
      onTap: () => _saveGoal(goal),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? color : FlutterFlowTheme.of(context).alternate,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: Offset(0.0, 4.0),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 28.0,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
                            fontSize: 16.0,
                          ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      description,
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 13.0,
                          ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      bestFor,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.0,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 28.0,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
