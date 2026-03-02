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
}

class WealthDataPoint {
  final int age;
  final double taxable;
  final double taxDeferred;
  final double roth;
  final double total;
  final double cashFlow;
  final String riskLevel; // 'safe', 'caution', 'aware'

  WealthDataPoint({
    required this.age,
    required this.taxable,
    required this.taxDeferred,
    required this.roth,
    required this.total,
    required this.cashFlow,
    required this.riskLevel,
  });
}

class SimulationResult {
  final List<WealthDataPoint> years;
  final double successProbability;
  final double endingWealth;
  final int? shortfallAge;

  SimulationResult({
    required this.years,
    required this.successProbability,
    required this.endingWealth,
    this.shortfallAge,
  });
}
