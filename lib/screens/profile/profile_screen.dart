import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import '../landing_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Callback invoked when the user saves updated data and wants to re-simulate.
typedef OnDataSaved = void Function(OnboardingData updated);

class ProfileScreen extends StatefulWidget {
  final OnboardingData? data;
  final OnDataSaved? onDataSaved;

  const ProfileScreen({super.key, this.data, this.onDataSaved});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late OnboardingData _data;
  bool _hasChanges = false;

  final _fmt = NumberFormat('#,##0', 'en_US');

  @override
  void initState() {
    super.initState();
    // Deep-copy so edits don't mutate the parent directly until saved
    _data = _cloneData(widget.data ?? OnboardingData());
  }

  OnboardingData _cloneData(OnboardingData src) {
    final d = OnboardingData()
      ..includePartner = src.includePartner
      ..currentAge = src.currentAge
      ..birthDate = src.birthDate
      ..retirementAge = src.retirementAge
      ..lifeExpectancy = src.lifeExpectancy
      ..taxFilingStatus = src.taxFilingStatus
      ..currentSalary = src.currentSalary
      ..currentExpenses = src.currentExpenses
      ..generalInflation = src.generalInflation
      ..taxDeferredSavings = src.taxDeferredSavings
      ..taxableSavings = src.taxableSavings
      ..taxFreeSavings = src.taxFreeSavings
      ..spouseAge = src.spouseAge
      ..spouseRetirementAge = src.spouseRetirementAge
      ..spouseSalary = src.spouseSalary
      ..spouseTaxDeferredSavings = src.spouseTaxDeferredSavings
      ..spouseTaxableSavings = src.spouseTaxableSavings
      ..spouseTaxFreeSavings = src.spouseTaxFreeSavings
      ..expectedReturn = src.expectedReturn
      ..socialSecurityBenefit = src.socialSecurityBenefit
      ..socialSecurityAge = src.socialSecurityAge
      ..spouseSocialSecurityBenefit = src.spouseSocialSecurityBenefit
      ..spouseSocialSecurityAge = src.spouseSocialSecurityAge
      ..pensionIncome = src.pensionIncome
      ..housingStatus = src.housingStatus
      ..monthlyRent = src.monthlyRent
      ..monthlyMortgage = src.monthlyMortgage
      ..rentalIncome = src.rentalIncome
      ..studentLoanBalance = src.studentLoanBalance
      ..studentLoanMonthly = src.studentLoanMonthly
      ..carLoanBalance = src.carLoanBalance
      ..carLoanMonthly = src.carLoanMonthly
      ..creditCardBalance = src.creditCardBalance
      ..creditCardMonthly = src.creditCardMonthly
      ..medicalExpenses = src.medicalExpenses
      ..businessIncome = src.businessIncome
      ..numChildren = src.numChildren
      ..childMonthlySpending = src.childMonthlySpending
      ..collegeGoal = src.collegeGoal
      ..legacyGoal = src.legacyGoal
      ..insuranceType = src.insuranceType
      ..insuranceCoverage = src.insuranceCoverage
      ..lifeEvents = List.from(src.lifeEvents);
    return d;
  }

