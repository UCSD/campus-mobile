import 'package:campus_mobile_experimental/core/models/dining.dart';

const int _nameWeight = 4;
const int _paymentOptionsWeight = 3;
const int _specialTitleWeight = 2;
const int _locationWeight = 2;
const int _descriptionWeight = 1;

/// Searches [models] with the given [query] and returns the matching models in
/// relevance order.
///
/// An empty or whitespace-only query returns [models] unchanged. This keeps the
/// provider's payment filtering and distance ordering intact.
List<DiningModel> searchDiningModels(List<DiningModel> models, String query) {
  final String normalizedQuery = _normalizeText(query);
  if (normalizedQuery.isEmpty) return models;

  final List<String> queryTokens = normalizedQuery.split(' ');
  final List<_ScoredDiningModel> scoredModels = [];

  for (final DiningModel model in models) {
    final int? score = _scoreModel(model, queryTokens);
    if (score != null) scoredModels.add(_ScoredDiningModel(model, score));
  }

  scoredModels.sort((a, b) {
    final int scoreComparison = b.score.compareTo(a.score);
    if (scoreComparison != 0) return scoreComparison;

    final int distanceComparison = _compareDistances(a.model, b.model);
    if (distanceComparison != 0) return distanceComparison;

    return a.model.name.compareTo(b.model.name);
  });

  return scoredModels.map((scoredModel) => scoredModel.model).toList();
}

String _normalizeText(String? text) {
  if (text == null || text.isEmpty) return '';

  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

int? _scoreModel(DiningModel model, List<String> queryTokens) {
  final List<_SearchField> searchFields = _buildSearchFields(model);
  int score = 0;

  for (final String queryToken in queryTokens) {
    int tokenScore = 0;

    for (final _SearchField searchField in searchFields) {
      if (_containsTokenPrefix(searchField.text, queryToken)) {
        tokenScore = tokenScore < searchField.weight ? searchField.weight : tokenScore;
      }
    }

    if (tokenScore == 0) return null;
    score += tokenScore;
  }

  if (_containsPhrase(searchFields, queryTokens)) score += 1;
  return score;
}

List<_SearchField> _buildSearchFields(DiningModel model) => [
  _SearchField(_normalizeText(model.name), _nameWeight),
  _SearchField(_normalizeText([...model.paymentOptions, model.paymentFilterTypes].join(' ')), _paymentOptionsWeight),
  _SearchField(_normalizeText(model.specialHours?.specialHoursEvent), _specialTitleWeight),
  _SearchField(_normalizeText(model.specials?.specialTitle), _specialTitleWeight),
  _SearchField(_normalizeText(model.location), _locationWeight),
  _SearchField(_normalizeText(model.address), _locationWeight),
  _SearchField(_normalizeText(model.meals == null ? null : mealsValues.reverse[model.meals!]), _descriptionWeight),
  _SearchField(_normalizeText(model.description), _descriptionWeight),
  _SearchField(_normalizeText(model.specialHours?.specialHoursEventDetails), _descriptionWeight),
  _SearchField(_normalizeText(model.specials?.specialDescription), _descriptionWeight),
];

bool _containsTokenPrefix(String fieldText, String queryToken) {
  if (fieldText.isEmpty) return false;

  for (final String fieldToken in fieldText.split(' ')) {
    if (fieldToken.startsWith(queryToken)) return true;
  }
  return false;
}

bool _containsPhrase(List<_SearchField> searchFields, List<String> queryTokens) {
  for (final _SearchField searchField in searchFields) {
    final List<String> fieldTokens = searchField.text.split(' ');
    for (int start = 0; start + queryTokens.length <= fieldTokens.length; start++) {
      bool matches = true;

      for (int offset = 0; offset < queryTokens.length; offset++) {
        if (fieldTokens[start + offset] != queryTokens[offset]) {
          matches = false;
          break;
        }
      }

      if (matches) return true;
    }
  }
  return false;
}

int _compareDistances(DiningModel a, DiningModel b) {
  final bool aHasDistance = a.distance != null;
  final bool bHasDistance = b.distance != null;

  if (aHasDistance && bHasDistance) return a.distance!.compareTo(b.distance!);
  if (aHasDistance) return -1;
  if (bHasDistance) return 1;
  return 0;
}

class _ScoredDiningModel {
  const _ScoredDiningModel(this.model, this.score);

  final DiningModel model;
  final int score;
}

class _SearchField {
  const _SearchField(this.text, this.weight);

  final String text;
  final int weight;
}
