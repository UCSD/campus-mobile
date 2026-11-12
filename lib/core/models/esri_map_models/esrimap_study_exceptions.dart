/// ============================================================================
/// File: esrimap_study_exceptions.dart
/// Description: Hand-audited study locations that the four base Study
///              aggregation legs miss, queried as a fifth leg by the Study
///              quick search.
/// ============================================================================
///
/// Provenance: hand-compiled from a live API audit on 2026-11-08; every
/// matchName was verified against a live response, with corrections
/// re-verified on 2026-11-12. Backend data enrichment is the proper
/// long-term fix. This table should shrink over time, not grow.

/// Which endpoint an exception entry queries.
enum StudyExceptionSource {
  /// Queries the POI search endpoint.
  poi,

  /// Queries the buildings search endpoint.
  buildings,
}

/// One hand-audited study location that the base Study legs miss.
class StudyException {
  /// Query term sent to the search endpoint.
  final String queryTerm;

  /// Endpoint this entry queries.
  final StudyExceptionSource source;

  /// Exact result names (case-insensitive) to accept from the query.
  final List<String> matchNames;

  /// Provenance or approximation note for future maintainers.
  final String note;

  /// Constructs a [StudyException] instance.
  const StudyException({required this.queryTerm, required this.source, required this.matchNames, required this.note});

  /// Whether [name] equals one of the match names, case-insensitively.
  bool matches(String name) => matchNames.any((m) => m.trim().toLowerCase() == name.trim().toLowerCase());
}

