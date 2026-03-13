import '../../models/simulation_models.dart';

class OnboardingData {
  OnboardingData();

  // ── Identity ─────────────────────────────────────────────────────────────
  String firstName = '';
  String lastName = '';
  String gender = 'Male'; // 'Male' | 'Female' | 'Other'

  bool includePartner = false;
  DateTime? birthDate;
  int currentAge = 35;
  int retirementAge = 65;
  int lifeExpectancy = 90;

  /// 'single' | 'married_joint' | 'married_separate' | 'head_of_household'
  String taxFilingStatus = 'single';
  String stateOfResidence = 'California';

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

  // ── Spouse ────────────────────────────────────────────────────────────────
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

  // ── Income & Expenses ─────────────────────────────────────────────────────
  double currentSalary = 100000;
  double currentExpenses = 75000;
  double generalInflation = 2.5;
  String taxTargetBracket = '22%';

  // ── Savings ───────────────────────────────────────────────────────────────
  double taxDeferredSavings = 200000;
  double taxableSavings = 0;
  double taxFreeSavings = 0;

  double spouseTaxDeferredSavings = 0;
  double spouseTaxableSavings = 0;
  double spouseTaxFreeSavings = 0;

  bool showDetailedBalances = false;

  double expectedReturn = 7.0;

  // ── Debts ─────────────────────────────────────────────────────────────────
  double studentLoanBalance = 0;
  double studentLoanMonthly = 0;
  double studentLoanRate = 0;
  double carLoanBalance = 0;
  double carLoanMonthly = 0;
  double carLoanYears = 0;
  double creditCardBalance = 0;
  double creditCardMonthly = 0;
  double creditCardRate = 18.0; // typical APR %

  // ── Housing ───────────────────────────────────────────────────────────────
  String housingStatus = 'Rent'; // 'Rent' | 'Own'
  double monthlyRent = 2000;
  double rentInflation = 3.0; // %
  double monthlyMortgage = 0;
  double rentalIncome = 0;
  // Home ownership details
  double homeValue = 0;
  double mortgageBalance = 0;
  double mortgageRate = 0; // % e.g. 6.5
  int mortgageYears = 0;

  // ── Healthcare & Medical ──────────────────────────────────────────────────
  double medicalExpenses = 0;
  double medicalInflation = 5.0;

  // ── Business ──────────────────────────────────────────────────────────────
  double businessIncome = 0;
  double businessGrowth = 0;
  int? businessEndsAtAge;

  // ── Children & Education ──────────────────────────────────────────────────
  int numChildren = 0;
  // Individual child ages (0 = not set)
  int child1Age = 0;
  int child2Age = 0;
  int child3Age = 0;
  int child4Age = 0;
  // Age-tiered monthly expenses per child (matches web model)
  double childExpense0to5 = 0;
  double childExpense6to12 = 0;
  double childExpense13to17 = 0;
  // Legacy flat field kept for UI backward compat (defaults to childExpense6to12)
  double childMonthlySpending = 0;
  double collegeGoal = 0; // college savings goal per child

  // ── Social Security ───────────────────────────────────────────────────────
  int socialSecurityAge = 67;
  double socialSecurityBenefit = 2500;
  int spouseSocialSecurityAge = 67;
  double spouseSocialSecurityBenefit = 0;

  // ── 401(k) Contributions ──────────────────────────────────────────────────
  double userFourOneKContrib = 20000;
  double userRothIRAContrib = 6000;
  double spouseFourOneKContrib = 0;
  double spouseRothIRAContrib = 0;

  double userContribRate = 15.0;
  double userEmployerMatchRate = 5.0;
  double spouseContribRate = 15.0;
  double spouseEmployerMatchRate = 5.0;

  bool smartTaxOptimization = true;
  String userContribType = 'Traditional';
  String spouseContribType = 'Traditional';

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

  // ── Other Income ──────────────────────────────────────────────────────────
  double pensionIncome = 0;
  double otherPassiveIncome = 0;

