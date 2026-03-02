import '../../models/simulation_models.dart';

class OnboardingData {
  bool includePartner = false;
  int currentAge = 35;
  int retirementAge = 65;
  int lifeExpectancy = 90;
  String taxFilingStatus = 'single';
  String stateOfResidence = 'California';

  // Spouse fields
  int? spouseAge;
  int? spouseRetirementAge;
  double spouseSalary = 0;

  // Income & Expenses
  double currentSalary = 100000;
  double currentExpenses = 75000;
  double generalInflation = 2.5;
  String taxTargetBracket = '22%';

  // Savings
  double taxDeferredSavings = 200000;
  double taxableSavings = 0;
  double taxFreeSavings = 0;

  double spouseTaxDeferredSavings = 0;
  double spouseTaxableSavings = 0;
  double spouseTaxFreeSavings = 0;

  // Simple mode for savings
  bool showDetailedBalances = false;

  // Return
  double expectedReturn = 7.0;

  // Debts
  double studentLoanBalance = 0;
  double studentLoanMonthly = 0;
  double studentLoanRate = 0;
  double carLoanBalance = 0;
  double carLoanMonthly = 0;
  double carLoanYears = 0;
  double creditCardBalance = 0;
  double creditCardMonthly = 0;

  // Housing
  String housingStatus = 'Rent'; // 'Rent' or 'Own'
  double monthlyRent = 2000;
  double monthlyMortgage = 0;
  double rentalIncome = 0;

  // Factors
  double medicalExpenses = 0;
  double medicalInflation = 5.0;
  double businessIncome = 0;
  double businessGrowth = 0;

  int numChildren = 0;
  double childMonthlySpending = 0;
  double collegeGoal = 0;

  // Social Security
  int socialSecurityAge = 67;
  double socialSecurityBenefit = 2500;
  int spouseSocialSecurityAge = 67;
  double spouseSocialSecurityBenefit = 0;

  // Contributions
  double userFourOneKContrib = 20000;
  double userRothIRAContrib = 6000;
  double spouseFourOneKContrib = 0;
  double spouseRothIRAContrib = 0;

  // Other income
  double pensionIncome = 0;
  double otherPassiveIncome = 0;

  // Insurance
  String insuranceType = 'none'; // 'none', 'term', 'whole'
  double insuranceCoverage = 0;

  // Legacy
  double legacyGoal = 0;

  // New fields for simulation
  double get totalSavings =>
      taxDeferredSavings +
      taxableSavings +
      taxFreeSavings +
      (includePartner
          ? (spouseTaxDeferredSavings +
                spouseTaxableSavings +
                spouseTaxFreeSavings)
          : 0);

  double get annualSalary => currentSalary;
  double get annualSpendingGoal => currentExpenses;

  // Events
  List<LifeEvent> lifeEvents = [];

  OnboardingData copyWith({
    bool? includePartner,
    int? currentAge,
    int? retirementAge,
    int? lifeExpectancy,
    String? taxFilingStatus,
    String? stateOfResidence,
    double? currentSalary,
    double? currentExpenses,
    double? generalInflation,
    double? expectedReturn,
    List<LifeEvent>? lifeEvents,
  }) {
    final newData = OnboardingData()
      ..includePartner = includePartner ?? this.includePartner
      ..currentAge = currentAge ?? this.currentAge
      ..retirementAge = retirementAge ?? this.retirementAge
      ..lifeExpectancy = lifeExpectancy ?? this.lifeExpectancy
      ..taxFilingStatus = taxFilingStatus ?? this.taxFilingStatus
      ..stateOfResidence = stateOfResidence ?? this.stateOfResidence
      ..currentSalary = currentSalary ?? this.currentSalary
      ..currentExpenses = currentExpenses ?? this.currentExpenses
      ..generalInflation = generalInflation ?? this.generalInflation
      ..expectedReturn = expectedReturn ?? this.expectedReturn
      ..lifeEvents = lifeEvents ?? List.from(this.lifeEvents);
    return newData;
  }
}