/// The hand-audited exception table for the Study quick search.
class StudyExceptions {
  /// All exception entries, in table order.
  static const List<StudyException> entries = [
    // Eighth College: hall lounges are proxied by their buildings.
    StudyException(
      queryTerm: 'Azad',
      source: StudyExceptionSource.buildings,
      matchNames: ['Azad'],
      note: 'proxy for hall lounges',
    ),
    StudyException(
      queryTerm: 'Podemos',
      source: StudyExceptionSource.buildings,
      matchNames: ['Podemos'],
      note: 'proxy for hall lounges',
    ),
    StudyException(
      queryTerm: 'Pulse',
      source: StudyExceptionSource.buildings,
      matchNames: ['Pulse'],
      note: 'proxy for hall lounges',
    ),
    StudyException(
      queryTerm: 'Sankofa',
      source: StudyExceptionSource.buildings,
      matchNames: ['Sankofa'],
      note: 'proxy for hall lounges',
    ),
    StudyException(
      queryTerm: 'Survivance',
      source: StudyExceptionSource.buildings,
      matchNames: ['Survivance'],
      note: 'proxy for hall lounges',
    ),
    StudyException(
      queryTerm: "Angela's Space",
      source: StudyExceptionSource.poi,
      matchNames: ["Drop-off at Angela's Space"],
      note: 'drop-off POI filed under Sustainability - Compost Locations; approximate',
    ),
    // Muir College
    StudyException(
      queryTerm: 'Tioga Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Tioga Hall'],
      note: 'proxy for Tioga residence halls',
    ),
    StudyException(
      queryTerm: 'Tenaya Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Tenaya Hall'],
      note: 'proxy for Tenaya residence hall lounges',
    ),
    StudyException(
      queryTerm: 'Tamarack Apartments',
      source: StudyExceptionSource.buildings,
      matchNames: ['Tamarack Apartments East', 'Tamarack Apartments West'],
      note: 'East and West buildings proxy for the complex lounges',
    ),
    StudyException(
      queryTerm: 'Pines Restaurant',
      source: StudyExceptionSource.poi,
      matchNames: ['Pines Restaurant'],
      note: 'Dining-class study spot',
    ),
    StudyException(
      queryTerm: "John's Place and Market",
      source: StudyExceptionSource.poi,
      matchNames: ["John's Place and Market"],
      note: 'outdoor seating',
    ),
    // Revelle College
    StudyException(
      queryTerm: 'Argo Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Argo Hall'],
      note: 'Fleet has no data point - excluded; "Wells Fargo Hall" is excluded by the exact match',
    ),
    StudyException(
      queryTerm: 'Charles David Keeling Apartments',
      source: StudyExceptionSource.buildings,
      matchNames: [
        'Charles David Keeling Apartments 1',
        'Charles David Keeling Apartments 2',
        'Charles David Keeling Apartments 3',
      ],
      note: 'proxy for Keeling 1 and 3 lounges',
    ),
    StudyException(
      queryTerm: 'Harlan Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Harlan Hall'],
      note: 'proxy for floor lounges',
    ),
    StudyException(
      queryTerm: 'Frankfurter Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Frankfurter Hall'],
      note: 'proxy for floor lounges',
    ),
    StudyException(
      queryTerm: 'Stewart Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Stewart Hall'],
      note: 'proxy for floor lounges',
    ),
    // Warren College
    StudyException(
      queryTerm: 'Warren Student Activity Center',
      source: StudyExceptionSource.poi,
      matchNames: ['Warren Student Activity Center'],
      note: 'The Courtroom; precedes the buildings twin so the richer record wins the dedupe',
    ),
    StudyException(
      queryTerm: 'Warren Student Activity Center',
      source: StudyExceptionSource.buildings,
      matchNames: ['Warren Student Activity Center'],
      note: 'fallback if the POI is ever removed',
    ),
    StudyException(
      queryTerm: 'Canyon Vista Marketplace',
      source: StudyExceptionSource.poi,
      matchNames: ['Canyon Vista Marketplace'],
      note: 'Dining-class study spot',
    ),
    // Seventh College
    StudyException(
      queryTerm: 'North Break',
      source: StudyExceptionSource.poi,
      matchNames: ['Seventh College- North Break (Game Room & Study Room)'],
      note: 'misfiled under Mobility; approximate',
    ),
    // ERC
    StudyException(
      queryTerm: 'Africa Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Africa Hall'],
      note: 'proxy for continent-hall lounges',
    ),
    StudyException(
      queryTerm: 'Asia Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Asia Hall'],
      note: 'proxy for continent-hall lounges',
    ),
    StudyException(
      queryTerm: 'Europe Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Europe Hall'],
      note: 'proxy for continent-hall lounges',
    ),
    StudyException(
      queryTerm: 'Latin America Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['Latin America Hall'],
      note: 'proxy for continent-hall lounges',
    ),
    StudyException(
      queryTerm: 'North America Hall',
      source: StudyExceptionSource.buildings,
      matchNames: ['North America Hall'],
      note: 'proxy for continent-hall lounges',
    ),
    StudyException(
      queryTerm: 'Asante Meeting Rooms',
      source: StudyExceptionSource.poi,
      matchNames: ['Asante Meeting Rooms'],
      note: 'I-House; an "Asante House" namesake is excluded by the exact match',
    ),
    StudyException(
      queryTerm: 'Cuzco House',
      source: StudyExceptionSource.poi,
      matchNames: ['Cuzco House'],
      note: 'I-House',
    ),
    StudyException(
      queryTerm: 'Kathmandu House',
      source: StudyExceptionSource.poi,
      matchNames: ['Kathmandu House'],
      note: 'I-House',
    ),
    StudyException(
      queryTerm: 'Student Activities Center',
      source: StudyExceptionSource.poi,
      matchNames: ['Student Activities Center'],
      note: 'the "Fishbowl"; a Hydration Location namesake is excluded by the exact match',
    ),
    StudyException(
      queryTerm: 'ERC Commuter Lounge',
      source: StudyExceptionSource.poi,
      matchNames: ['ERC Commuter Lounge'],
      note: 'misfiled under Mobility',
    ),
    StudyException(
      queryTerm: 'Great Hall',
      source: StudyExceptionSource.poi,
      matchNames: ['Great Hall'],
      note: 'same-name POIs across classes dedupe to one pin; variants excluded by the exact match',
    ),
    StudyException(
      queryTerm: 'Ventanas',
      source: StudyExceptionSource.buildings,
      matchNames: ['Ventanas'],
      note: 'proxy for Cafe Ventanas; no cafe POI exists',
    ),
  ];
}