  void _save() {
    widget.onDataSaved?.call(_data);
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Plan updated — re-simulating…'),
        backgroundColor: FinSpanTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ────────────────────────────── BUILD ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      floatingActionButton: _hasChanges
          ? FloatingActionButton.extended(
              onPressed: _save,
              backgroundColor: FinSpanTheme.primaryGreen,
              icon: const Icon(Icons.sync_rounded, color: Colors.white),
              label: const Text(
                'Save & Re-Simulate',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Text(
                'My Plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and edit all financial parameters. Changes will re-run your simulation.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: FinSpanTheme.bodyGray),
              ),
              const SizedBox(height: 20),

              // ── User Card ───────────────────────────────────────────
              FinSpanCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: FinSpanTheme.primaryGreen.withValues(
                        alpha: 0.1,
                      ),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              LucideIcons.user,
                              size: 32,
                              color: FinSpanTheme.primaryGreen,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Financial Planner',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: FinSpanTheme.charcoal,
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: FinSpanTheme.bodyGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Section 1: Identity & Timeline ─────────────────────
              _AccordionSection(
                icon: Icons.person_outline_rounded,
                title: 'Identity & Timeline',
                color: const Color(0xFF4CAF50),
                initiallyExpanded: true,
                children: [
                  _buildIntRow(
                    label: 'Current Age',
                    value: _data.currentAge,
                    min: 18,
                    max: 80,
                    onChanged: (v) => setState(() {
                      _data.currentAge = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildIntRow(
                    label: 'Retirement Age',
                    value: _data.retirementAge,
                    min: _data.currentAge + 1,
                    max: 85,
                    onChanged: (v) => setState(() {
                      _data.retirementAge = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildIntRow(
                    label: 'Plan Until Age',
                    value: _data.lifeExpectancy,
                    min: _data.retirementAge + 1,
                    max: 110,
                    onChanged: (v) => setState(() {
                      _data.lifeExpectancy = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildDropdownRow(
                    label: 'Filing Status',
                    value: _data.taxFilingStatus,
                    options: const {
                      'single': 'Single',
                      'married_joint': 'Married (Joint)',
                    },
                    onChanged: (v) => setState(() {
                      _data.taxFilingStatus = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.taxFilingStatus == 'married_joint') ...[
                    _buildIntRow(
                      label: 'Spouse Age',
                      value: _data.spouseAge ?? _data.currentAge,
                      min: 18,
                      max: 80,
                      onChanged: (v) => setState(() {
                        _data.spouseAge = v;
                        _hasChanges = true;
                      }),
                    ),
                    _buildIntRow(
                      label: 'Spouse Retirement Age',
                      value: _data.spouseRetirementAge ?? _data.retirementAge,
                      min: (_data.spouseAge ?? _data.currentAge) + 1,
                      max: 85,
                      onChanged: (v) => setState(() {
                        _data.spouseRetirementAge = v;
                        _hasChanges = true;
                      }),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 2: Income & Expenses ────────────────────────
              _AccordionSection(
                icon: Icons.work_outline_rounded,
                title: 'Income & Expenses',
                color: const Color(0xFF2196F3),
                children: [
                  _buildCurrencyRow(
                    label: 'Annual Salary',
                    value: _data.currentSalary,
                    onChanged: (v) => setState(() {
                      _data.currentSalary = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Annual Spending Goal',
                    value: _data.currentExpenses,
                    onChanged: (v) => setState(() {
                      _data.currentExpenses = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildPercentRow(
                    label: 'Inflation Rate',
                    value: _data.generalInflation,
                    onChanged: (v) => setState(() {
                      _data.generalInflation = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildPercentRow(
                    label: 'Expected Return',
                    value: _data.expectedReturn,
                    onChanged: (v) => setState(() {
                      _data.expectedReturn = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.taxFilingStatus == 'married_joint')
                    _buildCurrencyRow(
                      label: 'Spouse Annual Salary',
                      value: _data.spouseSalary,
                      onChanged: (v) => setState(() {
                        _data.spouseSalary = v;
                        _hasChanges = true;
                      }),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 3: Savings & Accounts ──────────────────────
              _AccordionSection(
                icon: Icons.savings_outlined,
                title: 'Savings & Accounts',
                color: const Color(0xFF9C27B0),
                children: [
                  _buildSubtitle('Your Accounts'),
                  _buildCurrencyRow(
                    label: 'Tax-Deferred (401k / Pre-Tax)',
                    value: _data.taxDeferredSavings,
                    onChanged: (v) => setState(() {
                      _data.taxDeferredSavings = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Tax-Free (Roth / TFSA)',
                    value: _data.taxFreeSavings,
                    onChanged: (v) => setState(() {
                      _data.taxFreeSavings = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Taxable / Brokerage',
                    value: _data.taxableSavings,
                    onChanged: (v) => setState(() {
                      _data.taxableSavings = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.taxFilingStatus == 'married_joint') ...[
                    _buildSubtitle('Spouse Accounts'),
                    _buildCurrencyRow(
                      label: 'Spouse Tax-Deferred',
                      value: _data.spouseTaxDeferredSavings,
                      onChanged: (v) => setState(() {
                        _data.spouseTaxDeferredSavings = v;
                        _hasChanges = true;
                      }),
                    ),
                    _buildCurrencyRow(
                      label: 'Spouse Tax-Free',
                      value: _data.spouseTaxFreeSavings,
                      onChanged: (v) => setState(() {
                        _data.spouseTaxFreeSavings = v;
                        _hasChanges = true;
                      }),
                    ),
                    _buildCurrencyRow(
                      label: 'Spouse Taxable',
                      value: _data.spouseTaxableSavings,
                      onChanged: (v) => setState(() {
                        _data.spouseTaxableSavings = v;
                        _hasChanges = true;
                      }),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 4: Social Security & Pension ───────────────
              _AccordionSection(
                icon: Icons.account_balance_outlined,
                title: 'Social Security & Pension',
                color: const Color(0xFFFF9800),
                children: [
                  _buildCurrencyRow(
                    label: 'Monthly SS Benefit',
                    value: _data.socialSecurityBenefit,
                    onChanged: (v) => setState(() {
                      _data.socialSecurityBenefit = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildIntRow(
                    label: 'SS Start Age',
                    value: _data.socialSecurityAge,
                    min: 62,
                    max: 75,
                    onChanged: (v) => setState(() {
                      _data.socialSecurityAge = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Annual Pension',
                    value: _data.pensionIncome,
                    onChanged: (v) => setState(() {
                      _data.pensionIncome = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.taxFilingStatus == 'married_joint') ...[
                    _buildCurrencyRow(
                      label: 'Spouse Monthly SS',
                      value: _data.spouseSocialSecurityBenefit,
                      onChanged: (v) => setState(() {
                        _data.spouseSocialSecurityBenefit = v;
                        _hasChanges = true;
                      }),
                    ),
                    _buildIntRow(
                      label: 'Spouse SS Start Age',
                      value: _data.spouseSocialSecurityAge,
                      min: 62,
                      max: 75,
                      onChanged: (v) => setState(() {
                        _data.spouseSocialSecurityAge = v;
                        _hasChanges = true;
                      }),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 5: Housing, Debts & Expenses ───────────────
              _AccordionSection(
                icon: LucideIcons.home,
                title: 'Housing, Debts & Expenses',
                color: const Color(0xFFF44336),
                children: [
                  _buildSubtitle('Housing'),
                  _buildDropdownRow(
                    label: 'Housing Status',
                    value: _data.housingStatus,
                    options: const {'Rent': 'Renting', 'Own': 'Own Home'},
                    onChanged: (v) => setState(() {
                      _data.housingStatus = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.housingStatus == 'Rent')
                    _buildCurrencyRow(
                      label: 'Monthly Rent',
                      value: _data.monthlyRent,
                      onChanged: (v) => setState(() {
                        _data.monthlyRent = v;
                        _hasChanges = true;
                      }),
                    )
                  else
                    _buildCurrencyRow(
                      label: 'Monthly Mortgage',
                      value: _data.monthlyMortgage,
                      onChanged: (v) => setState(() {
                        _data.monthlyMortgage = v;
                        _hasChanges = true;
                      }),
                    ),
                  _buildCurrencyRow(
                    label: 'Rental Income (Annual)',
                    value: _data.rentalIncome,
                    onChanged: (v) => setState(() {
                      _data.rentalIncome = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildSubtitle('Debts & Loans'),
                  _buildCurrencyRow(
                    label: 'Student Loan Balance',
                    value: _data.studentLoanBalance,
                    onChanged: (v) => setState(() {
                      _data.studentLoanBalance = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Student Loan Monthly',
                    value: _data.studentLoanMonthly,
                    onChanged: (v) => setState(() {
                      _data.studentLoanMonthly = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Car Loan Balance',
                    value: _data.carLoanBalance,
                    onChanged: (v) => setState(() {
                      _data.carLoanBalance = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Credit Card Balance',
                    value: _data.creditCardBalance,
                    onChanged: (v) => setState(() {
                      _data.creditCardBalance = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildSubtitle('Other Expenses'),
                  _buildCurrencyRow(
                    label: 'Annual Medical Expenses',
                    value: _data.medicalExpenses,
                    onChanged: (v) => setState(() {
                      _data.medicalExpenses = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Business Income (Annual)',
                    value: _data.businessIncome,
                    onChanged: (v) => setState(() {
                      _data.businessIncome = v;
                      _hasChanges = true;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 6: Children & Education ───────────────────
              _AccordionSection(
                icon: Icons.family_restroom_rounded,
                title: 'Children & Education',
                color: const Color(0xFF00BCD4),
                children: [
                  _buildIntRow(
                    label: 'Number of Children',
                    value: _data.numChildren,
                    min: 0,
                    max: 10,
                    onChanged: (v) => setState(() {
                      _data.numChildren = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'Monthly Spend Per Child',
                    value: _data.childMonthlySpending,
                    onChanged: (v) => setState(() {
                      _data.childMonthlySpending = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildCurrencyRow(
                    label: 'College Savings Goal (each)',
                    value: _data.collegeGoal,
                    onChanged: (v) => setState(() {
                      _data.collegeGoal = v;
                      _hasChanges = true;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Section 7: Legacy & Insurance ─────────────────────
              _AccordionSection(
                icon: Icons.shield_outlined,
                title: 'Legacy & Insurance',
                color: const Color(0xFF607D8B),
                children: [
                  _buildCurrencyRow(
                    label: 'Legacy / Estate Goal',
                    value: _data.legacyGoal,
                    onChanged: (v) => setState(() {
                      _data.legacyGoal = v;
                      _hasChanges = true;
                    }),
                  ),
                  _buildDropdownRow(
                    label: 'Insurance Type',
                    value: _data.insuranceType,
                    options: const {
                      'none': 'None',
                      'term': 'Term Life',
                      'whole': 'Whole Life',
                    },
                    onChanged: (v) => setState(() {
                      _data.insuranceType = v;
                      _hasChanges = true;
                    }),
                  ),
                  if (_data.insuranceType != 'none')
                    _buildCurrencyRow(
                      label: 'Insurance Coverage',
                      value: _data.insuranceCoverage,
                      onChanged: (v) => setState(() {
                        _data.insuranceCoverage = v;
                        _hasChanges = true;
                      }),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Account Settings ───────────────────────────────────
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FinSpanTheme.bodyGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildAccountAction(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildAccountAction(
                      context,
                      icon: Icons.security_rounded,
                      title: 'Data & Privacy',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildAccountAction(
                      context,
                      icon: LucideIcons.logOut,
                      title: 'Log Out',
                      color: Colors.redAccent,
                      onTap: () async {
                        // ── Confirmation dialog ──────────────────────────
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text(
                              'Are you sure you want to log out? You will need to sign back in.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LandingScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    _buildAccountAction(
                      context,
                      icon: LucideIcons.trash,
                      title: 'Delete Account',
                      color: Colors.red.shade800,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────── ROW BUILDERS ──────────────────────────────

  Widget _buildSubtitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: FinSpanTheme.bodyGray,
        ),
      ),
    );
  }

  Widget _buildIntRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final ctrl = TextEditingController(text: value.toString());
    return _FieldRow(
      label: label,
      child: _CompactIntField(
        controller: ctrl,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCurrencyRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final ctrl = TextEditingController(
      text: value == 0 ? '0' : _fmt.format(value),
    );
    return _FieldRow(
      label: label,
      child: _CompactCurrencyField(controller: ctrl, onChanged: onChanged),
    );
  }

  Widget _buildPercentRow({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final ctrl = TextEditingController(text: value.toStringAsFixed(1));
    return _FieldRow(
      label: label,
      child: _CompactPercentField(controller: ctrl, onChanged: onChanged),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return _FieldRow(
      label: label,
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: FinSpanTheme.charcoal,
        ),
        items: options.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildAccountAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? FinSpanTheme.charcoal, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color ?? FinSpanTheme.charcoal,
        ),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: Colors.grey.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    String typed = '';
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ This action is permanent. All your data will be deleted and cannot be recovered.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Type DELETE to confirm:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                autofocus: true,
                onChanged: (v) => setDlgState(() => typed = v),
                decoration: const InputDecoration(
                  hintText: 'DELETE',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: typed == 'DELETE'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: Text(
                'Delete Forever',
                style: TextStyle(
                  color: typed == 'DELETE' ? Colors.red.shade800 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        await user?.delete();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LandingScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.code == 'requires-recent-login'
                    ? 'Please sign out and sign back in before deleting your account.'
                    : 'Failed to delete account. Please try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// ─────────────────────────────── SUBWIDGETS ───────────────────────────────

class _AccordionSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _AccordionSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.topLeft,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: FinSpanTheme.charcoal,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: FinSpanTheme.bodyGray,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: child),
        ],
      ),
    );
  }
}

class _CompactIntField extends StatelessWidget {
  final TextEditingController controller;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _CompactIntField({
    required this.controller,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: FinSpanTheme.charcoal,
      ),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.primaryGreen, width: 1.5),
        ),
      ),
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) {
          onChanged(parsed.clamp(min, max));
        }
      },
    );
  }
}

class _CompactCurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;

  const _CompactCurrencyField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: FinSpanTheme.charcoal,
      ),
      decoration: const InputDecoration(
        isDense: true,
        prefixText: '\$ ',
        prefixStyle: TextStyle(fontSize: 11, color: FinSpanTheme.bodyGray),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.primaryGreen, width: 1.5),
        ),
      ),
      onChanged: (v) {
        final cleaned = v.replaceAll(',', '');
        final parsed = double.tryParse(cleaned);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

class _CompactPercentField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<double> onChanged;

  const _CompactPercentField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: FinSpanTheme.charcoal,
      ),
      decoration: const InputDecoration(
        isDense: true,
        suffixText: '%',
        suffixStyle: TextStyle(fontSize: 13, color: FinSpanTheme.bodyGray),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: FinSpanTheme.primaryGreen, width: 1.5),
        ),
      ),
      onChanged: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}
