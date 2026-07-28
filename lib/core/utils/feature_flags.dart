/// ============================================================================
/// File: feature_flags.dart
/// Description: Centralized configuration for enabling/disabling app features
///              using static boolean variables. Because these are static const,
///              the Dart compiler will optimize away (tree-shake) dead code
///              when features are disabled, saving compute and memory resources.
/// ============================================================================

/// Note: Since these are static variables, you need to rebuild the app after changing the value to see working changes.
class FeatureFlags {
  /// Controls the availability of alternative basemaps like "Light" and "Dark".
  /// - `true`: The UI will display buttons for these basemaps, and the map controller
  ///           will instantiate and pre-load them into memory.
  /// - `false`: The UI buttons will be hidden, and the map controller will skip
  ///            creating these objects, saving significant memory.
  static const bool mapAlternateBasemapsEnabled = false;

  /// Controls the availability of 3D Scene views (e.g., Drone View, 3D Building).
  /// - `true`: The UI will render the "SCENE" toggle chips.
  /// - `false`: The scene toggles will be hidden from the user, saving compute time
  ///            associated with rendering and managing scene UI states.
  static const bool mapScenesEnabled = false;
}
