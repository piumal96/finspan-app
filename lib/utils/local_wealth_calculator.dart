// Local wealth calculation — mirroring web's useLifePlanning.calculateWealth()
// No API calls. Computes instantly from life events for real-time simulator UX.
import 'dart:math' as math;
import '../models/simulation_models.dart';

class LocalWealthPoint {
  final int age;
  final double taxable;
  final double taxDeferred;
  final double roth;
  final double total;
  final double monthlyCashFlow;
  final String riskLevel; // 'safe' | 'caution' | 'aware'

  const LocalWealthPoint({
    required this.age,
    required this.taxable,
    required this.taxDeferred,
    required this.roth,
    required this.total,
    required this.monthlyCashFlow,
    required this.riskLevel,
  });
}

class LocalInsights {
  final double netWorth;
  final double monthlyCashFlow;
  final int stressLevel; // 0-100
  final String riskLevel;
  final int retirementAge;

  const LocalInsights({
    required this.netWorth,
    required this.monthlyCashFlow,
    required this.stressLevel,
    required this.riskLevel,
    required this.retirementAge,
  });
}

class LocalWealthCalculator {
  // Base income values (USD/year, mirrored from web)
  static const Map<String, double> _incomeValues = {
    'low': 35000,
    'moderate': 55000,
    'good': 85000,
    'high': 130000,
  };

  static const Map<String, double> _costMultipliers = {
    'cheaper': 0.7,
    'same': 1.0,
    'expensive': 1.3,
    'very-expensive': 1.7,
  };

  static double _income(String level) =>
      _incomeValues[level] ?? _incomeValues['moderate']!;

  static double _cost(String level) =>
      _costMultipliers[level] ?? _costMultipliers['same']!;

