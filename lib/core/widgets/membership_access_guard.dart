import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A context-aware feature wrapper.
/// Allows direct access on the frontend; backend APIs manage feature permissions dynamically.
class MembershipAccessGuard extends ConsumerStatefulWidget {
  final Widget child;
  final String featureName;
  final String featureDescription;
  final IconData? featureIcon;
  final List<String>? highlightPerks;

  const MembershipAccessGuard({
    super.key,
    required this.child,
    required this.featureName,
    this.featureDescription = 'audio tracks, video lectures, eBooks & consultations',
    this.featureIcon,
    this.highlightPerks,
  });

  @override
  ConsumerState<MembershipAccessGuard> createState() => _MembershipAccessGuardState();
}

class _MembershipAccessGuardState extends ConsumerState<MembershipAccessGuard> {
  @override
  Widget build(BuildContext context) {
    // Membership feature access is managed dynamically by backend APIs.
    // Client-side wrapper renders the feature directly on the frontend.
    return widget.child;
  }
}
