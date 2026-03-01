import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import 'detailed_results.dart';

class SimulationRunnerScreen extends StatefulWidget {
  const SimulationRunnerScreen({super.key});

  @override
  State<SimulationRunnerScreen> createState() => _SimulationRunnerScreenState();
}

class _SimulationRunnerScreenState extends State<SimulationRunnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Simulate a 4 second calculation process
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..forward().then((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DetailedResultsScreen(),
                ),
              );
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: FinSpanTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: FinSpanTheme.charcoal),
        title: Text(
          'Retirement Simulator',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: FinSpanTheme.charcoal),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Main Intro Card
                      FinSpanCard(
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: FinSpanTheme.primaryGreen.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  FinSpanTheme.cardRadius,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.settings_suggest,
                                  size: 64,
                                  color: FinSpanTheme.primaryGreen,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Simulation Ready',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "We'll run 10,000 market scenarios based on your Sri Lankan economic assumptions.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Settings List
                      FinSpanCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'Target Success Rate',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: Text(
                                '90%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: FinSpanTheme.dividerColor,
                            ),
                            ListTile(
                              title: Text(
                                'Simulation Years',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: Text(
                                '35 Years',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Divider(
                              height: 1,
                              color: FinSpanTheme.dividerColor,
                            ),
                            ListTile(
                              title: Text(
                                'Base Inflation Override',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: Text(
                                '4.5%',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Active Loading State
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running 10,000 simulations...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: FinSpanTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 12,
                          backgroundColor: FinSpanTheme.dividerColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            FinSpanTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
