
import 'dart:collection';
import 'dart:core';

import 'package:correctink/app/data/models/schemas.dart';

extension FlashcardComparator on Flashcard {
  int compareTo(Flashcard b) {
    return id.hexString.compareTo(b.id.hexString);
  }

  bool compareASC(Flashcard b) {
    return compareTo(b) < 0;
  }
}

class OrderedFlashcards extends SetBase<Flashcard> {
  // use a list to have [index], but the values are all unique like in a set
  final List<Flashcard> _list = [];

  static OrderedFlashcards fromList(List<Flashcard> list) {
    final newOrderedSet = OrderedFlashcards();
    list.forEach((element) {newOrderedSet.add(element);});
    return newOrderedSet;
  }

  OrderedFlashcards copy() {
    return fromList(_list);
  }

  Flashcard operator [](int index) {
    return _list[index];
  }

  @override
  void forEach(Function(Flashcard) f) {
    for(int i = 0; i < _list.length; ++i) {
      f(_list[i]);
    }
  }

  @override
  void clear() {
    _list.clear();
  }

  @override
  bool get isEmpty => _list.isEmpty;

  @override
  bool get isNotEmpty => _list.isNotEmpty;

  /// Add the element if not in the set, otherwise remove it
  void toggle(Flashcard value) {
    for(int i = 0; i < _list.length; ++i) {
      Flashcard currentValue = _list[i];
      if(value.compareASC(currentValue)) {
        continue;
      } else if(value.id.hexString == currentValue.id.hexString) {
        _list.removeAt(i);
        return;
      }
      _list.insert(i, value);
      return;
    }
    _list.add(value);
  }

  @override
  bool add(Flashcard value) {
    for(int i = 0; i < _list.length; ++i) {
      Flashcard currentValue = _list[i];
      if(value.compareASC(currentValue)) {
        continue;
      } else if(value.id.hexString == currentValue.id.hexString) {
        return false;
      }
      _list.insert(i, value);
      return true;
    }
    _list.add(value);
    return true;
  }

  @override
  bool contains(Object? element) {
    return lookup(element) != null;
  }

  @override
  Iterator<Flashcard> get iterator => _list.iterator;

  @override
  int get length => _list.length;

  @override
  Flashcard? lookup(Object? element) {
    if(element == null) {
      return null;
    }
    Flashcard value = element as Flashcard;
    for(int i = 0; i < _list.length; ++i) {
      Flashcard currentValue = _list[i];
      if(value.compareASC(currentValue)) {
        continue;
      } else if(value.id.hexString == currentValue.id.hexString) {
        return value;
      }
      return null;
    }
    return null;
  }

  @override
  bool remove(Object? value) {
    if(value == null) {
      return false;
    }
    Flashcard newValue = value as Flashcard;
    for(int i = 0; i < _list.length; ++i) {
      Flashcard currentValue = _list[i];
      if(value.compareASC(currentValue)) {
        continue;
      } else if(newValue.id.hexString == currentValue.id.hexString) {
        _list.removeAt(i);
        return true;
      }
      return false;
    }
    return false;
  }

  @override
  Set<Flashcard> toSet() {
    return _list.toSet();
  }
}