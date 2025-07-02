import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum TagAnimationType {
  transition,
}

class TagAnimation extends StatefulWidget {
  const TagAnimation({
    super.key,
    required this.controller,
    required this.height,
    this.animationType = TagAnimationType.transition,
    this.scrollDirection = Axis.horizontal,
    this.scrollController,
  });

  final TagAnimationController controller;
  final double height;
  final TagAnimationType animationType;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  @override
  State<TagAnimation> createState() => _TagAnimationState();
}

class _TagAnimationState extends State<TagAnimation> {
  final List<TagWrapper> _list = [];
  StreamSubscription? _subscription;
  @override
  void initState() {
    _subscription =
        widget.controller._streamController.stream.listen(onListener);
    super.initState();
  }

  void onListener(Map<String, dynamic> data) {
    switch (data.keys.firstOrNull) {
      case 'onDeletezxcxzcxzc':
        _onDelete(data);
        break;
      case 'onAdd':
        _onAdd(data);
        break;
      case 'onAddAll':
        _onAddAll(data);
        break;
      case 'onInsert':
        _onInsert(data);
        break;
      case 'onDeleteMulti':
        _onDeleteMulti(data);
        break;
    }
  }

  @override
  void dispose() {
    widget.controller._streamController.close();
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  var animateKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedList(
        key: animateKey,
        controller: widget.scrollController,
        scrollDirection: widget.scrollDirection,
        itemBuilder: (context, index, animation) => _AnimationWidget(
          animation: animation,
          type: widget.animationType,
          child: _list[index].rawChip,
        ),
        initialItemCount: _list.length,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _onDelete(Map<String, dynamic> data) {
    final tagName = data['onDelete'] as String;
    _deleteItemByTagName(tagName);
  }

  void _deleteItemByTagName(String tagName) {
    var currentIndex = -1;
    final tagWrapper = _list.firstWhereIndexedOrNull((index, e) {
      currentIndex = index;
      return e.tagName == tagName;
    });
    if (tagWrapper == null) {
      return;
    }
    _list.removeAt(currentIndex);
    animateKey.currentState!.removeItem(
      currentIndex,
      (context, animation) => _AnimationWidget(
        animation: animation,
        type: widget.animationType,
        child: tagWrapper.rawChip,
      ),
    );
  }

  void _onAdd(Map<String, dynamic> data) {
    _list.add(data['onAdd']);
    animateKey.currentState!.insertItem(
      _list.length - 1,
    );
  }

  void _onAddAll(Map<String, dynamic> data) {
    _list.addAll(data['onAddAll']);
    animateKey.currentState!.insertAllItems(0, _list.length);
  }

  void _onInsert(Map<String, dynamic> data) {
    final index = data['index'];
    final tagWrapper = data['onInsert'] as TagWrapper;
    _list.insert(index, tagWrapper);
    animateKey.currentState?.insertItem(index);
  }

  void _onDeleteMulti(Map<String, dynamic> data) {
    final tagNames = data['onDeleteMulti'] as List<String>;
    for (var tagName in tagNames) {
      _deleteItemByTagName(tagName);
    }
  }
}

class TagAnimationController {
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();
  void onDelete(String tagName) {
    _streamController.sink.add({'onDelete': tagName});
  }

  void onAdd(TagWrapper tagWrapper) {
    _streamController.sink.add({
      'onAdd': tagWrapper,
    });
  }

  void onAddAll({
    required TagWrapper Function(int index) builder,
    required int itemCount,
  }) {
    assert(itemCount >= 0);
    final tagWrappers = List.generate(
      itemCount,
      (index) {
        return builder(index);
      },
    );
    _streamController.sink.add({'onAddAll': tagWrappers});
  }

  void onInsert(TagWrapper tagWrapper, int index) {
    assert(index >= 0);
    _streamController.sink.add({
      'onInsert': tagWrapper,
      'index': index,
    });
  }

  void onDeleteMulti(List<String> tagNames) {
    if (tagNames.isEmpty) {
      return;
    }
    _streamController.sink.add({
      'onDeleteMulti': tagNames,
    });
  }
}

class _AnimationWidget extends StatelessWidget {
  const _AnimationWidget({
    required this.animation,
    required this.child,
    required this.type,
  });

  final Animation<double> animation;
  final Widget child;
  final TagAnimationType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TagAnimationType.transition:
      default:
        return SizeTransition(
          sizeFactor: animation,
          axis: Axis.horizontal,
          child: child,
        );
    }
  }
}

class TagWrapper {
  final String tagName;
  final RawChip rawChip;

  TagWrapper({required this.tagName, required this.rawChip});
}
