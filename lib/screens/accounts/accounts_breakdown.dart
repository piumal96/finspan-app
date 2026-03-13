import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AccountsBreakdownScreen extends StatelessWidget {
  final OnboardingData? data;
  const AccountsBreakdownScreen({super.key, this.data});

  String _fmt(double v) {
    if (v >= 1000000) return '\$${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '\$${(v / 1000).toStringAsFixed(0)}K';
    return '\$${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final d = data ?? OnboardingData();

    // ── Key numbers ───────────────────────────────────────────────────────
    final double retirement = d.taxDeferredSavings +
        d.taxFreeSavings +
        (d.includePartner
            ? d.spouseTaxDeferredSavings + d.spouseTaxFreeSavings
            : 0);
    final double investments = d.taxableSavings +
        (d.includePartner ? d.spouseTaxableSavings : 0);
    final double homeEquity = d.housingStatus == 'Own'
        ? (d.homeValue - d.mortgageBalance).clamp(0, double.infinity)
        : 0;
    final double totalAssets = retirement + investments + homeEquity;

    final double totalDebt = d.mortgageBalance +
        d.studentLoanBalance +
        d.carLoanBalance +
        d.creditCardBalance;
    final double netWorth = totalAssets - totalDebt;

    // ── Health metrics ────────────────────────────────────────────────────
    final double savingsRate = d.currentSalary > 0
        ? ((d.userFourOneKContribComputed + d.userEmployerMatchDollar) /
                d.currentSalary *
                100)
            .clamp(0, 100)
        : 0;
    final double dtiRatio = d.currentSalary > 0
        ? (totalDebt / d.currentSalary * 100).clamp(0, 999)
        : 0;
    final double annualContrib = d.userFourOneKContribComputed +
        d.userEmployerMatchDollar +
        (d.includePartner
            ? d.spouseFourOneKContribComputed + d.spouseEmployerMatchDollar
            : 0);

    // ── Health rating helpers ─────────────────────────────────────────────
    _Rating savingsRating = savingsRate >= 15
        ? _Rating.good
        : savingsRate >= 10
            ? _Rating.fair
            : _Rating.low;
    _Rating dtiRating = dtiRatio < 36
        ? _Rating.good
        : dtiRatio < 50
            ? _Rating.fair
            : _Rating.low;

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              const Text('Accounts',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: FinSpanTheme.charcoal,
                      letterSpacing: -0.5)),
              const SizedBox(height: 2),
              const Text('Your financial snapshot',
                  style: TextStyle(
                      fontSize: 13, color: FinSpanTheme.bodyGray)),
              const SizedBox(height: 20),

              // ── Net Worth ────────────────────────────────────────────────
              FinSpanCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Net Worth',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: FinSpanTheme.bodyGray,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                _fmt(netWorth),
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: netWorth >= 0
                                      ? FinSpanTheme.charcoal
                                      : Colors.red.shade600,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Simple donut summary
                        _MiniDonut(
                          assets: totalAssets,
                          debt: totalDebt,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _NetWorthPill(
                            label: 'Assets',
                            value: _fmt(totalAssets),
                            color: FinSpanTheme.primaryGreen),
                        const SizedBox(width: 10),
                        _NetWorthPill(
                            label: 'Debt',
                            value: _fmt(totalDebt),
                            color: Colors.red.shade400),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Health Score row ──────────────────────────────────────────
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _HealthTile(
                      label: 'Savings Rate',
                      value: '${savingsRate.toStringAsFixed(0)}%',
                      benchmark: '≥ 15% recommended',
                      rating: savingsRating,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HealthTile(
                      label: 'Debt-to-Income',
                      value: '${dtiRatio.toStringAsFixed(0)}%',
                      benchmark: '< 36% healthy',
                      rating: dtiRating,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HealthTile(
                      label: 'Exp. Return',
                      value: '${d.expectedReturn.toStringAsFixed(1)}%',
                      benchmark: 'Annual growth rate',
                      rating: _Rating.neutral,
                    ),
                  ),
                ],
              ),

              // ── Assets ───────────────────────────────────────────────────
              const SizedBox(height: 20),
              const _SectionLabel('Assets'),
              const SizedBox(height: 10),
              FinSpanCard(
                padding: EdgeInsets.zero,
                child: Column(children: [
                  _AssetRow(
                    label: 'Retirement Accounts',
                    sublabel: '401(k) · Roth IRA',
                    value: _fmt(retirement),
                    color: const Color(0xFF6366F1),
                    icon: LucideIcons.landmark,
                    growthLabel: retirement > 0
                        ? '+${_fmt(retirement * d.expectedReturn / 100)}/yr'
                        : null,
                  ),
                  if (investments > 0) ...[
                    const _Div(),
                    _AssetRow(
                      label: 'Investments',
                      sublabel: 'Brokerage / taxable',
                      value: _fmt(investments),
                      color: const Color(0xFFF59E0B),
                      icon: LucideIcons.lineChart,
                      growthLabel:
                          '+${_fmt(investments * d.expectedReturn / 100)}/yr',
                    ),
                  ],
                  if (homeEquity > 0) ...[
                    const _Div(),
                    _AssetRow(
                      label: 'Home Equity',
                      sublabel:
                          '${_fmt(d.homeValue)} value',
                      value: _fmt(homeEquity),
                      color: const Color(0xFF3B82F6),
                      icon: LucideIcons.home,
                    ),
                  ],
                ]),
              ),

              // ── Debt ─────────────────────────────────────────────────────
              if (totalDebt > 0) ...[
                const SizedBox(height: 20),
                const _SectionLabel('Debt'),
                const SizedBox(height: 10),
                FinSpanCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    if (d.mortgageBalance > 0)
                      _DebtRow(
                        label: 'Mortgage',
                        value: _fmt(d.mortgageBalance),
                        rate: d.mortgageRate,
                        monthlyPayment: d.monthlyMortgage,
                        icon: LucideIcons.home,
                      ),
                    if (d.studentLoanBalance > 0) ...[
                      if (d.mortgageBalance > 0) const _Div(),
                      _DebtRow(
                        label: 'Student Loan',
                        value: _fmt(d.studentLoanBalance),
                        rate: d.studentLoanRate,
                        monthlyPayment: d.studentLoanMonthly,
                        icon: LucideIcons.graduationCap,
                      ),
                    ],
                    if (d.carLoanBalance > 0) ...[
                      if (d.mortgageBalance > 0 ||
                          d.studentLoanBalance > 0)
                        const _Div(),
                      _DebtRow(
                        label: 'Auto Loan',
                        value: _fmt(d.carLoanBalance),
                        rate: 0,
                        monthlyPayment: d.carLoanMonthly,
                        icon: LucideIcons.car,
                      ),
                    ],
                    if (d.creditCardBalance > 0) ...[
                      if (totalDebt > d.creditCardBalance) const _Div(),
                      _DebtRow(
                        label: 'Credit Cards',
                        value: _fmt(d.creditCardBalance),
                        rate: d.creditCardRate,
                        monthlyPayment: d.creditCardMonthly,
                        icon: LucideIcons.creditCard,
                        isHighInterest: d.creditCardRate > 15,
                      ),
                    ],
                  ]),
                ),
              ],

              // ── Annual Cash Flow ──────────────────────────────────────────
              const SizedBox(height: 20),
              const _SectionLabel('Annual Cash Flow'),
              const SizedBox(height: 10),
              FinSpanCard(
                child: Column(children: [
                  _FlowRow(
                      label: 'Gross Income',
                      value: _fmt(d.currentSalary +
                          (d.includePartner ? d.spouseSalary : 0)),
                      positive: true),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 8),
                  _FlowRow(
                      label: 'Contributions',
                      value: _fmt(annualContrib),
                      positive: true,
                      sublabel: '401(k) + employer match'),
                  const SizedBox(height: 8),
                  _FlowRow(
                      label: 'Living Expenses',
                      value: _fmt(d.currentExpenses),
                      positive: false),
                  if (d.housingStatus == 'Rent' && d.monthlyRent > 0) ...[
                    const SizedBox(height: 4),
                    _FlowRow(
                        label: 'Rent',
                        value: _fmt(d.monthlyRent * 12),
                        positive: false,
                        sublabel: 'included in expenses'),
                  ],
                ]),
              ),

              // ── Retirement Income ─────────────────────────────────────────
              if (d.socialSecurityBenefit > 0 ||
                  d.pensionIncome > 0 ||
                  d.otherPassiveIncome > 0) ...[
                const SizedBox(height: 20),
                const _SectionLabel('Retirement Income Sources'),
                const SizedBox(height: 10),
                FinSpanCard(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    if (d.socialSecurityBenefit > 0)
                      _IncomeSourceRow(
                        label: 'Social Security',
                        monthly: d.socialSecurityBenefit,
                        detail: 'Age ${d.socialSecurityAge}',
                        icon: LucideIcons.shield,
                        color: const Color(0xFF10B981),
                      ),
                    if (d.pensionIncome > 0) ...[
                      if (d.socialSecurityBenefit > 0) const _Div(),
                      _IncomeSourceRow(
                        label: 'Pension',
                        monthly: d.pensionIncome,
                        detail: 'Guaranteed',
                        icon: LucideIcons.building,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                    if (d.otherPassiveIncome > 0) ...[
                      if (d.socialSecurityBenefit > 0 ||
                          d.pensionIncome > 0)
                        const _Div(),
                      _IncomeSourceRow(
                        label: 'Passive Income',
                        monthly: d.otherPassiveIncome,
                        detail: 'Rental / other',
                        icon: LucideIcons.coins,
                        color: const Color(0xFF06B6D4),
                      ),
                    ],
                  ]),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

enum _Rating { good, fair, low, neutral }

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: FinSpanTheme.charcoal,
          letterSpacing: 0.1));
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 64, color: Color(0xFFF3F4F6));
}

