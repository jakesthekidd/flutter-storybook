import 'package:flutter/foundation.dart';

import 'certify_logs_banner.dart';

/// A small state machine for the Certify Logs banner.
///
/// One controller owns the four banner states, the expanded/collapsed flag,
/// and the verification timestamp. App code drives it with high-level
/// methods (`markCertified()`, `runGeotabCheck(...)`, etc.) instead of
/// orchestrating individual setState calls.
///
/// Typical wiring:
///
/// ```dart
/// final certifyLogs = CertifyLogsController();
///
/// // Somewhere in your widget tree:
/// ListenableBuilder(
///   listenable: certifyLogs,
///   builder: (_, __) => CertifyLogsBanner.controlled(
///     certifyLogs,
///     required: workflow.requiresCertification,
///     onCertifyTap: () => certifyLogs.runGeotabCheck(geotab.isCertified),
///     onTryAgainTap: () => certifyLogs.runGeotabCheck(geotab.isCertified),
///     onSelfAttestTap: () => certifyLogs.markCertified(attested: true),
///     onSkipTap: certifyLogs.collapse,
///   ),
/// );
/// ```
class CertifyLogsController extends ChangeNotifier {
  CertifyLogsController({
    CertifyLogsState initialState = CertifyLogsState.uncertified,
    bool expanded = true,
    DateTime? verifiedAt,
  })  : _state = initialState,
        _expanded = expanded,
        _verifiedAt = verifiedAt;

  CertifyLogsState _state;
  bool _expanded;
  DateTime? _verifiedAt;
  bool _attested = false;

  CertifyLogsState get state => _state;
  bool get expanded => _expanded;
  DateTime? get verifiedAt => _verifiedAt;

  /// `true` if the certified state was reached via driver self-attestation
  /// rather than a successful Geotab API call. Use to drive event tracking
  /// with different compliance weight.
  bool get attested => _attested;

  bool get isBlockingProgress =>
      _state == CertifyLogsState.uncertified ||
      _state == CertifyLogsState.unverifiable ||
      _state == CertifyLogsState.loading;

  // ---- Direct state transitions -------------------------------------------

  void setLoading() => _setState(CertifyLogsState.loading);
  void setUncertified() => _setState(CertifyLogsState.uncertified);
  void setUnverifiable() => _setState(CertifyLogsState.unverifiable);

  void markCertified({DateTime? at, bool attested = false}) {
    _verifiedAt = at ?? DateTime.now();
    _attested = attested;
    _setState(CertifyLogsState.certified);
  }

  // ---- Expansion ----------------------------------------------------------

  void expand() {
    if (_expanded) return;
    _expanded = true;
    notifyListeners();
  }

  void collapse() {
    if (!_expanded) return;
    _expanded = false;
    notifyListeners();
  }

  void toggleExpanded() {
    _expanded = !_expanded;
    notifyListeners();
  }

  // ---- High-level orchestration ------------------------------------------

  /// Drives the full Geotab round-trip: shows the loading state, awaits the
  /// callback, lands on `certified` (success), `unverifiable` (returned false
  /// or threw), and re-expands if the user had collapsed.
  Future<void> runGeotabCheck(Future<bool> Function() check) async {
    expand();
    setLoading();
    try {
      final ok = await check();
      if (ok) {
        markCertified(attested: false);
      } else {
        setUnverifiable();
      }
    } catch (_) {
      setUnverifiable();
    }
  }

  // ---- Internal -----------------------------------------------------------

  void _setState(CertifyLogsState s) {
    if (_state == s) return;
    _state = s;
    notifyListeners();
  }
}
