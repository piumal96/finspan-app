import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simulation_models.dart';

class SimulationService {
  // Base URL for the FastAPI backend
  static const String baseUrl =
      'https://retirement-planner-backend-471609383103.us-central1.run.app/api';

  Future<SimulationResult?> runSimulation(
    RetirementSimulationParams params,
  ) async {
    try {
      // 1. Fire off the standard API call
      final standardFuture = http
          .post(
            Uri.parse('$baseUrl/run-simulation'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(params.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      // 2. Fire off the Monte Carlo API call concurrently
      final mcFuture = runMonteCarlo(params);

      // 3. Await the standard response first
      final response = await standardFuture;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true && data['scenarios'] != null) {
          final scenarios = data['scenarios'];

          final standardResults = (scenarios['standard']['results'] as List)
              .map((year) => WealthDataPoint.fromJson(year))
              .toList();

          final taxableFirstResults =
              (scenarios['taxable_first']['results'] as List)
                  .map((year) => WealthDataPoint.fromJson(year))
                  .toList();

          if (standardResults.isEmpty) return null;

          // Now wait for Monte Carlo to finish
          MonteCarloResult? mcResult;
          try {
            mcResult = await mcFuture;
          } catch (e) {
            print(
              "Monte Carlo failed, but returning standard results. Error: $e",
            );
          }

          return SimulationResult(
            standardResults: standardResults,
            taxableFirstResults: taxableFirstResults,
            successProbability: _calculateSuccessProbability(standardResults),
            endingWealth: standardResults.last.netWorth,
            shortfallAge: _findShortfallAge(standardResults),
            monteCarlo: mcResult,
          );
        }
      }
      throw Exception(
        'Failed to connect to simulation API: ${response.statusCode}',
      );
    } catch (e, stack) {
      print('Error running simulation: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<MonteCarloResult?> runMonteCarlo(
    RetirementSimulationParams params, {
    double? volatility,
    int? numSims,
  }) async {
    try {
      final Map<String, dynamic> body = params.toJson();
      if (volatility != null) body['volatility'] = volatility;
      if (numSims != null) body['num_simulations'] = numSims;

      final response = await http
          .post(
            Uri.parse('$baseUrl/run-monte-carlo'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MonteCarloResult.fromJson(data);
        }
      }
      throw Exception(
        'Failed to connect to Monte Carlo API: ${response.statusCode}',
      );
    } catch (e, stack) {
      print('Error running Monte Carlo: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  double _calculateSuccessProbability(List<WealthDataPoint> results) {
    if (results.isEmpty) return 0.0;
    int successYears = results.where((y) => y.netWorth > 0).length;
    return (successYears / results.length) * 100.0;
  }

  int? _findShortfallAge(List<WealthDataPoint> results) {
    for (var point in results) {
      if (point.netWorth <= 0) {
        return point.age;
      }
    }
    return null;
  }
}