// Simple two-arc "donut" drawn with CustomPaint
class _MiniDonut extends StatelessWidget {
  final double assets;
  final double debt;
  const _MiniDonut({required this.assets, required this.debt});

  @override
  Widget build(BuildContext context) {
    final total = assets + debt;
    final frac = total > 0 ? (assets / total).clamp(0.05, 0.95) : 1.0;
    return CustomPaint(
      size: const Size(56, 56),
      painter: _DonutPainter(frac: frac),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double frac;
  const _DonutPainter({required this.frac});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 5;
    const sw = 8.0;
    const start = -1.5708; // -π/2 (top)
    const full = 6.2832; // 2π

    final bgPaint = Paint()
      ..color = Colors.red.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    final fgPaint = Paint()
      ..color = FinSpanTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        full,
        false,
        bgPaint);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start,
        full * frac,
        false,
        fgPaint);
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.frac != frac;
}

class _NetWorthPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _NetWorthPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label  ',
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _HealthTile extends StatelessWidget {
  final String label;
  final String value;
  final String benchmark;
  final _Rating rating;
  const _HealthTile(
      {required this.label,
      required this.value,
      required this.benchmark,
      required this.rating});

  Color get _color {
    switch (rating) {
      case _Rating.good:
        return FinSpanTheme.primaryGreen;
      case _Rating.fair:
        return const Color(0xFFF59E0B);
      case _Rating.low:
        return Colors.red.shade400;
      case _Rating.neutral:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FinSpanTheme.cardRadius),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _color,
                  letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: FinSpanTheme.charcoal)),
          const SizedBox(height: 2),
          Text(benchmark,
              style: const TextStyle(
                  fontSize: 9.5, color: FinSpanTheme.bodyGray),
              maxLines: 2),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color color;
  final IconData icon;
  final String? growthLabel;
  const _AssetRow(
      {required this.label,
      required this.sublabel,
      required this.value,
      required this.color,
      required this.icon,
      this.growthLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FinSpanTheme.charcoal)),
              Text(sublabel,
                  style: const TextStyle(
                      fontSize: 11, color: FinSpanTheme.bodyGray)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: FinSpanTheme.charcoal,
                    letterSpacing: -0.3)),
            if (growthLabel != null)
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.trendingUp,
                    size: 9, color: FinSpanTheme.primaryGreen),
                const SizedBox(width: 3),
                Text(growthLabel!,
                    style: TextStyle(
                        fontSize: 10,
                        color: FinSpanTheme.primaryGreen,
                        fontWeight: FontWeight.w600)),
              ]),
          ],
        ),
      ]),
    );
  }
}

