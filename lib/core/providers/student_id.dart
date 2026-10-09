import 'dart:async';
import 'dart:ui' as ui;
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_photo.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/user.dart';
import 'package:campus_mobile_experimental/core/services/student_id.dart';
import 'package:flutter/material.dart';

class StudentIdDataProvider extends ChangeNotifier {
  StudentIdDataProvider({StudentIdService? service}) : _studentIdService = service ?? StudentIdService();

  static const _apiDeadline = Duration(seconds: 60);
  static const _imageDeadline = Duration(seconds: 30);
  final StudentIdService _studentIdService;
  final _name = _StudentIdRequest();
  final _profile = _StudentIdRequest();
  final _photoMetadata = _StudentIdRequest();
  final _image = _StudentIdRequest();
  StudentIdNameModel _studentIdNameModel = StudentIdNameModel();
  StudentIdPhotoModel _studentIdPhotoModel = StudentIdPhotoModel();
  StudentIdProfileModel _studentIdProfileModel = StudentIdProfileModel();
  ui.Image? _studentPhoto;
  UserDataProvider? _userDataProvider;
  (String?, String)? _session;
  int _sessionId = 0;
  bool _disposed = false;
  DateTime? _lastUpdated;

  (String?, String)? get _authenticatedSession {
    final user = _userDataProvider;
    final token = user?.authenticationModel.accessToken;
    if (user == null || !user.isLoggedIn || token == null || token.isEmpty) return null;
    return (user.authenticationModel.pid, token);
  }

  set userDataProvider(UserDataProvider value) {
    if (!identical(value, _userDataProvider)) {
      _userDataProvider?.removeListener(_onUserChanged);
      _userDataProvider = value;
      value.addListener(_onUserChanged);
    }
    _onUserChanged();
  }

  void _onUserChanged() {
    if (_disposed) return;
    final session = _authenticatedSession;
    if (session == _session) return;
    // A token change supersedes attempts too. Retain content only for a known,
    // unchanged user; signing out or switching users clears all retained data.
    final sameUser = session != null && _session != null && session.$1 != null && session.$1 == _session!.$1;
    _session = session;
    _sessionId++;
    for (final section in [_name, _profile, _photoMetadata, _image]) {
      section.invalidate();
    }
    if (!sameUser) {
      _studentIdNameModel = StudentIdNameModel();
      _studentIdPhotoModel = StudentIdPhotoModel();
      _studentIdProfileModel = StudentIdProfileModel();
      _studentPhoto?.dispose();
      _studentPhoto = null;
      _lastUpdated = null;
    }
    if (session != null) {
      _refreshAll();
    } else {
      notifyListeners();
    }
  }

  bool _isCurrent(_StudentIdRequest section, int attempt, int session) {
    if (_disposed) return false;
    _onUserChanged();
    return session == _sessionId && section.attempt == attempt && section.loading;
  }

  /// Reload unavailable/failed verification sections. Optional academic fields
  /// do not trigger retries. Every start sets its pending flag synchronously.
  void fetchData() {
    _onUserChanged();
    if (_disposed || _session == null) return;
    final retryName = !hasName || _name.error != null;
    final retryProfile = !hasBarcode || _profile.error != null;
    final retryPhoto = !hasPhoto || _photoMetadata.error != null || _image.error != null;
    if (!retryName && !retryProfile && !retryPhoto) {
      if (!hasPendingWork) _refreshAll();
      return;
    }
    if (retryProfile) _startProfile();
    if (retryName) _startName();
    if (retryPhoto && !isPhotoLoading) {
      if (_studentIdPhotoModel.photoUrl.isEmpty || _photoMetadata.error != null) {
        _startPhotoMetadata();
      } else {
        _startImage(_studentIdPhotoModel.photoUrl, refetchOnFailure: true);
      }
    }
    notifyListeners();
  }

  void _refreshAll() {
    _startProfile();
    _startName();
    if (!isPhotoLoading) _startPhotoMetadata();
    notifyListeners();
  }

  Map<String, String> get _headers => {'Authorization': 'Bearer ${_session!.$2}'};

  void _startName() {
    if (_name.loading) return;
    unawaited(
      _loadApi<StudentIdNameModel>(_name, () => _studentIdService.fetchStudentIdName(_headers), (replacement) {
        _studentIdNameModel = _studentIdNameModel.mergeValid(replacement);
        return replacement.displayName.isNotEmpty;
      }),
    );
  }

  void _startProfile() {
    if (_profile.loading) return;
    unawaited(
      _loadApi<StudentIdProfileModel>(_profile, () => _studentIdService.fetchStudentIdProfile(_headers), (replacement) {
        _studentIdProfileModel = _studentIdProfileModel.mergeValid(replacement);
        return replacement.barcode.isNotEmpty;
      }),
    );
  }

