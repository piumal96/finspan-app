enum LifeEventType {
  job,
  education,
  rent,
  home,
  marriage,
  children,
  retirement,
  health,
  business,
  move,
  familySupport,
  jobChange,
  jobLoss,
  sideHustle,
  careerBreak,
}

class LifeEvent {
  final String id;
  final LifeEventType type;
  final String name;
  final int startAge;
  final int? endAge;
  final Map<String, dynamic> params;

  LifeEvent({
    required this.id,
    required this.type,
    required this.name,
    required this.startAge,
    this.endAge,
    this.params = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'startAge': startAge,
      'endAge': endAge,
      'params': params,
    };
  }

  factory LifeEvent.fromMap(Map<String, dynamic> map) {
    return LifeEvent(
      id: map['id'] ?? '',
      type: LifeEventType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => LifeEventType.job,
      ),
      name: map['name'] ?? '',
      startAge: (map['startAge'] ?? 0).toInt(),
      endAge: map['endAge']?.toInt(),
      params: Map<String, dynamic>.from(map['params'] ?? {}),
    );
  }
}

class RetirementSimulationParams {
  final int p1StartAge;
  final int p2StartAge;
  final int endSimulationAge;
  final double inflationRate;
  final double annualSpendGoal;
  final String filingStatus;

  // Employment Income
  final double p1EmploymentIncome;
  final int p1EmploymentUntilAge;
  final double p2EmploymentIncome;
  final int p2EmploymentUntilAge;

  // Social Security
  final double p1SsAmount;
  final int p1SsStartAge;
  final double p2SsAmount;
  final int p2SsStartAge;

  // Pensions
  final double p1Pension;
  final int p1PensionStartAge;
  final double p2Pension;
  final int p2PensionStartAge;

  // Account Balances
  final double balTaxable;
  final double balPretaxP1;
  final double balPretaxP2;
  final double balRothP1;
  final double balRothP2;

  // Growth Rates
  final double growthRateTaxable;
  final double growthRatePretaxP1;
  final double growthRatePretaxP2;
  final double growthRateRothP1;
  final double growthRateRothP2;

  // Tax Settings
  final double taxableBasisRatio;
  final double targetTaxBracketRate;
  final double? previousYearTaxes;

  // Real Estate & Mortgages
  final double? primaryHomeValue;
  final double? primaryHomeGrowthRate;
  final double? primaryHomeMortgagePrincipal;
  final double? primaryHomeMortgageRate;
  final int? primaryHomeMortgageYears;

  // Rental Properties
  final double rental1Value;
  final double rental1Income;
  final double rental1MortgagePrincipal;

  RetirementSimulationParams({
    required this.p1StartAge,
    required this.p2StartAge,
    required this.endSimulationAge,
    required this.inflationRate,
    required this.annualSpendGoal,
    this.filingStatus = 'MFJ',
    required this.p1EmploymentIncome,
    required this.p1EmploymentUntilAge,
    required this.p2EmploymentIncome,
    required this.p2EmploymentUntilAge,
    required this.p1SsAmount,
    required this.p1SsStartAge,
    required this.p2SsAmount,
    required this.p2SsStartAge,
    required this.p1Pension,
    required this.p1PensionStartAge,
    required this.p2Pension,
    required this.p2PensionStartAge,
    required this.balTaxable,
    required this.balPretaxP1,
    required this.balPretaxP2,
    required this.balRothP1,
    required this.balRothP2,
    required this.growthRateTaxable,
    required this.growthRatePretaxP1,
    required this.growthRatePretaxP2,
    required this.growthRateRothP1,
    required this.growthRateRothP2,
    required this.taxableBasisRatio,
    required this.targetTaxBracketRate,
    this.previousYearTaxes,
    this.primaryHomeValue,
    this.primaryHomeGrowthRate,
    this.primaryHomeMortgagePrincipal,
    this.primaryHomeMortgageRate,
    this.primaryHomeMortgageYears,
    this.rental1Value = 0,
    this.rental1Income = 0,
    this.rental1MortgagePrincipal = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'p1_start_age': p1StartAge,
      'p2_start_age': p2StartAge,
      'end_simulation_age': endSimulationAge,
      'inflation_rate': inflationRate,
      'annual_spend_goal': annualSpendGoal,
      'filing_status': filingStatus,
      'p1_employment_income': p1EmploymentIncome,
      'p1_employment_until_age': p1EmploymentUntilAge,
      'p2_employment_income': p2EmploymentIncome,
      'p2_employment_until_age': p2EmploymentUntilAge,
      'p1_ss_amount': p1SsAmount,
      'p1_ss_start_age': p1SsStartAge,
      'p2_ss_amount': p2SsAmount,
      'p2_ss_start_age': p2SsStartAge,
      'p1_pension': p1Pension,
      'p1_pension_start_age': p1PensionStartAge,
      'p2_pension': p2Pension,
      'p2_pension_start_age': p2PensionStartAge,
      'bal_taxable': balTaxable,
      'bal_pretax_p1': balPretaxP1,
      'bal_pretax_p2': balPretaxP2,
      'bal_roth_p1': balRothP1,
      'bal_roth_p2': balRothP2,
      'growth_rate_taxable': growthRateTaxable,
      'growth_rate_pretax_p1': growthRatePretaxP1,
      'growth_rate_pretax_p2': growthRatePretaxP2,
      'growth_rate_roth_p1': growthRateRothP1,
      'growth_rate_roth_p2': growthRateRothP2,
      'taxable_basis_ratio': taxableBasisRatio,
      'target_tax_bracket_rate': targetTaxBracketRate,
      if (previousYearTaxes != null) 'previous_year_taxes': previousYearTaxes,
      if (primaryHomeValue != null) 'primary_home_value': primaryHomeValue,
      if (primaryHomeGrowthRate != null)
        'primary_home_growth_rate': primaryHomeGrowthRate,
      if (primaryHomeMortgagePrincipal != null)
        'primary_home_mortgage_principal': primaryHomeMortgagePrincipal,
      if (primaryHomeMortgageRate != null)
        'primary_home_mortgage_rate': primaryHomeMortgageRate,
      if (primaryHomeMortgageYears != null)
        'primary_home_mortgage_years': primaryHomeMortgageYears,
      'rental_1_value': rental1Value,
      'rental_1_income': rental1Income,
      'rental_1_mortgage_principal': rental1MortgagePrincipal,
    };
  }
}

