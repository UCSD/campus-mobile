/// ============================================================================
/// File: feature_flags.dart
/// Description: Centralized configuration for enabling/disabling app features
///              using static boolean variables. Because these are static const,
///              the Dart compiler will optimize away (tree-shake) dead code
///              when features are disabled, saving compute and memory resources.
/// ============================================================================

class FeatureFlags {
  // ---------------------------------------------------------------------------
  // Search & Navigation
  // ---------------------------------------------------------------------------

  /// Controls the availability of the core Search Bar.
  /// - `true`: The top search bar is rendered, allowing text search for buildings and places.
  /// - `false`: The search bar is completely hidden. (Note: this effectively disables AI search and category chips too).
  static const bool mapSearchEnabled = true;

  /// Controls the availability of the AI Search feature.
  /// - `true`: Renders the AI search trigger button inside the search bar.
  /// - `false`: Hides the AI search button and prevents instantiation of AI-related models.
  static const bool mapAiSearchEnabled = false; // No AI search for now.

  /// Controls the quick-filter category chips (Dining, Library, Parking, Recreation).
  /// - `true`: Displays the quick-filter chips when the search bar is active.
  /// - `false`: Hides the chips, saving UI rendering time.
  static const bool mapSearchCategoriesEnabled = true;

  /// Controls point-to-point routing and directions.
  /// - `true`: Enables route calculation and displays "Directions" buttons in POI details.
  /// - `false`: Disables route generation logic and hides related UI elements.
  static const bool mapRoutingEnabled = true;

  /// Controls device GPS location tracking.
  /// - `true`: Starts the location data source to query GPS hardware and shows the re-center FAB.
  /// - `false`: Prevents querying GPS hardware (saving battery) and hides location UI controls.
  static const bool mapLocationTrackingEnabled = true;

  // ---------------------------------------------------------------------------
  // Basemaps & Layers (inside the Map Display)
  // ---------------------------------------------------------------------------

  /// Controls the availability of alternative basemaps like "Light" and "Dark".
  /// - `true`: The UI will display buttons for these basemaps, and the map controller
  ///           will instantiate and pre-load them into memory.
  /// - `false`: The UI buttons will be hidden, and the map controller will skip
  ///            creating these objects, saving significant memory.
  static const bool mapAlternateBasemapsEnabled = false; // No Light and Dark basemaps for now.

  /// Master switch for all Operational Layers (Transit, Districts, Construction).
  /// - `true`: Renders the "LAYERS" section in the map settings panel.
  /// - `false`: Hides the entire "LAYERS" section and prevents layer preloading.
  static const bool mapOperationalLayersEnabled = true;

  // Fine-grained layer toggles (Only effective if mapOperationalLayersEnabled is true)
  static const bool transitOperationalLayerEnabled = true;
  static const bool districtsOperationalLayerEnabled = true;
  static const bool constructionOperationalLayerEnabled = true;

  // ---------------------------------------------------------------------------
  // SCENES Feature (inside the Map Display)
  // ---------------------------------------------------------------------------

  /// Master switch for the 3D Scene View toggles.
  /// - `true`: Renders the "SCENE" section in the map settings panel.
  /// - `false`: Hides the entire "SCENE" section.
  static const bool mapScenesEnabled = false;

  // Fine-grained scene toggles (Only effective if mapScenesEnabled is true)
  static const bool defaultSceneEnabled = false;
  static const bool threeDimensionalSceneEnabled = false;
  static const bool droneViewSceneEnabled = false;
}
