import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/parent_dashboard_cubit.dart';
import 'parent_dashboard_screen.dart';
import 'parent_dependents_screen.dart';
import 'parent_distribution_screen.dart';
import 'parent_approvals_screen.dart';

class ParentMainNavigation extends StatefulWidget {
  final String parentId;

  const ParentMainNavigation({super.key, required this.parentId});

  @override
  State<ParentMainNavigation> createState() => _ParentMainNavigationState();
}

class _ParentMainNavigationState extends State<ParentMainNavigation> {
  late final ParentDashboardCubit _cubit;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = ParentDashboardCubit()..loadDashboard(widget.parentId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _setTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> get _pages => [
        ParentDashboardScreen(
          parentId: widget.parentId,
          onNavigateToTab: _setTab,
        ),
        const ParentDependentsScreen(),
        const ParentDistributionScreen(),
        const ParentApprovalsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Início',
                  color: const Color(AppConstants.primaryBlue),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.family_restroom_rounded,
                  label: 'Dependentes',
                  color: const Color(AppConstants.secondaryBlue),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.payments_rounded,
                  label: 'Distribuir',
                  color: const Color(AppConstants.accentOrange),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.verified_user_rounded,
                  label: 'Aprovar',
                  color: const Color(AppConstants.successGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _setTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? color
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

