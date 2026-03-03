import '../../models/simulation_models.dart';

class OnboardingData {
  OnboardingData();

  bool includePartner = false;
  DateTime? birthDate;
  int currentAge = 35;
  int retirementAge = 65;
  int lifeExpectancy = 90;
  String taxFilingStatus = 'single';
  String stateOfResidence = 'California';

  // Helper to calculate age from birthDate
  void updateAgeFromBirthDate() {
    if (birthDate != null) {
      final now = DateTime.now();
      int age = now.year - birthDate!.year;
      if (now.month < birthDate!.month ||
          (now.month == birthDate!.month && now.day < birthDate!.day)) {
        age--;
      }
      currentAge = age;
    }
  }

  // Spouse fields
  int? spouseAge;
  DateTime? spouseBirthDate;
  int? spouseRetirementAge;
  double spouseSalary = 0;

  void updateSpouseAgeFromBirthDate() {
    if (spouseBirthDate != null) {
      final now = DateTime.now();
      int age = now.year - spouseBirthDate!.year;
      if (now.month < spouseBirthDate!.month ||
          (now.month == spouseBirthDate!.month &&
              now.day < spouseBirthDate!.day)) {
        age--;
      }
      spouseAge = age;
    }
  }

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

  // 401(k) contribution and employer match rates (as % of salary, 0–100)
  double userContribRate = 15.0; // % of salary
  double userEmployerMatchRate = 5.0; // % employer matches
  double spouseContribRate = 15.0;
  double spouseEmployerMatchRate = 5.0;

  // Tax Optimization
  bool smartTaxOptimization = true;
  String userContribType = 'Traditional'; // 'Traditional' or 'Roth'
  String spouseContribType = 'Traditional';

  // Computed per-rate using salary; kept in sync when user edits sliders
  double get userFourOneKContribComputed =>
      currentSalary * (userContribRate / 100);
  double get userEmployerMatchDollar =>
      currentSalary * (userEmployerMatchRate / 100);
  double get spouseFourOneKContribComputed =>
      spouseSalary * (spouseContribRate / 100);
  double get spouseEmployerMatchDollar =>
      spouseSalary * (spouseEmployerMatchRate / 100);
  double get totalHouseholdContribPerYear =>
      userFourOneKContribComputed +
      userEmployerMatchDollar +
      (includePartner
          ? spouseFourOneKContribComputed + spouseEmployerMatchDollar
          : 0);