class _DebtRow extends StatelessWidget {
  final String label;
  final String value;
  final double rate;
  final double monthlyPayment;
  final IconData icon;
  final bool isHighInterest;
  const _DebtRow(
      {required this.label,
      required this.value,
      required this.rate,
      required this.monthlyPayment,
      required this.icon,
      this.isHighInterest = false});

  @override
  Widget build(BuildContext context) {
    final String sub = [
      if (rate > 0) '${rate.toStringAsFixed(1)}% APR',
      if (monthlyPayment > 0)
        '\$${monthlyPayment.toStringAsFixed(0)}/mo',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: Colors.red.shade400, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: FinSpanTheme.charcoal)),
                if (isHighInterest) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text('High APR',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              if (sub.isNotEmpty)
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11, color: FinSpanTheme.bodyGray)),
            ],
          ),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.red.shade500,
                letterSpacing: -0.3)),
      ]),
    );
  }
}

class _FlowRow extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;
  final String? sublabel;
  const _FlowRow(
      {required this.label,
      required this.value,
      required this.positive,
      this.sublabel});

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? FinSpanTheme.primaryGreen : FinSpanTheme.charcoal;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: FinSpanTheme.charcoal)),
              if (sublabel != null)
                Text(sublabel!,
                    style: const TextStyle(
                        fontSize: 11, color: FinSpanTheme.bodyGray)),
            ],
          ),
        ),
        Row(children: [
          Text(positive ? '+' : '−',
              style: TextStyle(
                  fontSize: 13, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(width: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: -0.3)),
        ]),
      ],
    );
  }
}

class _IncomeSourceRow extends StatelessWidget {
  final String label;
  final double monthly;
  final String detail;
  final IconData icon;
  final Color color;
  const _IncomeSourceRow(
      {required this.label,
      required this.monthly,
      required this.detail,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: FinSpanTheme.charcoal)),
              Text(detail,
                  style: const TextStyle(
                      fontSize: 11, color: FinSpanTheme.bodyGray)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${monthly.toStringAsFixed(0)}/mo',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: FinSpanTheme.charcoal,
                    letterSpacing: -0.3)),
            Text('\$${(monthly * 12 / 1000).toStringAsFixed(0)}K/yr',
                style: const TextStyle(
                    fontSize: 10, color: FinSpanTheme.bodyGray)),
          ],
        ),
      ]),
    );
  }
}