  // ── Insurance ─────────────────────────────────────────────────────────────
  String insuranceType = 'none'; // 'none' | 'term' | 'whole'
  double insuranceCoverage = 0;
  double lifeInsurancePremium = 0; // monthly premium
  int? lifeInsuranceTermEndsAtAge;

  // ── Legacy ────────────────────────────────────────────────────────────────
  double legacyGoal = 0;

  // ── Computed Helpers ──────────────────────────────────────────────────────
  double get spouseTotalSavings =>
      spouseTaxDeferredSavings + spouseTaxableSavings + spouseTaxFreeSavings;

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

  // ── Life Events ───────────────────────────────────────────────────────────
  List<LifeEvent> lifeEvents = [];

  // ── Filing Status → Backend String ───────────────────────────────────────
  String get _backendFilingStatus {
    switch (taxFilingStatus) {
      case 'single':
        return 'Single';
      case 'married_joint':
        return 'MFJ';
      case 'married_separate':
        return 'Married Filing Separately';
      case 'head_of_household':
        return 'Head of Household';
      default:
        return 'Single';
    }
  }

  // ── toSimulationParams — FULL PAYLOAD (matches web SimulationParams) ──────
  RetirementSimulationParams get toSimulationParams {
    final double rate = expectedReturn / 100;
    final double inflation = generalInflation / 100;
    final double targetBracket =
        (double.tryParse(taxTargetBracket.replaceAll('%', '')) ?? 22.0) / 100;
    final bool hasPartner = includePartner;

    // Child expense: if tier values are set use them; else distribute flat spend
    final double exp0to5 = childExpense0to5 > 0
        ? childExpense0to5
        : childMonthlySpending;
    final double exp6to12 = childExpense6to12 > 0
        ? childExpense6to12
        : childMonthlySpending;
    final double exp13to17 = childExpense13to17 > 0
        ? childExpense13to17
        : childMonthlySpending;

    return RetirementSimulationParams(
      // ── Core ──────────────────────────────────────────────────────────────
      p1StartAge: currentAge,
      p2StartAge: hasPartner ? (spouseAge ?? currentAge) : currentAge,
      endSimulationAge: lifeExpectancy,
      inflationRate: inflation,
      annualSpendGoal: currentExpenses,
      filingStatus: _backendFilingStatus,

      // ── Employment ────────────────────────────────────────────────────────
      p1EmploymentIncome: currentSalary,
      p1EmploymentUntilAge: retirementAge,
      p2EmploymentIncome: hasPartner ? spouseSalary : 0,
      p2EmploymentUntilAge: hasPartner
          ? (spouseRetirementAge ?? retirementAge)
          : retirementAge,

      // ── Social Security ───────────────────────────────────────────────────
      p1SsAmount: socialSecurityBenefit,
      p1SsStartAge: socialSecurityAge,
      p2SsAmount: hasPartner ? spouseSocialSecurityBenefit : 0,
      p2SsStartAge: hasPartner ? spouseSocialSecurityAge : 67,

      // ── Pensions ──────────────────────────────────────────────────────────
      p1Pension: pensionIncome,
      p1PensionStartAge: retirementAge,
      p2Pension: 0,
      p2PensionStartAge: hasPartner ? (spouseRetirementAge ?? retirementAge) : retirementAge,

      // ── Account Balances ──────────────────────────────────────────────────
      balTaxable: taxableSavings + (hasPartner ? spouseTaxableSavings : 0),
      balPretaxP1: taxDeferredSavings,
      balPretaxP2: hasPartner ? spouseTaxDeferredSavings : 0,
      balRothP1: taxFreeSavings,
      balRothP2: hasPartner ? spouseTaxFreeSavings : 0,

      // ── Growth Rates ──────────────────────────────────────────────────────
      growthRateTaxable: rate,
      growthRatePretaxP1: rate,
      growthRatePretaxP2: rate,
      growthRateRothP1: rate,
      growthRateRothP2: rate,

      // ── Tax ───────────────────────────────────────────────────────────────
      taxableBasisRatio: 0.8,
      targetTaxBracketRate: targetBracket,

      // ── 401k Contributions ────────────────────────────────────────────────
      p1FourOnekContributionRate: userContribRate / 100,
      p1FourOnekEmployerMatchRate: userEmployerMatchRate / 100,
      p1FourOnekIsRoth: userContribType == 'Roth',
      p2FourOnekContributionRate: hasPartner ? spouseContribRate / 100 : 0.0,
      p2FourOnekEmployerMatchRate:
          hasPartner ? spouseEmployerMatchRate / 100 : 0.0,
      p2FourOnekIsRoth: hasPartner ? spouseContribType == 'Roth' : false,
      autoOptimizeRothTraditional: smartTaxOptimization,

      // ── Debts ─────────────────────────────────────────────────────────────
      studentLoanBalance: studentLoanBalance,
      studentLoanRate: studentLoanRate / 100,
      studentLoanPayment: studentLoanMonthly,
      carLoanBalance: carLoanBalance,
      carLoanPayment: carLoanMonthly,
      carLoanYears: carLoanYears.toInt(),
      creditCardDebt: creditCardBalance,
      creditCardPayment: creditCardMonthly,
      creditCardRate: creditCardRate / 100,

      // ── Healthcare ────────────────────────────────────────────────────────
      annualMedicalExpenses: medicalExpenses,
      medicalInflationRate: medicalInflation / 100,

      // ── Business ──────────────────────────────────────────────────────────
      businessIncome: businessIncome,
      businessGrowthRate: businessGrowth / 100,
      businessEndsAtAge: businessEndsAtAge,

      // ── Children ──────────────────────────────────────────────────────────
      numChildren: numChildren,
      child1CurrentAge: child1Age,
      child2CurrentAge: child2Age,
      child3CurrentAge: child3Age,
      child4CurrentAge: child4Age,
      monthlyExpensePerChild0to5: exp0to5,
      monthlyExpensePerChild6to12: exp6to12,
      monthlyExpensePerChild13to17: exp13to17,
      collegeCostPerYear: collegeGoal,

      // ── Other Income ──────────────────────────────────────────────────────
      passiveIncome: otherPassiveIncome,
      passiveIncomeGrowthRate: 0.02,

      // ── Life Insurance ────────────────────────────────────────────────────
      lifeInsurancePremium: lifeInsurancePremium,
      lifeInsuranceType: insuranceType,
      lifeInsuranceTermEndsAtAge: lifeInsuranceTermEndsAtAge,

      // ── Housing ───────────────────────────────────────────────────────────
      monthlyRent: housingStatus == 'Rent' ? monthlyRent : 0,
      rentInflationRate: rentInflation / 100,

      // ── Primary Home (if owner) ───────────────────────────────────────────
      primaryHomeValue: housingStatus == 'Own' && homeValue > 0
          ? homeValue
          : null,
      primaryHomeGrowthRate: housingStatus == 'Own' ? 0.04 : null,
      primaryHomeMortgagePrincipal: housingStatus == 'Own' && mortgageBalance > 0
          ? mortgageBalance
          : null,
      primaryHomeMortgageRate: housingStatus == 'Own' && mortgageRate > 0
          ? mortgageRate / 100
          : null,
      primaryHomeMortgageYears: housingStatus == 'Own' && mortgageYears > 0
          ? mortgageYears
          : null,

      // ── Rental Income ─────────────────────────────────────────────────────
      rental1Value: 0,
      rental1Income: rentalIncome,
      rental1MortgagePrincipal: 0,
    );
  }

