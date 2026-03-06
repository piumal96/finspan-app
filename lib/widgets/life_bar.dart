import 'package:flutter/material.dart';
import '../theme/finspan_theme.dart';
import '../models/simulation_models.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FinSpanLifeBar extends StatefulWidget {
  final int currentAge;
  final int retirementAge;
  final int lifeExpectancy;
  final List<LifeEvent> events;
  final Function(int age)? onAddEvent;
  final Function(LifeEvent event)? onEventTap;
  final Function(String id, int newAge)? onEventMove;
  final Function(int newAge)? onAgeChange;

  const FinSpanLifeBar({
    super.key,
    required this.currentAge,
    required this.retirementAge,
    required this.lifeExpectancy,
    this.events = const [],
    this.onAddEvent,
    this.onEventTap,
    this.onEventMove,
    this.onAgeChange,
  });

  @override
  State<FinSpanLifeBar> createState() => _FinSpanLifeBarState();
}

class _FinSpanLifeBarState extends State<FinSpanLifeBar> {
  String? _draggingEventId;
  bool _isDraggingAge = false;

  // Track initial global pan position for absolute drag (avoids delta accumulation jitter)
  double _ageDragStartGlobalX = 0;
  double _ageDragStartPosX = 0;
  double _eventDragStartGlobalX = 0;
  double _eventDragStartPosX = 0;