class WealthDataPoint {
  final int age;
  final int? p2Age;
  final double taxable;
  final double preTaxP1;
  final double preTaxP2;
  final double rothP1;
  final double rothP2;
  final double total;
  final double netWorth;
  final double income;
  final double expenses;
  final double taxBill;
  final String riskLevel;

  WealthDataPoint({
    required this.age,
    this.p2Age,
    required this.taxable,
    required this.preTaxP1,
    required this.preTaxP2,
    required this.rothP1,
    required this.rothP2,
    required this.total,
    required this.netWorth,
    required this.income,
    required this.expenses,
    required this.taxBill,
    required this.riskLevel,
  });

  factory WealthDataPoint.fromJson(Map<String, dynamic> json) {
    try {
      final nw = (json['Net_Worth'] ?? 0).toDouble();
      return WealthDataPoint(
        age: (json['P1_Age'] as num? ?? 0).toInt(),
        p2Age: json['P2_Age'] != null ? (json['P2_Age'] as num).toInt() : null,
        taxable: (json['Bal_Taxable'] ?? 0).toDouble(),
        preTaxP1: (json['Bal_PreTax_P1'] ?? 0).toDouble(),
        preTaxP2: (json['Bal_PreTax_P2'] ?? 0).toDouble(),
        rothP1: (json['Bal_Roth_P1'] ?? 0).toDouble(),
        rothP2: (json['Bal_Roth_P2'] ?? 0).toDouble(),
        total: nw,
        netWorth: nw,
        income: (json['Total_Income'] ?? 0).toDouble(),
        expenses: (json['Spend_Goal'] ?? 0).toDouble(),
        taxBill: (json['Tax_Bill'] ?? 0).toDouble(),
        riskLevel: nw <= 0 ? 'caution' : 'safe',
      );
    } catch (e) {
      print('Error parsing WealthDataPoint from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class SimulationResult {
  final List<WealthDataPoint> standardResults;
  final List<WealthDataPoint> taxableFirstResults;
  final double successProbability;
  final double endingWealth;
  final int? shortfallAge;
  final MonteCarloResult? monteCarlo;

  SimulationResult({
    required this.standardResults,
    required this.taxableFirstResults,
    required this.successProbability,
    required this.endingWealth,
    this.shortfallAge,
    this.monteCarlo,
  });
}

class MonteCarloStat {
  final int year;
  final double netWorthMedian;
  final double netWorthP10;
  final double netWorthP90;
  final double rothMedian;
  final double preTaxMedian;
  final double taxableMedian;

  MonteCarloStat({
    required this.year,
    required this.netWorthMedian,
    required this.netWorthP10,
    required this.netWorthP90,
    required this.rothMedian,
    required this.preTaxMedian,
    required this.taxableMedian,
  });

  factory MonteCarloStat.fromJson(Map<String, dynamic> json) {
    return MonteCarloStat(
      year: (json['Year'] ?? 0).toInt(),
      netWorthMedian: (json['Net_Worth_median'] ?? 0).toDouble(),
      netWorthP10: (json['Net_Worth_P10'] ?? 0).toDouble(),
      netWorthP90: (json['Net_Worth_P90'] ?? 0).toDouble(),
      rothMedian: (json['Bal_Roth_Total_median'] ?? 0).toDouble(),
      preTaxMedian: (json['Bal_PreTax_Total_median'] ?? 0).toDouble(),
      taxableMedian: (json['Bal_Taxable_median'] ?? 0).toDouble(),
    );
  }
}

class MonteCarloResult {
  final double successRate;
  final List<MonteCarloStat> stats;
  final int numSimulations;
  final double volatility;

  MonteCarloResult({
    required this.successRate,
    required this.stats,
    required this.numSimulations,
    required this.volatility,
  });

  factory MonteCarloResult.fromJson(Map<String, dynamic> json) {
    return MonteCarloResult(
      successRate: (json['success_rate'] ?? 0).toDouble(),
      stats: (json['stats'] as List? ?? [])
          .map((s) => MonteCarloStat.fromJson(s))
          .toList(),
      numSimulations: (json['num_simulations'] ?? 100).toInt(),
      volatility: (json['volatility'] ?? 0.15).toDouble(),
    );
  }
}