  // ── copyWith ──────────────────────────────────────────────────────────────
  OnboardingData copyWith({
    String? firstName,
    String? lastName,
    String? gender,
    bool? includePartner,
    int? currentAge,
    int? retirementAge,
    int? lifeExpectancy,
    String? taxFilingStatus,
    String? stateOfResidence,
    DateTime? birthDate,
    DateTime? spouseBirthDate,
    int? spouseAge,
    int? spouseRetirementAge,
    double? spouseSalary,
    double? currentSalary,
    double? currentExpenses,
    double? generalInflation,
    String? taxTargetBracket,
    double? taxDeferredSavings,
    double? taxableSavings,
    double? taxFreeSavings,
    double? spouseTaxDeferredSavings,
    double? spouseTaxableSavings,
    double? spouseTaxFreeSavings,
    bool? showDetailedBalances,
    double? expectedReturn,
    double? studentLoanBalance,
    double? studentLoanMonthly,
    double? studentLoanRate,
    double? carLoanBalance,
    double? carLoanMonthly,
    double? carLoanYears,
    double? creditCardBalance,
    double? creditCardMonthly,
    double? creditCardRate,
    String? housingStatus,
    double? monthlyRent,
    double? rentInflation,
    double? monthlyMortgage,
    double? rentalIncome,
    double? homeValue,
    double? mortgageBalance,
    double? mortgageRate,
    int? mortgageYears,
    double? medicalExpenses,
    double? medicalInflation,
    double? businessIncome,
    double? businessGrowth,
    int? businessEndsAtAge,
    int? numChildren,
    int? child1Age,
    int? child2Age,
    int? child3Age,
    int? child4Age,
    double? childExpense0to5,
    double? childExpense6to12,
    double? childExpense13to17,
    double? childMonthlySpending,
    double? collegeGoal,
    int? socialSecurityAge,
    double? socialSecurityBenefit,
    int? spouseSocialSecurityAge,
    double? spouseSocialSecurityBenefit,
    double? userFourOneKContrib,
    double? userRothIRAContrib,
    double? spouseFourOneKContrib,
    double? spouseRothIRAContrib,
    double? userContribRate,
    double? userEmployerMatchRate,
    double? spouseContribRate,
    double? spouseEmployerMatchRate,
    bool? smartTaxOptimization,
    String? userContribType,
    String? spouseContribType,
    double? pensionIncome,
    double? otherPassiveIncome,
    String? insuranceType,
    double? insuranceCoverage,
    double? lifeInsurancePremium,
    int? lifeInsuranceTermEndsAtAge,
    double? legacyGoal,
    List<LifeEvent>? lifeEvents,
  }) {
    final d = OnboardingData()
      ..firstName = firstName ?? this.firstName
      ..lastName = lastName ?? this.lastName
      ..gender = gender ?? this.gender
      ..includePartner = includePartner ?? this.includePartner
      ..currentAge = currentAge ?? this.currentAge
      ..birthDate = birthDate ?? this.birthDate
      ..retirementAge = retirementAge ?? this.retirementAge
      ..lifeExpectancy = lifeExpectancy ?? this.lifeExpectancy
      ..taxFilingStatus = taxFilingStatus ?? this.taxFilingStatus
      ..stateOfResidence = stateOfResidence ?? this.stateOfResidence
      ..spouseBirthDate = spouseBirthDate ?? this.spouseBirthDate
      ..spouseAge = spouseAge ?? this.spouseAge
      ..spouseRetirementAge = spouseRetirementAge ?? this.spouseRetirementAge
      ..spouseSalary = spouseSalary ?? this.spouseSalary
      ..currentSalary = currentSalary ?? this.currentSalary
      ..currentExpenses = currentExpenses ?? this.currentExpenses
      ..generalInflation = generalInflation ?? this.generalInflation
      ..taxTargetBracket = taxTargetBracket ?? this.taxTargetBracket
      ..taxDeferredSavings = taxDeferredSavings ?? this.taxDeferredSavings
      ..taxableSavings = taxableSavings ?? this.taxableSavings
      ..taxFreeSavings = taxFreeSavings ?? this.taxFreeSavings
      ..spouseTaxDeferredSavings =
          spouseTaxDeferredSavings ?? this.spouseTaxDeferredSavings
      ..spouseTaxableSavings =
          spouseTaxableSavings ?? this.spouseTaxableSavings
      ..spouseTaxFreeSavings =
          spouseTaxFreeSavings ?? this.spouseTaxFreeSavings
      ..showDetailedBalances =
          showDetailedBalances ?? this.showDetailedBalances
      ..expectedReturn = expectedReturn ?? this.expectedReturn
      ..studentLoanBalance = studentLoanBalance ?? this.studentLoanBalance
      ..studentLoanMonthly = studentLoanMonthly ?? this.studentLoanMonthly
      ..studentLoanRate = studentLoanRate ?? this.studentLoanRate
      ..carLoanBalance = carLoanBalance ?? this.carLoanBalance
      ..carLoanMonthly = carLoanMonthly ?? this.carLoanMonthly
      ..carLoanYears = carLoanYears ?? this.carLoanYears
      ..creditCardBalance = creditCardBalance ?? this.creditCardBalance
      ..creditCardMonthly = creditCardMonthly ?? this.creditCardMonthly
      ..creditCardRate = creditCardRate ?? this.creditCardRate
      ..housingStatus = housingStatus ?? this.housingStatus
      ..monthlyRent = monthlyRent ?? this.monthlyRent
      ..rentInflation = rentInflation ?? this.rentInflation
      ..monthlyMortgage = monthlyMortgage ?? this.monthlyMortgage
      ..rentalIncome = rentalIncome ?? this.rentalIncome
      ..homeValue = homeValue ?? this.homeValue
      ..mortgageBalance = mortgageBalance ?? this.mortgageBalance
      ..mortgageRate = mortgageRate ?? this.mortgageRate
      ..mortgageYears = mortgageYears ?? this.mortgageYears
      ..medicalExpenses = medicalExpenses ?? this.medicalExpenses
      ..medicalInflation = medicalInflation ?? this.medicalInflation
      ..businessIncome = businessIncome ?? this.businessIncome
      ..businessGrowth = businessGrowth ?? this.businessGrowth
      ..businessEndsAtAge = businessEndsAtAge ?? this.businessEndsAtAge
      ..numChildren = numChildren ?? this.numChildren
      ..child1Age = child1Age ?? this.child1Age
      ..child2Age = child2Age ?? this.child2Age
      ..child3Age = child3Age ?? this.child3Age
      ..child4Age = child4Age ?? this.child4Age
      ..childExpense0to5 = childExpense0to5 ?? this.childExpense0to5
      ..childExpense6to12 = childExpense6to12 ?? this.childExpense6to12
      ..childExpense13to17 = childExpense13to17 ?? this.childExpense13to17
      ..childMonthlySpending =
          childMonthlySpending ?? this.childMonthlySpending
      ..collegeGoal = collegeGoal ?? this.collegeGoal
      ..socialSecurityAge = socialSecurityAge ?? this.socialSecurityAge
      ..socialSecurityBenefit =
          socialSecurityBenefit ?? this.socialSecurityBenefit
      ..spouseSocialSecurityAge =
          spouseSocialSecurityAge ?? this.spouseSocialSecurityAge
      ..spouseSocialSecurityBenefit =
          spouseSocialSecurityBenefit ?? this.spouseSocialSecurityBenefit
      ..userFourOneKContrib = userFourOneKContrib ?? this.userFourOneKContrib
      ..userRothIRAContrib = userRothIRAContrib ?? this.userRothIRAContrib
      ..spouseFourOneKContrib =
          spouseFourOneKContrib ?? this.spouseFourOneKContrib
      ..spouseRothIRAContrib =
          spouseRothIRAContrib ?? this.spouseRothIRAContrib
      ..userContribRate = userContribRate ?? this.userContribRate
      ..userEmployerMatchRate =
          userEmployerMatchRate ?? this.userEmployerMatchRate
      ..spouseContribRate = spouseContribRate ?? this.spouseContribRate
      ..spouseEmployerMatchRate =
          spouseEmployerMatchRate ?? this.spouseEmployerMatchRate
      ..smartTaxOptimization =
          smartTaxOptimization ?? this.smartTaxOptimization
      ..userContribType = userContribType ?? this.userContribType
      ..spouseContribType = spouseContribType ?? this.spouseContribType
      ..pensionIncome = pensionIncome ?? this.pensionIncome
      ..otherPassiveIncome = otherPassiveIncome ?? this.otherPassiveIncome
      ..insuranceType = insuranceType ?? this.insuranceType
      ..insuranceCoverage = insuranceCoverage ?? this.insuranceCoverage
      ..lifeInsurancePremium =
          lifeInsurancePremium ?? this.lifeInsurancePremium
      ..lifeInsuranceTermEndsAtAge =
          lifeInsuranceTermEndsAtAge ?? this.lifeInsuranceTermEndsAtAge
      ..legacyGoal = legacyGoal ?? this.legacyGoal
      ..lifeEvents = lifeEvents ?? List.from(this.lifeEvents);
    return d;
  }

