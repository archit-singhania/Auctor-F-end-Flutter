/// score_provider.dart
///
/// A Riverpod AsyncNotifier that owns the AuctorScore lifecycle:
///   - fetchScore()  → GET /api/score   → updates state
///   - refresh()     → re-fetches (call after badge submit or GitHub verify)
///
/// Screens read:  ref.watch(scoreProvider)
/// Screens write: ref.read(scoreProvider.notifier).refresh()

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auctor_api_service.dart';
import '../models/auctor_models.dart';

class ScoreNotifier extends AsyncNotifier<AuctorScore> {
  @override
  Future<AuctorScore> build() => _fetch();

  Future<AuctorScore> _fetch() =>
      ref.read(apiServiceProvider).fetchScore();

  /// Call after any event that changes the score (badge pass, GitHub verify).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final scoreProvider =
    AsyncNotifierProvider<ScoreNotifier, AuctorScore>(ScoreNotifier.new);