  /// Port of useLifePlanning.calculateWealth() — runs in microseconds.
  /// Pass [initialTaxable], [initialTaxDeferred], [initialRoth] to seed real
  /// account balances from the user's OnboardingData instead of zeroes.
  static List<LocalWealthPoint> calculate(
    List<LifeEvent> events,
    int currentAge,
    int lifeExpectancy, {
    List<double>? customReturns,
    double initialTaxable = 0.0,
    double initialTaxDeferred = 0.0,
    double initialRoth = 0.0,
    // Actual yearly non-housing non-retirement baseline expenses from the user's
    // plan (My Plan → currentExpenses).  Defaults to $36K if not set (web default).
    double baseYearlyExpenses = 36000.0,
  }) {
    final List<LocalWealthPoint> data = [];
    double taxable = initialTaxable;
    double taxDeferred = initialTaxDeferred;
    double roth = initialRoth;

    for (int age = currentAge; age <= lifeExpectancy; age++) {
      double income = 0;
      double expenses = baseYearlyExpenses; // seeded from user plan
      bool isWorking = false;
      bool isRetired = false;
      bool hasPartner = false;

      for (final event in events) {
        final bool active =
            age >= event.startAge &&
            (event.endAge == null || age <= event.endAge!);
        final bool started = age >= event.startAge;

        switch (event.type) {
          case LifeEventType.education:
            if (active) {
              // Prefer editor-set numeric tuition over qualitative fallback
              final tuition = (event.params['tuition'] as num?)?.toDouble();
              final dur = (event.params['durationYears'] as num?)?.toDouble() ?? 4.0;
              if (tuition != null) {
                expenses += tuition / dur;
              } else {
                expenses +=
                    (40000 *
                        _cost(event.params['costLevel'] as String? ?? 'moderate')) /
                    4;
              }
            }

          case LifeEventType.job:
            if (started && !isRetired) {
              // Prefer editor-set numeric salary over qualitative incomeLevel
              final salary = (event.params['salary'] as num?)?.toDouble();
              final base = salary ??
                  _income(event.params['incomeLevel'] as String? ?? 'moderate');
              final raisePct =
                  (event.params['annualRaise'] as num?)?.toDouble() ?? 2.5;
              final years = age - event.startAge;
              income += base * pow(1.0 + raisePct / 100, years);
              isWorking = true;
            }

          case LifeEventType.jobChange:
            if (started && !isRetired) {
              // Prefer editor-set newSalary over qualitative direction/level
              final newSalary = (event.params['newSalary'] as num?)?.toDouble();
              if (newSalary != null) {
                income = newSalary;
              } else {
                final dir = event.params['direction'] as String? ?? 'same';
                final mult = dir == 'up' ? 1.2 : dir == 'down' ? 0.8 : 1.0;
                income =
                    _income(event.params['incomeLevel'] as String? ?? 'moderate') *
                    mult;
              }
              isWorking = true;
            }

          case LifeEventType.jobLoss:
            if (active) {
              income = 0;
              isWorking = false;
              if (!(event.params['hasEmergencyFund'] as bool? ?? true)) {
                expenses += 5000;
              }
            }

          case LifeEventType.sideHustle:
            if (active && !isRetired) {
              // Prefer editor-set monthlyIncome over qualitative level
              final monthly = (event.params['monthlyIncome'] as num?)?.toDouble();
              if (monthly != null) {
                income += monthly * 12;
              } else {
                income +=
                    _income(event.params['incomeLevel'] as String? ?? 'low') * 0.3;
              }
            }

          case LifeEventType.rent:
            if (active) {
              // Prefer editor-set monthlyRent over qualitative costLevel
              final monthly = (event.params['monthlyRent'] as num?)?.toDouble();
              if (monthly != null) {
                expenses += monthly * 12;
              } else {
                expenses +=
                    18000 * _cost(event.params['costLevel'] as String? ?? 'moderate');
              }
            }

          case LifeEventType.marriage:
            if (started) {
              hasPartner = true;
              // Prefer editor-set partnerIncome over qualitative level
              final partnerIncome =
                  (event.params['partnerIncome'] as num?)?.toDouble();
              if (partnerIncome != null) {
                income += partnerIncome * (isRetired ? 0 : 0.8);
              } else {
                final partnerLevel =
                    event.params['partnerIncomeLevel'] as String? ?? 'moderate';
                if (partnerLevel != 'none') {
                  income += _income(partnerLevel) * (isRetired ? 0 : 0.8);
                }
              }
              expenses *= 0.85; // shared household discount
            }
            // One-time wedding cost on the start year (added after multiplier)
            if (age == event.startAge) {
              final weddingCost =
                  (event.params['weddingCost'] as num?)?.toDouble() ?? 0;
              expenses += weddingCost;
            }

          case LifeEventType.home:
            if (age == event.startAge) {
              final homePrice = (event.params['homePrice'] as num?)?.toDouble();
              if (homePrice != null) {
                final downPct =
                    (event.params['downPaymentPercent'] as num?)?.toDouble() ?? 20;
                taxable -= homePrice * (downPct / 100);
              } else {
                final mult =
                    _cost(event.params['costLevel'] as String? ?? 'expensive');
                final price = 400000 * mult;
                final dp = (event.params['hasGoodSavings'] as bool? ?? false)
                    ? price * 0.2
                    : price * 0.1;
                taxable -= dp;
              }
            }
            if (started) {
              final homePrice = (event.params['homePrice'] as num?)?.toDouble();
              if (homePrice != null) {
                expenses += homePrice * 0.06; // ~6% annual carrying cost
              } else {
                expenses +=
                    400000 *
                    _cost(event.params['costLevel'] as String? ?? 'expensive') *
                    0.06;
              }
            }

          case LifeEventType.children:
            if (active) {
              // Prefer editor-set numKids + annualCostPerKid over qualitative
              final numKids = (event.params['numKids'] as num?)?.toInt();
              final annualCost =
                  (event.params['annualCostPerKid'] as num?)?.toDouble();
              if (numKids != null && annualCost != null) {
                expenses += annualCost * numKids;
              } else {
                final count = (event.params['count'] as num?)?.toInt() ?? 1;
                expenses +=
                    15000.0 *
                    count *
                    _cost(event.params['costLevel'] as String? ?? 'moderate');
              }
            }

          case LifeEventType.careerBreak:
            if (active) {
              income = 0;
              isWorking = false;
              if (!(event.params['hasSavings'] as bool? ?? true)) {
                expenses += 3000;
              }
            }

          case LifeEventType.retirement:
            if (started) {
              isRetired = true;
              isWorking = false;
              // Prefer editor-set monthlySpending over qualitative lifestyleLevel
              final monthly =
                  (event.params['monthlySpending'] as num?)?.toDouble();
              if (monthly != null) {
                expenses = monthly * 12 + (hasPartner ? monthly * 12 * 0.6 : 0);
              } else {
                final lifestyle =
                    event.params['lifestyleLevel'] as String? ?? 'moderate';
                final costs = lifestyle == 'frugal'
                    ? 36000.0
                    : lifestyle == 'generous'
                    ? 96000.0
                    : 60000.0;
                expenses = costs + (hasPartner ? costs * 0.6 : 0);
              }
            }

          case LifeEventType.health:
            if (age == event.startAge) {
              // Prefer editor-set medicalCost over qualitative severity
              final medicalCost =
                  (event.params['medicalCost'] as num?)?.toDouble();
              if (medicalCost != null) {
                expenses += medicalCost;
              } else {
                final severity =
                    event.params['severity'] as String? ?? 'moderate';
                final base = severity == 'minor'
                    ? 5000.0
                    : severity == 'major'
                    ? 80000.0
                    : 25000.0;
                final cov = event.params['hasInsurance'] as bool? ?? false;
                expenses += base * (cov ? 0.3 : 1.0);
              }
            }

          case LifeEventType.business:
            if (age == event.startAge) {
              final startupCost =
                  (event.params['startupCost'] as num?)?.toDouble() ?? 50000;
              taxable -= startupCost;
            }
            if (started && age >= event.startAge + 3 && !isRetired) {
              final revenue =
                  (event.params['expectedRevenue'] as num?)?.toDouble() ?? 75000;
              income += revenue;
              isWorking = true;
            }

          case LifeEventType.move:
            // One-time moving cost set by the editor
            if (age == event.startAge) {
              final movingCost =
                  (event.params['movingCost'] as num?)?.toDouble() ?? 0;
              expenses += movingCost;
            }
            // Ongoing cost-of-living change (qualitative, kept for backward compat)
            if (started) {
              final change = event.params['costChange'] as String? ?? 'same';
              expenses *= _cost(change);
            }

          case LifeEventType.familySupport:
            if (active) {
              // Prefer editor-set monthlyAmount over qualitative amount level
              final monthly =
                  (event.params['monthlyAmount'] as num?)?.toDouble();
              if (monthly != null) {
                expenses += monthly * 12;
              } else {
                final amount = event.params['amount'] as String? ?? 'moderate';
                final cost = amount == 'small'
                    ? 6000.0
                    : amount == 'significant'
                    ? 30000.0
                    : 15000.0;
                expenses += cost;
              }
            }

          case LifeEventType.car:
            if (age == event.startAge) {
              final price =
                  (event.params['carPrice'] as num?)?.toDouble() ?? 30000;
              taxable -= price;
            }
            if (active) {
              expenses += 1200; // ~$100/month maintenance
            }

          case LifeEventType.vacation:
            if (age == event.startAge) {
              final cost =
                  (event.params['tripCost'] as num?)?.toDouble() ?? 5000;
              expenses += cost;
            }

          case LifeEventType.oneTimeExpense:
            if (age == event.startAge) {
              final amount =
                  (event.params['amount'] as num?)?.toDouble() ?? 15000;
              expenses += amount;
            }

          case LifeEventType.insurance:
            if (active) {
              final monthly =
                  (event.params['monthlyPremium'] as num?)?.toDouble() ?? 100;
              expenses += monthly * 12;
            }
        }
      }

      final netIncome = income - expenses;
      final cashFlow = netIncome / 12;

      if (isWorking && netIncome > 0) {
        final savings = netIncome * 0.25;
        taxDeferred += savings * 0.4;
        roth += savings * 0.2;
        taxable += savings * 0.4 + (netIncome - savings);
      } else if (netIncome > 0) {
        taxable += netIncome * 0.5;
      } else {
        final deficit = netIncome.abs();
        final total = taxable + taxDeferred + roth;
        if (total > 0) {
          final ratio = (deficit / total).clamp(0.0, 1.0);
          taxable = (taxable * (1 - ratio)).clamp(0, double.infinity);
          taxDeferred = (taxDeferred * (1 - ratio)).clamp(0, double.infinity);
          roth = (roth * (1 - ratio)).clamp(0, double.infinity);
        }
      }

      // Apply Growth
      // If customReturns are provided (e.g., from Monte Carlo), use the return for this year.
      // Otherwise default to standard 5.5% (0.055)
      final rate =
          customReturns != null && customReturns.length > (age - currentAge)
          ? customReturns[age - currentAge]
          : 0.055;

      taxable *= (1.0 + rate);
      taxDeferred *= (1.0 + rate);
      roth *= (1.0 + rate);

      final total = taxable + taxDeferred + roth;
      final String risk = cashFlow < -500
          ? 'aware'
          : cashFlow < 500
          ? 'caution'
          : 'safe';

      data.add(
        LocalWealthPoint(
          age: age,
          taxable: taxable.clamp(0, double.infinity),
          taxDeferred: taxDeferred.clamp(0, double.infinity),
          roth: roth.clamp(0, double.infinity),
          total: total.clamp(0, double.infinity),
          monthlyCashFlow: cashFlow,
          riskLevel: risk,
        ),
      );
    }

    return data;
  }

