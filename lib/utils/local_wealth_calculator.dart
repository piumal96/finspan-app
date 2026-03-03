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
  static List<LocalWealthPoint> calculate(
    List<LifeEvent> events,
    int currentAge,
    int lifeExpectancy, {
    List<double>? customReturns, // Optional array of realistic yearly returns
  }) {
    final List<LocalWealthPoint> data = [];
    double taxable = 10000;
    double taxDeferred = 0;
    double roth = 0;

    for (int age = currentAge; age <= lifeExpectancy; age++) {
      double income = 0;
      double expenses = 12000; // base living
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
              expenses +=
                  (40000 *
                      _cost(
                        event.params['costLevel'] as String? ?? 'moderate',
                      )) /
                  4;
            }

          case LifeEventType.job:
            if (started && !isRetired) {
              final base = _income(
                event.params['incomeLevel'] as String? ?? 'moderate',
              );
              final years = age - event.startAge;
              income += base * pow(1.025, years);
              isWorking = true;
            }

          case LifeEventType.jobChange:
            if (started && !isRetired) {
              final dir = event.params['direction'] as String? ?? 'same';
              final mult = dir == 'up'
                  ? 1.2
                  : dir == 'down'
                  ? 0.8
                  : 1.0;
              income =
                  _income(
                    event.params['incomeLevel'] as String? ?? 'moderate',
                  ) *
                  mult;
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
              income +=
                  _income(event.params['incomeLevel'] as String? ?? 'low') *
                  0.3;
            }

          case LifeEventType.rent:
            if (active) {
              expenses +=
                  18000 *
                  _cost(event.params['costLevel'] as String? ?? 'moderate');
            }

          case LifeEventType.marriage:
            if (started) {
              hasPartner = true;
              final partnerLevel =
                  event.params['partnerIncomeLevel'] as String? ?? 'moderate';
              if (partnerLevel != 'none') {
                income += _income(partnerLevel) * (isRetired ? 0 : 0.8);
              }
              expenses *= 0.85;
            }

          case LifeEventType.home:
            if (age == event.startAge) {
              final mult = _cost(
                event.params['costLevel'] as String? ?? 'expensive',
              );
              final price = 400000 * mult;
              final dp = (event.params['hasGoodSavings'] as bool? ?? false)
                  ? price * 0.2
                  : price * 0.1;
              taxable -= dp;
            }
            if (started) {
              expenses +=
                  400000 *
                  _cost(event.params['costLevel'] as String? ?? 'expensive') *
                  0.06;
            }

          case LifeEventType.children:
            if (active) {
              final count = (event.params['count'] as num?)?.toInt() ?? 1;
              expenses +=
                  15000.0 *
                  count *
                  _cost(event.params['costLevel'] as String? ?? 'moderate');
            }

          case LifeEventType.careerBreak:
            if (active) {
              income = 0;
              isWorking = false;
            }

          case LifeEventType.retirement:
            if (started) {
              isRetired = true;
              isWorking = false;
              final lifestyle =
                  event.params['lifestyleLevel'] as String? ?? 'moderate';
              final costs = lifestyle == 'frugal'
                  ? 36000.0
                  : lifestyle == 'generous'
                  ? 96000.0
                  : 60000.0;
              expenses = costs + (hasPartner ? costs * 0.6 : 0);
            }

          case LifeEventType.health:
            if (age == event.startAge) {
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

          case LifeEventType.business:
            if (age == event.startAge) {
              taxable -= 50000;
            }
            if (started && age >= event.startAge + 3 && !isRetired) {
              income += 75000;
              isWorking = true;
            }

          case LifeEventType.move:
            if (started) {
              final change = event.params['costChange'] as String? ?? 'same';
              expenses *= _cost(change);
            }

          case LifeEventType.familySupport:
            if (active) {
              expenses += 15000;
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
    int lifeExpectancy,
  ) {
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
