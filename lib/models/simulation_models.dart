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
  // Added for web parity
  car,
  vacation,
  oneTimeExpense,
  insurance,
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

/// Full backend simulation payload — matches the web SimulationParams interface exactly.
class RetirementSimulationParams {
  // ── Core ──────────────────────────────────────────────────────────────────
  final int p1StartAge;
  final int p2StartAge;
  final int endSimulationAge;
  final double inflationRate;
  final double annualSpendGoal;
  final String filingStatus;

  // ── Employment ────────────────────────────────────────────────────────────
  final double p1EmploymentIncome;
  final int p1EmploymentUntilAge;
  final double p2EmploymentIncome;
  final int p2EmploymentUntilAge;

  // ── Social Security ───────────────────────────────────────────────────────
  final double p1SsAmount;
  final int p1SsStartAge;
  final double p2SsAmount;
  final int p2SsStartAge;

  // ── Pensions ──────────────────────────────────────────────────────────────
  final double p1Pension;
  final int p1PensionStartAge;
  final double p2Pension;
  final int p2PensionStartAge;

  // ── Account Balances ──────────────────────────────────────────────────────
  final double balTaxable;
  final double balPretaxP1;
  final double balPretaxP2;
  final double balRothP1;
  final double balRothP2;

  // ── Growth Rates ──────────────────────────────────────────────────────────
  final double growthRateTaxable;
  final double growthRatePretaxP1;
  final double growthRatePretaxP2;
  final double growthRateRothP1;
  final double growthRateRothP2;

  // ── Tax Settings ──────────────────────────────────────────────────────────
  final double taxableBasisRatio;
  final double targetTaxBracketRate;
  final double? previousYearTaxes;

  // ── 401k Contributions ────────────────────────────────────────────────────
  final double p1FourOnekContributionRate;
  final double p1FourOnekEmployerMatchRate;
  final bool p1FourOnekIsRoth;
  final double p2FourOnekContributionRate;
  final double p2FourOnekEmployerMatchRate;
  final bool p2FourOnekIsRoth;
  final bool autoOptimizeRothTraditional;

  // ── Debts ─────────────────────────────────────────────────────────────────
  final double studentLoanBalance;
  final double studentLoanRate;
  final double studentLoanPayment;
  final double carLoanBalance;
  final double carLoanPayment;
  final int carLoanYears;
  final double creditCardDebt;
  final double creditCardPayment;
  final double creditCardRate;

  // ── Healthcare ────────────────────────────────────────────────────────────
  final double annualMedicalExpenses;
  final double medicalInflationRate;

  // ── Business ──────────────────────────────────────────────────────────────
  final double businessIncome;
  final double businessGrowthRate;
  final int? businessEndsAtAge;

  // ── Children ──────────────────────────────────────────────────────────────
  final int numChildren;
  final int child1CurrentAge;
  final int child2CurrentAge;
  final int child3CurrentAge;
  final int child4CurrentAge;
  final double monthlyExpensePerChild0to5;
  final double monthlyExpensePerChild6to12;
  final double monthlyExpensePerChild13to17;
  final double collegeCostPerYear;

  // ── Other Income ──────────────────────────────────────────────────────────
  final double passiveIncome;
  final double passiveIncomeGrowthRate;

  // ── Life Insurance ────────────────────────────────────────────────────────
  final double lifeInsurancePremium;
  final String lifeInsuranceType;
  final int? lifeInsuranceTermEndsAtAge;

  // ── Housing ───────────────────────────────────────────────────────────────
  final double monthlyRent;
  final double rentInflationRate;

  // ── Real Estate & Mortgages ───────────────────────────────────────────────
  final double? primaryHomeValue;
  final double? primaryHomeGrowthRate;
  final double? primaryHomeMortgagePrincipal;
  final double? primaryHomeMortgageRate;
  final int? primaryHomeMortgageYears;

  // ── Rental Properties ─────────────────────────────────────────────────────
  final double rental1Value;
  final double rental1Income;
  final double rental1MortgagePrincipal;

