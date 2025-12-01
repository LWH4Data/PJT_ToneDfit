import 'package:flutter/material.dart';
import '../services/recent_search_service.dart';

class RecentSearchController extends ChangeNotifier {
  RecentSearchController(this._service);
  final RecentSearchService _service;

  final int _max = 30;
  List<String> _items = <String>[];
  List<String> get items => _items;

  Future<void> init() async {
    _items = await _service.load();
    notifyListeners();
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _items.remove(q);
    _items.insert(0, q);
    if (_items.length > _max) {
      _items = _items.sublist(0, _max);
    }
    await _service.save(_items);
    notifyListeners();
  }

  Future<void> remove(String query) async {
    _items.remove(query);
    await _service.save(_items);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _service.save(_items);
    notifyListeners();
  }
}


