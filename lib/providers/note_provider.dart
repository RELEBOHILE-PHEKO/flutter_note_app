import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/note.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class NoteProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Note>>? _notesSubscription;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get notesCount => _notes.length;
  bool get hasNotes => _notes.isNotEmpty;

  NoteProvider() {
    _initializeNotes();
  }

  void _initializeNotes() {
    final user = _authService.currentUser;
    if (user != null) {
      loadNotes();
    }
  }

  void loadNotes() {
    final user = _authService.currentUser;
    if (user == null) {
      _setError('User not authenticated');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _notesSubscription?.cancel();
      _notesSubscription = _firestoreService.getNotes(user.uid).listen(
            (fetchedNotes) {
          _notes = fetchedNotes
            ..sort((a, b) => (b.createdAt ?? DateTime.now())
                .compareTo(a.createdAt ?? DateTime.now()));
          _setLoading(false);
        },
        onError: (error) {
          _setError('Failed to load notes: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Failed to initialize notes stream: $e');
      _setLoading(false);
    }
  }

  Future<void> refreshNotes() async {
    loadNotes();
  }

  Future<void> addNote(String text, {List<String> tags = const []}) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    if (text.trim().isEmpty) throw Exception('Note text cannot be empty');
    _clearError();

    try {
      await _firestoreService.addNote(text.trim(), user.uid, tags);
    } catch (e) {
      _setError('Failed to add note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(String id, String text, {List<String> tags = const []}) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    if (text.trim().isEmpty) throw Exception('Note text cannot be empty');
    _clearError();

    try {
      await _firestoreService.updateNote(id, text.trim(), tags: tags);
    } catch (e) {
      _setError('Failed to update note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    _clearError();

    try {
      await _firestoreService.deleteNote(id);
    } catch (e) {
      _setError('Failed to delete note: $e');
      rethrow;
    }
  }

  Future<Note?> getNote(String id) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception('User not authenticated');
    _clearError();

    try {
      return await _firestoreService.getNote(id);
    } catch (e) {
      _setError('Failed to get note: $e');
      rethrow;
    }
  }

  Future<bool> noteExists(String id) async {
    try {
      return await _firestoreService.noteExists(id);
    } catch (_) {
      return false;
    }
  }

  // 🔍 Search and Filter
  List<Note> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _notes
        .where((note) => note.text.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<Note> filterByTag(String tag) {
    return _notes.where((note) => note.tags.contains(tag)).toList();
  }

  void clearNotes() {
    _notesSubscription?.cancel();
    _notes.clear();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}
