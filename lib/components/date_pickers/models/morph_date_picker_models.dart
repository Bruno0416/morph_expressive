import 'package:flutter/foundation.dart';

/// Returns true when [day] can be selected in a single-date picker.
typedef MorphSelectableDayPredicate = bool Function(DateTime day);

/// Returns true when [day] can be selected in a range picker.
typedef MorphSelectableDayForRangePredicate = bool Function(DateTime day);

/// A selected date range with optional [end].
@immutable
class MorphDateRange {
  /// MorphDateRange.
  const MorphDateRange({required this.start, this.end});

  /// start.

  final DateTime start;

  /// end.
  final DateTime? end;

  /// The isComplete.

  bool get isComplete => end != null;

  @override
  bool operator ==(Object other) {
    return other is MorphDateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}