  void _startPhotoMetadata() {
    if (isPhotoLoading) return;
    unawaited(
      _loadApi<StudentIdPhotoModel>(_photoMetadata, () => _studentIdService.fetchStudentIdPhoto(_headers), (
        replacement,
      ) {
        if (replacement.photoUrl.isEmpty) return false;
        _studentIdPhotoModel = replacement;
        _startImage(replacement.photoUrl);
        return true;
      }),
    );
  }

  Future<void> _loadApi<T>(_StudentIdRequest section, Future<T> Function() fetch, bool Function(T) merge) async {
    final attempt = section.start();
    final session = _sessionId;
    try {
      final replacement = await Future<T>.sync(fetch).timeout(_apiDeadline);
      if (!_isCurrent(section, attempt, session)) return;
      if (!merge(replacement)) section.error = 'Verification content unavailable';
    } catch (error) {
      if (!_isCurrent(section, attempt, session)) return;
      section.error = error.toString();
    } finally {
      if (_isCurrent(section, attempt, session)) {
        section.loading = false;
        _lastUpdated = DateTime.now();
        notifyListeners();
      }
    }
  }

  void _startImage(String url, {bool refetchOnFailure = false}) {
    if (_image.loading) return;
    unawaited(_loadImage(url, refetchOnFailure: refetchOnFailure));
  }

  Future<void> _loadImage(String url, {required bool refetchOnFailure}) async {
    final attempt = _image.start();
    final session = _sessionId;
    try {
      final image = await Future<ui.Image>.sync(() => _studentIdService.fetchStudentIdImage(url))
          .then((image) {
            // The underlying download/codec can finish after the overall deadline.
            // Dispose its result instead of accepting it into an expired session.
            if (!_isCurrent(_image, attempt, session)) {
              image.dispose();
              throw StateError('Expired Student ID photo attempt');
            }
            return image;
          })
          .timeout(_imageDeadline);
      if (!_isCurrent(_image, attempt, session)) {
        image.dispose();
        return;
      }
      _studentPhoto?.dispose();
      _studentPhoto = image;
    } catch (error) {
      if (!_isCurrent(_image, attempt, session)) return;
      _image.error = error.toString();
    } finally {
      if (_isCurrent(_image, attempt, session)) {
        _image.loading = false;
        _lastUpdated = DateTime.now();
        // An existing URL gets one fresh attempt on Reload. If it still fails,
        // ask /photo for a new URL within the same recovery action.
        if (_image.error != null && refetchOnFailure) _startPhotoMetadata();
        notifyListeners();
      }
    }
  }

  bool get hasName => _studentIdNameModel.displayName.isNotEmpty;
  bool get hasBarcode => _studentIdProfileModel.barcode.isNotEmpty;
  bool get hasPhoto => _studentPhoto != null;
  bool get hasUsableContent => hasBarcode || hasName || hasPhoto;
  bool get hasPendingWork => _name.loading || _profile.loading || isPhotoLoading;
  bool get isNameLoading => _name.loading;
  bool get isProfileLoading => _profile.loading;
  bool get isPhotoMetadataLoading => _photoMetadata.loading;
  bool get isImageLoading => _image.loading;
  bool get isPhotoLoading => _photoMetadata.loading || _image.loading;
  bool get isLoading => !hasUsableContent && hasPendingWork;
  String? get error => !hasUsableContent && !hasPendingWork ? 'An error occurred, please try again.' : null;
  String? get nameError => _name.error;
  String? get profileError => _profile.error;
  String? get photoMetadataError => _photoMetadata.error;
  String? get imageError => _image.error;
  DateTime? get lastUpdated => _lastUpdated;
  int get sessionId => _sessionId;
  StudentIdNameModel get studentIdNameModel => _studentIdNameModel;
  StudentIdPhotoModel get studentIdPhotoModel => _studentIdPhotoModel;
  StudentIdProfileModel get studentIdProfileModel => _studentIdProfileModel;
  ui.Image? get studentPhoto => _studentPhoto;

  @override
  void dispose() {
    _disposed = true;
    _userDataProvider?.removeListener(_onUserChanged);
    _studentPhoto?.dispose();
    super.dispose();
  }
}

class _StudentIdRequest {
  bool loading = false;
  String? error;
  int attempt = 0;

  int start() {
    loading = true;
    error = null;
    return ++attempt;
  }

  void invalidate() {
    attempt++;
    loading = false;
    error = null;
  }
}