  /// Computes insights at a given age from a pre-calculated dataset.
  static LocalInsights insights(
    List<LocalWealthPoint> data,
    int currentAge,
    List<LifeEvent> events,
  ) {
    final point = data.isEmpty
        ? null
        : data.firstWhere((d) => d.age == currentAge, orElse: () => data.first);

    final netWorth = point?.total ?? 0;
    final cashFlow = point?.monthlyCashFlow ?? 0;
    final riskLevel = point?.riskLevel ?? 'safe';

    final maxWealth = data.isEmpty
        ? 1.0
        : data.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final wealthRatio = maxWealth > 0 ? netWorth / maxWealth : 0.5;

    int stress = 30;
    if (cashFlow < 0) {
      stress += 40;
    } else if (cashFlow < 1000) {
      stress += 20;
    }
    stress += ((1 - wealthRatio) * 20).round();
    stress = stress.clamp(0, 100);

    final retirementEvent = events
        .where((e) => e.type == LifeEventType.retirement)
        .toList();
    final retirementAge = retirementEvent.isEmpty
        ? 65
        : retirementEvent.first.startAge;

    return LocalInsights(
      netWorth: netWorth,
      monthlyCashFlow: cashFlow,
      stressLevel: stress,
      riskLevel: riskLevel,
      retirementAge: retirementAge,
    );
  }