  // ── toMap (Firestore) ─────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
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
      'creditCardRate': creditCardRate,
      'housingStatus': housingStatus,
      'monthlyRent': monthlyRent,
      'rentInflation': rentInflation,
      'monthlyMortgage': monthlyMortgage,
      'rentalIncome': rentalIncome,
      'homeValue': homeValue,
      'mortgageBalance': mortgageBalance,
      'mortgageRate': mortgageRate,
      'mortgageYears': mortgageYears,
      'medicalExpenses': medicalExpenses,
      'medicalInflation': medicalInflation,
      'businessIncome': businessIncome,
      'businessGrowth': businessGrowth,
      'businessEndsAtAge': businessEndsAtAge,
      'numChildren': numChildren,
      'child1Age': child1Age,
      'child2Age': child2Age,
      'child3Age': child3Age,
      'child4Age': child4Age,
      'childExpense0to5': childExpense0to5,
      'childExpense6to12': childExpense6to12,
      'childExpense13to17': childExpense13to17,
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
      'userContribRate': userContribRate,
      'userEmployerMatchRate': userEmployerMatchRate,
      'spouseContribRate': spouseContribRate,
      'spouseEmployerMatchRate': spouseEmployerMatchRate,
      'smartTaxOptimization': smartTaxOptimization,
      'userContribType': userContribType,
      'spouseContribType': spouseContribType,
      'pensionIncome': pensionIncome,
      'otherPassiveIncome': otherPassiveIncome,
      'insuranceType': insuranceType,
      'insuranceCoverage': insuranceCoverage,
      'lifeInsurancePremium': lifeInsurancePremium,
      'lifeInsuranceTermEndsAtAge': lifeInsuranceTermEndsAtAge,
      'legacyGoal': legacyGoal,
      'lifeEvents': lifeEvents.map((e) => e.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ── fromMap (Firestore restore) ───────────────────────────────────────────
  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    final data = OnboardingData()
      ..firstName = map['firstName'] ?? ''
      ..lastName = map['lastName'] ?? ''
      ..gender = map['gender'] ?? 'Male'
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
      ..spouseTaxDeferredSavings =
          (map['spouseTaxDeferredSavings'] ?? 0).toDouble()
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
      ..creditCardRate = (map['creditCardRate'] ?? 18.0).toDouble()
      ..housingStatus = map['housingStatus'] ?? 'Rent'
      ..monthlyRent = (map['monthlyRent'] ?? 2000).toDouble()
      ..rentInflation = (map['rentInflation'] ?? 3.0).toDouble()
      ..monthlyMortgage = (map['monthlyMortgage'] ?? 0).toDouble()
      ..rentalIncome = (map['rentalIncome'] ?? 0).toDouble()
      ..homeValue = (map['homeValue'] ?? 0).toDouble()
      ..mortgageBalance = (map['mortgageBalance'] ?? 0).toDouble()
      ..mortgageRate = (map['mortgageRate'] ?? 0).toDouble()
      ..mortgageYears = (map['mortgageYears'] ?? 0).toInt()
      ..medicalExpenses = (map['medicalExpenses'] ?? 0).toDouble()
      ..medicalInflation = (map['medicalInflation'] ?? 5.0).toDouble()
      ..businessIncome = (map['businessIncome'] ?? 0).toDouble()
      ..businessGrowth = (map['businessGrowth'] ?? 0).toDouble()
      ..businessEndsAtAge = map['businessEndsAtAge']?.toInt()
      ..numChildren = (map['numChildren'] ?? 0).toInt()
      ..child1Age = (map['child1Age'] ?? 0).toInt()
      ..child2Age = (map['child2Age'] ?? 0).toInt()
      ..child3Age = (map['child3Age'] ?? 0).toInt()
      ..child4Age = (map['child4Age'] ?? 0).toInt()
      ..childExpense0to5 = (map['childExpense0to5'] ?? 0).toDouble()
      ..childExpense6to12 = (map['childExpense6to12'] ?? 0).toDouble()
      ..childExpense13to17 = (map['childExpense13to17'] ?? 0).toDouble()
      ..childMonthlySpending = (map['childMonthlySpending'] ?? 0).toDouble()
      ..collegeGoal = (map['collegeGoal'] ?? 0).toDouble()
      ..socialSecurityAge = (map['socialSecurityAge'] ?? 67).toInt()
      ..socialSecurityBenefit =
          (map['socialSecurityBenefit'] ?? 2500).toDouble()
      ..spouseSocialSecurityAge =
          (map['spouseSocialSecurityAge'] ?? 67).toInt()
      ..spouseSocialSecurityBenefit =
          (map['spouseSocialSecurityBenefit'] ?? 0).toDouble()
      ..userFourOneKContrib = (map['userFourOneKContrib'] ?? 20000).toDouble()
      ..userRothIRAContrib = (map['userRothIRAContrib'] ?? 6000).toDouble()
      ..spouseFourOneKContrib =
          (map['spouseFourOneKContrib'] ?? 0).toDouble()
      ..spouseRothIRAContrib =
          (map['spouseRothIRAContrib'] ?? 0).toDouble()
      ..userContribRate = (map['userContribRate'] ?? 15.0).toDouble()
      ..userEmployerMatchRate =
          (map['userEmployerMatchRate'] ?? 5.0).toDouble()
      ..spouseContribRate = (map['spouseContribRate'] ?? 15.0).toDouble()
      ..spouseEmployerMatchRate =
          (map['spouseEmployerMatchRate'] ?? 5.0).toDouble()
      ..smartTaxOptimization = map['smartTaxOptimization'] ?? true
      ..userContribType = map['userContribType'] ?? 'Traditional'
      ..spouseContribType = map['spouseContribType'] ?? 'Traditional'
      ..pensionIncome = (map['pensionIncome'] ?? 0).toDouble()
      ..otherPassiveIncome = (map['otherPassiveIncome'] ?? 0).toDouble()
      ..insuranceType = map['insuranceType'] ?? 'none'
      ..insuranceCoverage = (map['insuranceCoverage'] ?? 0).toDouble()
      ..lifeInsurancePremium =
          (map['lifeInsurancePremium'] ?? 0).toDouble()
      ..lifeInsuranceTermEndsAtAge =
          map['lifeInsuranceTermEndsAtAge']?.toInt()
      ..legacyGoal = (map['legacyGoal'] ?? 0).toDouble();

    if (map['lifeEvents'] != null) {
      data.lifeEvents = (map['lifeEvents'] as List)
          .map((e) => LifeEvent.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }

    return data;
  }
}