  @override
  Widget build(BuildContext context) {
    const int minAge = 18;
    const int maxAge = 95;

    // Multi-row logic: group events to prevent overlap
    final List<List<LifeEvent>> eventRows = [];
    final sortedEvents = List<LifeEvent>.from(widget.events)
      ..sort((a, b) => a.startAge.compareTo(b.startAge));

    for (var event in sortedEvents) {
      bool placed = false;
      for (var row in eventRows) {
        final lastEvent = row.last;
        final lastEnd = lastEvent.endAge ?? lastEvent.startAge;
        // Padding of 5 years to prevent text overlap
        if (event.startAge >= lastEnd + 5) {
          row.add(event);
          placed = true;
          break;
        }
      }
      if (!placed) {
        eventRows.add([event]);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Financial Journey',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: FinSpanTheme.charcoal,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: FinSpanTheme.dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.events.length} Events',
                style: const TextStyle(
                  fontSize: 10,
                  color: FinSpanTheme.bodyGray,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            double ageToPos(int age) {
              double pct = (age - minAge) / (maxAge - minAge);
              return pct.clamp(0.0, 1.0) * constraints.maxWidth;
            }

            int posToAge(double x) {
              double pct = x / constraints.maxWidth;
              return (minAge + (pct * (maxAge - minAge))).round().clamp(
                minAge,
                maxAge,
              );
            }

            double currentAgePos = ageToPos(widget.currentAge);
            double retirementPos = ageToPos(widget.retirementAge);
            double endPos = ageToPos(widget.lifeExpectancy);

            return SizedBox(
              height:
                  100 +
                  (eventRows.length * 45.0), // Dynamic height based on rows
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Background Track (Tappable to add)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTapUp: (details) {
                        if (widget.onAddEvent != null) {
                          widget.onAddEvent!(
                            posToAge(details.localPosition.dx),
                          );
                        }
                      },
                      child: Container(
                        height: 30, // Large hit area
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: FinSpanTheme.dividerColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Accumulation Phase Highlight
                  Positioned(
                    top: 72,
                    left: currentAgePos,
                    child: Container(
                      height: 6,
                      width: (retirementPos - currentAgePos).clamp(
                        0,
                        constraints.maxWidth,
                      ),
                      decoration: BoxDecoration(
                        color: FinSpanTheme.primaryGreen.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // 3. Decumulation (Living) Phase Highlight
                  Positioned(
                    top: 72,
                    left: retirementPos,
                    child: Container(
                      height: 6,
                      width: (endPos - retirementPos).clamp(
                        0,
                        constraints.maxWidth,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // 4. Age Scale Markers
                  ...[20, 30, 40, 50, 60, 70, 80, 90].map((age) {
                    double x = ageToPos(age);
                    return Positioned(
                      left: x,
                      top: 85,
                      child: Column(
                        children: [
                          Container(
                            width: 1,
                            height: 4,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$age",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // 5. Draggable Current Age Handle
                  Positioned(
                    left: currentAgePos - 12,
                    top: 45,
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() => _isDraggingAge = true);
                        // Record starting touch and position for absolute tracking
                        _ageDragStartGlobalX = details.globalPosition.dx;
                        _ageDragStartPosX = currentAgePos;
                      },
                      onPanUpdate: (details) {
                        if (widget.onAgeChange != null) {
                          final double newX =
                              _ageDragStartPosX +
                              (details.globalPosition.dx -
                                  _ageDragStartGlobalX);
                          widget.onAgeChange!(posToAge(newX));
                        }
                      },
                      onPanEnd: (_) => setState(() => _isDraggingAge = false),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _isDraggingAge
                                  ? FinSpanTheme.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: FinSpanTheme.primaryGreen,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              "${widget.currentAge}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isDraggingAge
                                    ? Colors.white
                                    : FinSpanTheme.primaryGreen,
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FinSpanTheme.primaryGreen,
                                width: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 6. Interactive Event Rows
                  for (
                    int rowIndex = 0;
                    rowIndex < eventRows.length;
                    rowIndex++
                  )
                    for (var event in eventRows[rowIndex])
                      _buildEventItem(
                        event: event,
                        rowIndex: rowIndex,
                        ageToPos: ageToPos,
                        posToAge: posToAge,
                        constraints: constraints,
                      ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildLegendItem(
              "Accumulation",
              FinSpanTheme.primaryGreen.withValues(alpha: 0.6),
            ),
            _buildLegendItem(
              "Living",
              Colors.blueAccent.withValues(alpha: 0.4),
            ),
            const Text(
              "Drag pins to move • Tap track to add",
              style: TextStyle(
                fontSize: 10,
                color: FinSpanTheme.bodyGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventItem({
    required LifeEvent event,
    required int rowIndex,
    required double Function(int) ageToPos,
    required int Function(double) posToAge,
    required BoxConstraints constraints,
  }) {
    double startX = ageToPos(event.startAge);
    bool hasDuration = event.endAge != null && event.endAge! > event.startAge;
    double width = hasDuration
        ? (ageToPos(event.endAge!) - startX).clamp(4.0, constraints.maxWidth)
        : 0;

    // Y position calculation: markers finish at ~100, so rows start below at 110 + row*45
    double yPos = 110 + (rowIndex * 45.0);

    return Positioned(
      left: startX - (hasDuration ? 0 : 14),
      top: yPos,
      child: GestureDetector(
        onTap: () => widget.onEventTap?.call(event),
        onPanStart: (details) {
          setState(() => _draggingEventId = event.id);
          // Record starting touch and position for absolute tracking
          _eventDragStartGlobalX = details.globalPosition.dx;
          _eventDragStartPosX = startX;
        },
        onPanUpdate: (details) {
          if (widget.onEventMove != null) {
            final double newX =
                _eventDragStartPosX +
                (details.globalPosition.dx - _eventDragStartGlobalX);
            widget.onEventMove!(event.id, posToAge(newX));
          }
        },
        onPanEnd: (_) => setState(() => _draggingEventId = null),
        child: Opacity(
          opacity: _draggingEventId == event.id ? 0.7 : 1.0,
          child: hasDuration
              ? _buildDurationEvent(event, width)
              : _buildPinEvent(event),
        ),
      ),
    );
  }

  Widget _buildPinEvent(LifeEvent event) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _getEventColor(event.type),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(_getEventIcon(event.type), size: 14, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          event.name,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: FinSpanTheme.charcoal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDurationEvent(LifeEvent event, double width) {
    return Container(
      width: width,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: _getEventColor(event.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _getEventColor(event.type).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getEventColor(event.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEventIcon(event.type),
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              event.name,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: FinSpanTheme.charcoal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: FinSpanTheme.bodyGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getEventColor(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return Colors.blue;
      case LifeEventType.home:
        return Colors.orange;
      case LifeEventType.marriage:
        return Colors.pink;
      case LifeEventType.children:
        return Colors.purple;
      case LifeEventType.retirement:
        return Colors.green;
      case LifeEventType.education:
        return Colors.indigo;
      case LifeEventType.business:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(LifeEventType type) {
    switch (type) {
      case LifeEventType.job:
        return LucideIcons.briefcase;
      case LifeEventType.home:
        return LucideIcons.home;
      case LifeEventType.marriage:
        return LucideIcons.heart;
      case LifeEventType.children:
        return LucideIcons.baby;
      case LifeEventType.retirement:
        return LucideIcons.palmtree;
      case LifeEventType.education:
        return LucideIcons.graduationCap;
      case LifeEventType.business:
        return LucideIcons.rocket;
      default:
        return LucideIcons.calendarDays;
    }
  }
}