  // Simple power helper
  static double pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  /// Runs 100 Monte Carlo simulations locally using Box-Muller normal distribution.
  /// Returns the configured baseline + the P10, P50, and P90 trajectories for instantly responsive UI.
  static LocalMonteCarloResult calculateMonteCarlo(
    List<LifeEvent> events,
    int currentAge,
    int lifeExpectancy, {
    double initialTaxable = 0.0,
    double initialTaxDeferred = 0.0,
    double initialRoth = 0.0,
    double baseYearlyExpenses = 36000.0,
  }) {
    final int yearsToSimulate = lifeExpectancy - currentAge + 1;
    final int numSimulations = 100;
    const double meanReturn = 0.07; // 7% average
    const double volatility = 0.15; // 15% volatile (matches web params)

    final math.Random random = math.Random();

    // Box-Muller transform for standard normal distribution
    double generateNormal() {
      double u1 = random.nextDouble();
      double u2 = random.nextDouble();
      // Ensure u1 is not exactly 0 to avoid log(0)
      if (u1 < 1e-10) u1 = 1e-10;
      return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    }

    final List<List<LocalWealthPoint>> allRuns = [];

    // Run 100 simulations
    for (int i = 0; i < numSimulations; i++) {
      // 1. Generate realistic market returns for this timeline
      final List<double> marketReturns = [];
      for (int y = 0; y < yearsToSimulate; y++) {
        final double z = generateNormal();
        final double simulatedReturn = meanReturn + (volatility * z);
        marketReturns.add(simulatedReturn);
      }

      // 2. Run the FAST deterministic local calculator with these specific returns
      final runData = calculate(
        events,
        currentAge,
        lifeExpectancy,
        customReturns: marketReturns,
        initialTaxable: initialTaxable,
        initialTaxDeferred: initialTaxDeferred,
        initialRoth: initialRoth,
        baseYearlyExpenses: baseYearlyExpenses,
      );

      allRuns.add(runData);
    }

    // Now extract the percentiles
    // Sort runs based on their final net worth at lifeExpectancy
    allRuns.sort((a, b) => a.last.total.compareTo(b.last.total));

    final int p10Index = (numSimulations * 0.10).floor();
    final int p50Index = (numSimulations * 0.50).floor();
    final int p90Index = (numSimulations * 0.90).floor();

    return LocalMonteCarloResult(
      p10: allRuns[p10Index],
      median: allRuns[p50Index],
      p90: allRuns[p90Index],
      allRuns: allRuns,
    );
  }
}

class LocalMonteCarloResult {
  final List<LocalWealthPoint> p10;
  final List<LocalWealthPoint> median;
  final List<LocalWealthPoint> p90;
  final List<List<LocalWealthPoint>> allRuns;

  LocalMonteCarloResult({
    required this.p10,
    required this.median,
    required this.p90,
    required this.allRuns,
  });
}
