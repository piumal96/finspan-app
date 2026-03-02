import 'dart:math';
import '../models/simulation_models.dart';
import '../screens/onboarding/onboarding_data.dart';

class SimulationService {
  static const double baseInflation = 0.025;
  static const double baseGrowth = 0.06;

  SimulationResult runSimulation(OnboardingData data) {
    List<WealthDataPoint> years = [];
    double taxable = data.taxableSavings;
    double taxDeferred = data.taxDeferredSavings;
    double roth = data.taxFreeSavings;

    if (data.includePartner) {
      taxable += data.spouseTaxableSavings;
      taxDeferred += data.spouseTaxDeferredSavings;
      roth += data.spouseTaxFreeSavings;
    }

    for (int age = data.currentAge; age <= data.lifeExpectancy; age++) {
      int yearIdx = age - data.currentAge;

      // 1. Calculate Income
      double annualIncome = 0;
      if (age < data.retirementAge) {
        // Working years
        annualIncome = data.annualSalary;
        if (data.includePartner) annualIncome += data.spouseSalary;
        // Apply 2.5% salary growth
        annualIncome *= pow(1.025, yearIdx);
      } else {
        // Retirement years - Social Security + Pensions
        annualIncome = data.socialSecurityBenefit * 12;
        if (data.includePartner) {
          annualIncome += data.spouseSocialSecurityBenefit * 12;
        }
        annualIncome += data.pensionIncome;
      }
      // Add passive income and business income
      double currentBusinessIncome =
          data.businessIncome * pow(1 + data.businessGrowth / 100, yearIdx);
      annualIncome += currentBusinessIncome + data.otherPassiveIncome;

      // 2. Calculate Expenses
      double annualExpenses = data.annualSpendingGoal; // Base goal

      // Add Debt Payments
      if (data.studentLoanBalance > 0 && yearIdx < 10) {
        // Assume 10 years for loans if not specified
        annualExpenses += data.studentLoanMonthly * 12;
      }
      if (data.carLoanBalance > 0 && yearIdx < data.carLoanYears) {
        annualExpenses += data.carLoanMonthly * 12;
      }
      if (data.creditCardBalance > 0 && yearIdx < 3) {
        // Assume 3 years for CC
        annualExpenses += data.creditCardMonthly * 12;
      }

      // Add Housing
      if (data.housingStatus == 'Rent') {
        annualExpenses +=
            data.monthlyRent * 12 * pow(1 + baseInflation, yearIdx);
      } else {
        annualExpenses += data.monthlyMortgage * 12;
      }

      // Add Medical (with medical inflation)
      annualExpenses +=
          data.medicalExpenses * pow(1 + data.medicalInflation / 100, yearIdx);

      // Add Child Expenses
      if (data.numChildren > 0 && age < (data.currentAge + 18)) {
        annualExpenses += data.childMonthlySpending * 12 * data.numChildren;
      }

      // Apply overall inflation to base expenses
      // Note: annualSpendingGoal usually already includes lifestyle,
      // but we should inflate it as well.
      double inflatedExpenses =
          annualExpenses * pow(1 + baseInflation, yearIdx);

      // 3. Net Cash Flow
      double netCashFlow = annualIncome - inflatedExpenses;

      // 4. Update Wealth
      if (netCashFlow > 0) {
        // Distribute savings: 40% taxable, 40% tax-deferred, 20% roth
        taxable += netCashFlow * 0.4;
        taxDeferred += netCashFlow * 0.4;
        roth += netCashFlow * 0.2;
      } else {
        // Drawdown: Draw from taxable first, then roth, then tax-deferred
        double deficit = netCashFlow.abs();

        if (taxable >= deficit) {
          taxable -= deficit;
        } else {
          deficit -= taxable;
          taxable = 0;
          if (roth >= deficit) {
            roth -= deficit;
          } else {
            deficit -= roth;
            roth = 0;
            if (taxDeferred >= deficit) {
              taxDeferred -= deficit;
            } else {
              taxDeferred = 0; // Broke
            }
          }
        }
      }

      // 5. Apply Growth
      taxable *= (1 + baseGrowth);
      taxDeferred *= (1 + baseGrowth);
      roth *= (1 + baseGrowth);

      double totalWealth = taxable + taxDeferred + roth;

      years.add(
        WealthDataPoint(
          age: age,
          taxable: taxable,
          taxDeferred: taxDeferred,
          roth: roth,
          total: totalWealth,
          cashFlow: netCashFlow / 12,
          riskLevel: totalWealth < 0
              ? 'caution'
              : (netCashFlow < 0 ? 'aware' : 'safe'),
        ),
      );
    }

    return SimulationResult(
      years: years,
      successProbability: _calculateSuccessProbability(data, years),
      endingWealth: years.last.total,
      shortfallAge: _findShortfallAge(years),
    );
  }

  double _calculateSuccessProbability(
    OnboardingData data,
    List<WealthDataPoint> years,
  ) {
    // Percentage of years that stayed positive
    int successYears = years.where((y) => y.total > 1000).length;
    double ratio = successYears / years.length;
    return (ratio * 100).clamp(0.0, 100.0);
  }

  int? _findShortfallAge(List<WealthDataPoint> years) {
    for (var point in years) {
      if (point.total < 1000 && point.age > (years.first.age + 5)) {
        return point.age;
      }
    }
    return null;
  }
}