  // Spouse simple total savings
  double get spouseTotalSavings =>
      spouseTaxDeferredSavings + spouseTaxableSavings + spouseTaxFreeSavings;

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
    DateTime? birthDate,
    DateTime? spouseBirthDate,
    double? currentSalary,
    double? currentExpenses,
    double? generalInflation,
    double? expectedReturn,
    List<LifeEvent>? lifeEvents,
  }) {
    final newData = OnboardingData()
      ..includePartner = includePartner ?? this.includePartner
      ..currentAge = currentAge ?? this.currentAge
      ..birthDate = birthDate ?? this.birthDate
      ..retirementAge = retirementAge ?? this.retirementAge
      ..lifeExpectancy = lifeExpectancy ?? this.lifeExpectancy
      ..taxFilingStatus = taxFilingStatus ?? this.taxFilingStatus
      ..stateOfResidence = stateOfResidence ?? this.stateOfResidence
      ..spouseBirthDate = spouseBirthDate ?? this.spouseBirthDate
      ..currentSalary = currentSalary ?? this.currentSalary
      ..currentExpenses = currentExpenses ?? this.currentExpenses
      ..generalInflation = generalInflation ?? this.generalInflation
      ..expectedReturn = expectedReturn ?? this.expectedReturn
      ..lifeEvents = lifeEvents ?? List.from(this.lifeEvents);
    return newData;
  }

  Map<String, dynamic> toMap() {
    return {
      'includePartner': includePartner,
      'currentAge': currentAge,
      'birthDate': birthDate?.toIso8601String(),
      'retirementAge': retirementAge,
      'lifeExpectancy': lifeExpectancy,
      'taxFilingStatus': taxFilingStatus,
      'stateOfResidence': stateOfResidence,
      'spouseAge': spouseAge,
      'spouseBirthDate': spouseBirthDate?.toIso8601String(),
      'spouseRetirementAge': spouseRetirementAge,
      'spouseSalary': spouseSalary,
      'currentSalary': currentSalary,
      'currentExpenses': currentExpenses,
      'generalInflation': generalInflation,
      'taxTargetBracket': taxTargetBracket,
      'taxDeferredSavings': taxDeferredSavings,
      'taxableSavings': taxableSavings,
      'taxFreeSavings': taxFreeSavings,
      'spouseTaxDeferredSavings': spouseTaxDeferredSavings,
      'spouseTaxableSavings': spouseTaxableSavings,
      'spouseTaxFreeSavings': spouseTaxFreeSavings,
      'showDetailedBalances': showDetailedBalances,
      'expectedReturn': expectedReturn,
      'studentLoanBalance': studentLoanBalance,
      'studentLoanMonthly': studentLoanMonthly,
      'studentLoanRate': studentLoanRate,
      'carLoanBalance': carLoanBalance,
      'carLoanMonthly': carLoanMonthly,
      'carLoanYears': carLoanYears,
      'creditCardBalance': creditCardBalance,
      'creditCardMonthly': creditCardMonthly,
      'housingStatus': housingStatus,
      'monthlyRent': monthlyRent,
      'monthlyMortgage': monthlyMortgage,
      'rentalIncome': rentalIncome,
      'medicalExpenses': medicalExpenses,
      'medicalInflation': medicalInflation,
      'businessIncome': businessIncome,
      'businessGrowth': businessGrowth,
      'numChildren': numChildren,
      'childMonthlySpending': childMonthlySpending,
      'collegeGoal': collegeGoal,
      'socialSecurityAge': socialSecurityAge,
      'socialSecurityBenefit': socialSecurityBenefit,
      'spouseSocialSecurityAge': spouseSocialSecurityAge,
      'spouseSocialSecurityBenefit': spouseSocialSecurityBenefit,
      'userFourOneKContrib': userFourOneKContrib,
      'userRothIRAContrib': userRothIRAContrib,
      'spouseFourOneKContrib': spouseFourOneKContrib,
      'spouseRothIRAContrib': spouseRothIRAContrib,
      'pensionIncome': pensionIncome,
      'otherPassiveIncome': otherPassiveIncome,
      'insuranceType': insuranceType,
      'insuranceCoverage': insuranceCoverage,
      'legacyGoal': legacyGoal,
      'lifeEvents': lifeEvents.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    final data = OnboardingData()
      ..includePartner = map['includePartner'] ?? false
      ..currentAge = (map['currentAge'] ?? 35).toInt()
      ..birthDate = map['birthDate'] != null
          ? DateTime.tryParse(map['birthDate'])
          : null
      ..retirementAge = (map['retirementAge'] ?? 65).toInt()
      ..lifeExpectancy = (map['lifeExpectancy'] ?? 90).toInt()
      ..taxFilingStatus = map['taxFilingStatus'] ?? 'single'
      ..stateOfResidence = map['stateOfResidence'] ?? 'California'
      ..spouseAge = map['spouseAge']?.toInt()
      ..spouseBirthDate = map['spouseBirthDate'] != null
          ? DateTime.tryParse(map['spouseBirthDate'])
          : null
      ..spouseRetirementAge = map['spouseRetirementAge']?.toInt()
      ..spouseSalary = (map['spouseSalary'] ?? 0).toDouble()
      ..currentSalary = (map['currentSalary'] ?? 100000).toDouble()
      ..currentExpenses = (map['currentExpenses'] ?? 75000).toDouble()
      ..generalInflation = (map['generalInflation'] ?? 2.5).toDouble()
      ..taxTargetBracket = map['taxTargetBracket'] ?? '22%'
      ..taxDeferredSavings = (map['taxDeferredSavings'] ?? 200000).toDouble()
      ..taxableSavings = (map['taxableSavings'] ?? 0).toDouble()
      ..taxFreeSavings = (map['taxFreeSavings'] ?? 0).toDouble()
      ..spouseTaxDeferredSavings = (map['spouseTaxDeferredSavings'] ?? 0)
          .toDouble()
      ..spouseTaxableSavings = (map['spouseTaxableSavings'] ?? 0).toDouble()
      ..spouseTaxFreeSavings = (map['spouseTaxFreeSavings'] ?? 0).toDouble()
      ..showDetailedBalances = map['showDetailedBalances'] ?? false
      ..expectedReturn = (map['expectedReturn'] ?? 7.0).toDouble()
      ..studentLoanBalance = (map['studentLoanBalance'] ?? 0).toDouble()
      ..studentLoanMonthly = (map['studentLoanMonthly'] ?? 0).toDouble()
      ..studentLoanRate = (map['studentLoanRate'] ?? 0).toDouble()
      ..carLoanBalance = (map['carLoanBalance'] ?? 0).toDouble()
      ..carLoanMonthly = (map['carLoanMonthly'] ?? 0).toDouble()
      ..carLoanYears = (map['carLoanYears'] ?? 0).toDouble()
      ..creditCardBalance = (map['creditCardBalance'] ?? 0).toDouble()
      ..creditCardMonthly = (map['creditCardMonthly'] ?? 0).toDouble()
      ..housingStatus = map['housingStatus'] ?? 'Rent'
      ..monthlyRent = (map['monthlyRent'] ?? 2000).toDouble()
      ..monthlyMortgage = (map['monthlyMortgage'] ?? 0).toDouble()
      ..rentalIncome = (map['rentalIncome'] ?? 0).toDouble()
      ..medicalExpenses = (map['medicalExpenses'] ?? 0).toDouble()
      ..medicalInflation = (map['medicalInflation'] ?? 5.0).toDouble()
      ..businessIncome = (map['businessIncome'] ?? 0).toDouble()
      ..businessGrowth = (map['businessGrowth'] ?? 0).toDouble()
      ..numChildren = (map['numChildren'] ?? 0).toInt()
      ..childMonthlySpending = (map['childMonthlySpending'] ?? 0).toDouble()
      ..collegeGoal = (map['collegeGoal'] ?? 0).toDouble()
      ..socialSecurityAge = (map['socialSecurityAge'] ?? 67).toInt()
      ..socialSecurityBenefit = (map['socialSecurityBenefit'] ?? 2500)
          .toDouble()
      ..spouseSocialSecurityAge = (map['spouseSocialSecurityAge'] ?? 67).toInt()
      ..spouseSocialSecurityBenefit = (map['spouseSocialSecurityBenefit'] ?? 0)
          .toDouble()
      ..userFourOneKContrib = (map['userFourOneKContrib'] ?? 20000).toDouble()
      ..userRothIRAContrib = (map['userRothIRAContrib'] ?? 6000).toDouble()
      ..spouseFourOneKContrib = (map['spouseFourOneKContrib'] ?? 0).toDouble()
      ..spouseRothIRAContrib = (map['spouseRothIRAContrib'] ?? 0).toDouble()
      ..pensionIncome = (map['pensionIncome'] ?? 0).toDouble()
      ..otherPassiveIncome = (map['otherPassiveIncome'] ?? 0).toDouble()
      ..insuranceType = map['insuranceType'] ?? 'none'
      ..insuranceCoverage = (map['insuranceCoverage'] ?? 0).toDouble()
      ..legacyGoal = (map['legacyGoal'] ?? 0).toDouble();

    if (map['lifeEvents'] != null) {
      data.lifeEvents = (map['lifeEvents'] as List)
          .map((e) => LifeEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return data;
  }

  RetirementSimulationParams get toSimulationParams {
    return RetirementSimulationParams(
      p1StartAge: currentAge,
      p2StartAge: includePartner ? (spouseAge ?? currentAge) : currentAge,
      endSimulationAge: lifeExpectancy,
      inflationRate: generalInflation / 100,
      annualSpendGoal:
          currentExpenses, // Map frontend 'currentExpenses' to backend 'annualSpendGoal'
      filingStatus: taxFilingStatus == 'single' ? 'Single' : 'MFJ',
      p1EmploymentIncome: currentSalary,
      p1EmploymentUntilAge: retirementAge,
      p2EmploymentIncome: includePartner ? spouseSalary : 0,
      p2EmploymentUntilAge: includePartner
          ? (spouseRetirementAge ?? retirementAge)
          : retirementAge,
      p1SsAmount: socialSecurityBenefit,
      p1SsStartAge: socialSecurityAge,
      p2SsAmount: includePartner ? spouseSocialSecurityBenefit : 0,
      p2SsStartAge: includePartner ? spouseSocialSecurityAge : 67,
      p1Pension: pensionIncome,
      p1PensionStartAge: 65,
      p2Pension: 0,
      p2PensionStartAge: 65,
      balTaxable: taxableSavings + (includePartner ? spouseTaxableSavings : 0),
      balPretaxP1: taxDeferredSavings,
      balPretaxP2: includePartner ? spouseTaxDeferredSavings : 0,
      balRothP1: taxFreeSavings,
      balRothP2: includePartner ? spouseTaxFreeSavings : 0,
      growthRateTaxable: expectedReturn / 100,
      growthRatePretaxP1: expectedReturn / 100,
      growthRatePretaxP2: expectedReturn / 100,
      growthRateRothP1: expectedReturn / 100,
      growthRateRothP2: expectedReturn / 100,
      taxableBasisRatio: 0.8,
      targetTaxBracketRate:
          (double.tryParse(taxTargetBracket.replaceAll('%', '')) ?? 22.0) / 100,
      rental1Income: rentalIncome,
    );
  }
}
