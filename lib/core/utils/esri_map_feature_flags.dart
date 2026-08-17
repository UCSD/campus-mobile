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
  static const bool MAP_SEARCH_ENABLED = true;

  /// Controls the availability of the AI Search feature.
  /// - `true`: Renders the AI search trigger button inside the search bar.
  /// - `false`: Hides the AI search button and prevents instantiation of AI-related models.
  static const bool MAP_AI_SEARCH_ENABLED = false; // No AI search for now.

  /// Controls the quick-filter category chips (Dining, Library, Parking, Recreation).
  /// - `true`: Displays the quick-filter chips when the search bar is active.
  /// - `false`: Hides the chips, saving UI rendering time.
  static const bool MAP_SEARCH_CATEGORIES_ENABLED = true;

  /// Controls point-to-point routing and directions.
  /// - `true`: Enables route calculation and displays "Directions" buttons in POI details.
  /// - `false`: Disables route generation logic and hides related UI elements.
  static const bool MAP_ROUTING_ENABLED = true;

  /// Controls device GPS location tracking.
  /// - `true`: Starts the location data source to query GPS hardware and shows the re-center FAB.
  /// - `false`: Prevents querying GPS hardware (saving battery) and hides location UI controls.
  static const bool MAP_LOCATION_TRACKING_ENABLED = true;

  // ---------------------------------------------------------------------------
  // Basemaps & Layers (inside the Map Display)
  // ---------------------------------------------------------------------------

  /// Controls the availability of alternative basemaps like "Light" and "Dark".
  /// - `true`: The UI will display buttons for these basemaps, and the map controller
  ///           will instantiate and pre-load them into memory.
  /// - `false`: The UI buttons will be hidden, and the map controller will skip
  ///            creating these objects, saving significant memory.
  static const bool MAP_ALTERNATE_BASEMAPS_ENABLED = false; // No Light and Dark basemaps for now.

  /// Master switch for all Operational Layers (Transit, Districts, Construction).
  /// - `true`: Renders the "LAYERS" section in the map settings panel.
  /// - `false`: Hides the entire "LAYERS" section and prevents layer preloading.
  static const bool MAP_OPERATIONAL_LAYERS_ENABLED = true;

  // Fine-grained layer toggles (Only effective if MAP_OPERATIONAL_LAYERS_ENABLED is true)
  static const bool TRANSIT_OPERATIONAL_LAYER_ENABLED = true;
  static const bool DISTRICTS_OPERATIONAL_LAYER_ENABLED = true;
  static const bool CONSTRUCTION_OPERATIONAL_LAYER_ENABLED = true;

  // ---------------------------------------------------------------------------
  // SCENES Feature (inside the Map Display)
  // ---------------------------------------------------------------------------

  /// Master switch for the 3D Scene View toggles.
  /// - `true`: Renders the "SCENE" section in the map settings panel.
  /// - `false`: Hides the entire "SCENE" section.
  static const bool MAP_SCENES_ENABLED = false;

  // Fine-grained scene toggles (Only effective if MAP_SCENES_ENABLED is true)
  static const bool DEFAULT_SCENE_ENABLED = false;
  static const bool THREE_DIMENSIONAL_SCENE_ENABLED = false;
  static const bool DRONE_VIEW_SCENE_ENABLED = false;
}