  RetirementSimulationParams({
    required this.p1StartAge,
    required this.p2StartAge,
    required this.endSimulationAge,
    required this.inflationRate,
    required this.annualSpendGoal,
    this.filingStatus = 'Single',
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
    this.p1FourOnekContributionRate = 0.0,
    this.p1FourOnekEmployerMatchRate = 0.0,
    this.p1FourOnekIsRoth = false,
    this.p2FourOnekContributionRate = 0.0,
    this.p2FourOnekEmployerMatchRate = 0.0,
    this.p2FourOnekIsRoth = false,
    this.autoOptimizeRothTraditional = true,
    this.studentLoanBalance = 0.0,
    this.studentLoanRate = 0.0,
    this.studentLoanPayment = 0.0,
    this.carLoanBalance = 0.0,
    this.carLoanPayment = 0.0,
    this.carLoanYears = 0,
    this.creditCardDebt = 0.0,
    this.creditCardPayment = 0.0,
    this.creditCardRate = 0.0,
    this.annualMedicalExpenses = 0.0,
    this.medicalInflationRate = 0.05,
    this.businessIncome = 0.0,
    this.businessGrowthRate = 0.0,
    this.businessEndsAtAge,
    this.numChildren = 0,
    this.child1CurrentAge = 0,
    this.child2CurrentAge = 0,
    this.child3CurrentAge = 0,
    this.child4CurrentAge = 0,
    this.monthlyExpensePerChild0to5 = 0.0,
    this.monthlyExpensePerChild6to12 = 0.0,
    this.monthlyExpensePerChild13to17 = 0.0,
    this.collegeCostPerYear = 0.0,
    this.passiveIncome = 0.0,
    this.passiveIncomeGrowthRate = 0.02,
    this.lifeInsurancePremium = 0.0,
    this.lifeInsuranceType = 'none',
    this.lifeInsuranceTermEndsAtAge,
    this.monthlyRent = 0.0,
    this.rentInflationRate = 0.03,
    this.primaryHomeValue,
    this.primaryHomeGrowthRate,
    this.primaryHomeMortgagePrincipal,
    this.primaryHomeMortgageRate,
    this.primaryHomeMortgageYears,
    this.rental1Value = 0.0,
    this.rental1Income = 0.0,
    this.rental1MortgagePrincipal = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      // Core
      'p1_start_age': p1StartAge,
      'p2_start_age': p2StartAge,
      'end_simulation_age': endSimulationAge,
      'inflation_rate': inflationRate,
      'annual_spend_goal': annualSpendGoal,
      'filing_status': filingStatus,

      // Employment
      'p1_employment_income': p1EmploymentIncome,
      'p1_employment_until_age': p1EmploymentUntilAge,
      'p2_employment_income': p2EmploymentIncome,
      'p2_employment_until_age': p2EmploymentUntilAge,

      // Social Security
      'p1_ss_amount': p1SsAmount,
      'p1_ss_start_age': p1SsStartAge,
      'p2_ss_amount': p2SsAmount,
      'p2_ss_start_age': p2SsStartAge,

      // Pensions
      'p1_pension': p1Pension,
      'p1_pension_start_age': p1PensionStartAge,
      'p2_pension': p2Pension,
      'p2_pension_start_age': p2PensionStartAge,

      // Account Balances
      'bal_taxable': balTaxable,
      'bal_pretax_p1': balPretaxP1,
      'bal_pretax_p2': balPretaxP2,
      'bal_roth_p1': balRothP1,
      'bal_roth_p2': balRothP2,

      // Growth Rates
      'growth_rate_taxable': growthRateTaxable,
      'growth_rate_pretax_p1': growthRatePretaxP1,
      'growth_rate_pretax_p2': growthRatePretaxP2,
      'growth_rate_roth_p1': growthRateRothP1,
      'growth_rate_roth_p2': growthRateRothP2,

      // Tax
      'taxable_basis_ratio': taxableBasisRatio,
      'target_tax_bracket_rate': targetTaxBracketRate,
      if (previousYearTaxes != null) 'previous_year_taxes': previousYearTaxes,

      // 401k contributions
      'p1_401k_contribution_rate': p1FourOnekContributionRate,
      'p1_401k_employer_match_rate': p1FourOnekEmployerMatchRate,
      'p1_401k_is_roth': p1FourOnekIsRoth,
      'p2_401k_contribution_rate': p2FourOnekContributionRate,
      'p2_401k_employer_match_rate': p2FourOnekEmployerMatchRate,
      'p2_401k_is_roth': p2FourOnekIsRoth,
      'auto_optimize_roth_traditional': autoOptimizeRothTraditional,

      // Debts
      'student_loan_balance': studentLoanBalance,
      'student_loan_rate': studentLoanRate,
      'student_loan_payment': studentLoanPayment,
      'car_loan_balance': carLoanBalance,
      'car_loan_payment': carLoanPayment,
      'car_loan_years': carLoanYears,
      'credit_card_debt': creditCardDebt,
      'credit_card_payment': creditCardPayment,
      'credit_card_rate': creditCardRate,

      // Healthcare
      'annual_medical_expenses': annualMedicalExpenses,
      'medical_inflation_rate': medicalInflationRate,

      // Business
      'business_income': businessIncome,
      'business_growth_rate': businessGrowthRate,
      'business_ends_at_age': businessEndsAtAge ?? 0,

      // Children
      'num_children': numChildren,
      'child_1_current_age': child1CurrentAge,
      'child_2_current_age': child2CurrentAge,
      'child_3_current_age': child3CurrentAge,
      'child_4_current_age': child4CurrentAge,
      'monthly_expense_per_child_0_5': monthlyExpensePerChild0to5,
      'monthly_expense_per_child_6_12': monthlyExpensePerChild6to12,
      'monthly_expense_per_child_13_17': monthlyExpensePerChild13to17,
      'college_cost_per_year': collegeCostPerYear,

      // Other Income
      'passive_income': passiveIncome,
      'passive_income_growth_rate': passiveIncomeGrowthRate,

      // Life Insurance
      'life_insurance_premium': lifeInsurancePremium,
      'life_insurance_type': lifeInsuranceType,
      'life_insurance_term_ends_at_age': lifeInsuranceTermEndsAtAge ?? 0,

      // Housing
      'monthly_rent': monthlyRent,
      'rent_inflation_rate': rentInflationRate,

      // Primary Home (conditional)
      if (primaryHomeValue != null) 'primary_home_value': primaryHomeValue,
      if (primaryHomeGrowthRate != null)
        'primary_home_growth_rate': primaryHomeGrowthRate,
      if (primaryHomeMortgagePrincipal != null)
        'primary_home_mortgage_principal': primaryHomeMortgagePrincipal,
      if (primaryHomeMortgageRate != null)
        'primary_home_mortgage_rate': primaryHomeMortgageRate,
      if (primaryHomeMortgageYears != null)
        'primary_home_mortgage_years': primaryHomeMortgageYears,

      // Rental
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
