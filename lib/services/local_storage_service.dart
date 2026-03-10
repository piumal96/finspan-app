import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/simulation_models.dart';
import '../screens/onboarding/onboarding_data.dart';

/// Hive-backed local cache for the user's financial plan.
///
/// Architecture:
///   Write path: My Plan save → Hive (instant) + Firebase (async, background)
///   Read path:  App start   → Hive (instant, no network)
///                           → Firebase (background, updates Hive silently)
///
/// This means the app always starts without a spinner for returning users,
/// and Firebase keeps the data in sync across devices.
class LocalStorageService {
  static const _boxName = 'finspan_cache';
  static const _mcStateKey = 'mc_enabled';

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Must be called once before runApp(), after Hive.initFlutter().
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  // ── Profile (OnboardingData) ───────────────────────────────────────────────

  static String _profileKey(String uid) => 'profile_$uid';

  /// Saves the user's plan to Hive synchronously (fast, no network).
  static Future<void> saveProfile(String uid, OnboardingData data) async {
    if (uid.isEmpty) return;
    try {
      await _box.put(_profileKey(uid), jsonEncode(data.toMap()));
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Hive saveProfile failed: $e');
    }
  }

  /// Reads the cached plan for [uid].  Returns null if nothing is cached yet.
  static OnboardingData? loadProfile(String uid) {
    if (uid.isEmpty) return null;
    final raw = _box.get(_profileKey(uid));
    if (raw == null) return null;
    try {
      return OnboardingData.fromMap(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Hive loadProfile parse error: $e');
      return null;
    }
  }

  /// Removes cached data for [uid] — called on sign-out so the next user
  /// on this device starts fresh.
  /// Removes cached data for [uid] — called on sign-out so the next user
  /// on this device starts fresh.
  static Future<void> clearProfile(String uid) async {
    if (uid.isEmpty) return;
    await _box.delete(_profileKey(uid));
    await clearSimState(uid);
    await _box.delete(_mcKey(uid));
  }

  // ── MC toggle persistence ─────────────────────────────────────────────────
  // Remembers whether the user left Monte Carlo enabled so the home chart
  // restores the same state on next launch.

  static String _mcKey(String uid) => '${_mcStateKey}_$uid';

  static Future<void> saveMcEnabled(String uid, {required bool enabled}) async {
    if (uid.isEmpty) return;
    await _box.put(_mcKey(uid), enabled ? '1' : '0');
  }

  static bool loadMcEnabled(String uid) {
    if (uid.isEmpty) return false;
    return _box.get(_mcKey(uid)) == '1';
  }

  // ── Simulator events ──────────────────────────────────────────────────────
  // Persists the user's custom life-event scenario so it survives app restarts.

  static String _simEventsKey(String uid) => 'sim_events_$uid';
  static String _simAgeKey(String uid) => 'sim_age_$uid';

  static Future<void> saveSimEvents(String uid, List<LifeEvent> events) async {
    if (uid.isEmpty) return;
    try {
      final list = events.map((e) => e.toMap()).toList();
      await _box.put(_simEventsKey(uid), jsonEncode(list));
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Hive saveSimEvents failed: $e');
    }
  }

  static List<LifeEvent>? loadSimEvents(String uid) {
    if (uid.isEmpty) return null;
    final raw = _box.get(_simEventsKey(uid));
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((m) => LifeEvent.fromMap(m as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Hive loadSimEvents parse error: $e');
      return null;
    }
  }

  static Future<void> saveSimCurrentAge(String uid, int age) async {
    if (uid.isEmpty) return;
    await _box.put(_simAgeKey(uid), age.toString());
  }

  static int? loadSimCurrentAge(String uid) {
    if (uid.isEmpty) return null;
    final raw = _box.get(_simAgeKey(uid));
    if (raw == null) return null;
    return int.tryParse(raw);
  }

  static Future<void> clearSimState(String uid) async {
    if (uid.isEmpty) return;
    await _box.delete(_simEventsKey(uid));
    await _box.delete(_simAgeKey(uid));
  }
}
