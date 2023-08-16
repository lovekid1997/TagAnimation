import 'package:flutter/material.dart';
import 'package:tag_animation/tag_animation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var tagAnimationController = TagAnimationController();
  @override
  void initState() {
    tagAnimationController.onAddAll(
      builder: (index) {
        var tagName = 'tagName$index';
        return TagWrapper(
          tagName: tagName,
          rawChip: RawChip(
            label: Text(tagName),
            onPressed: () {
              var tagName2 = '$tagName${UniqueKey()}';
              tagAnimationController.onAdd(
                TagWrapper(
                  tagName: tagName2,
                  rawChip: RawChip(
                    label: Text(tagName2),
                    onDeleted: () {
                      tagAnimationController.onDelete(tagName2);
                    },
                  ),
                ),
              );
            },
            onDeleted: () {
              tagAnimationController.onDelete(tagName);
            },
          ),
        );
      },
      itemCount: 3,
    );
    super.initState();
  }

  TagWrapper _test(String tagName) {
    return TagWrapper(
      tagName: tagName,
      rawChip: RawChip(
        label: Text(tagName),
        onPressed: () {
          var tagName2 = '$tagName${UniqueKey()}';
          tagAnimationController.onAdd(
            TagWrapper(
              tagName: tagName2,
              rawChip: RawChip(
                label: Text(tagName2),
                onDeleted: () {
                  tagAnimationController.onDelete(tagName2);
                },
              ),
            ),
          );
        },
        onDeleted: () {
          tagAnimationController.onDelete(tagName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TagAnimation(
            controller: tagAnimationController,
            height: 50.0,
            animationType: TagAnimationType.transition,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  tagAnimationController.onAdd(_test('on Add'));
                },
                child: const Text('onAdd'),
              ),
              TextButton(
                onPressed: () {
                  tagAnimationController.onInsert(_test('on Insert'), 0);
                },
                child: const Text('onInsert'),
              ),
              TextButton(
                onPressed: () {
                  tagAnimationController.onDeleteMulti(['on Add', 'on Insert']);
                },
                child: const Text('onDeleteMulti'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
