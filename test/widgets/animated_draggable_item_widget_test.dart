import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/reorderable_grid_view_builder.dart';
import '../services/widget_test_helper.dart';

void main() {
  final builder = ReorderableGridViewBuilder();

  testWidgets(
      'GIVEN enableAnimation = false, enableLongPress = false and entry '
      'WHEN pumping [AnimatedDraggableItem] '
      'THEN should show expected widgets, have expected values and should not '
      'call onRemoveItem', (WidgetTester tester) async {
    // given
    const givenEnableAnimation = false;
    const givenEnableLongPress = false;
    final givenEntry = MapEntry(0, builder.getGridItemEntity());
    const givenChild = UniqueTestWidget();

    int? expectedKey;

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AnimatedDraggableItem(
                child: givenChild,
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                entry: givenEntry,
                onRemoveItem: (int key) {
                  expectedKey = key;
                },
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Positioned &&
            widget.top == givenEntry.value.localPosition.dy &&
            widget.left == givenEntry.value.localPosition.dx &&
            widget.width == givenEntry.value.size.width &&
            widget.height == givenEntry.value.size.height),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DraggableItem &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).child == givenChild &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.id == givenEntry.key &&
            widget.longPressDelay == kLongPressTimeout &&
            widget.enabled),
        findsOneWidget);
    expect(expectedKey, isNull);
  });

  testWidgets(
      'GIVEN enableAnimation = true, enableLongPress = true, enabled = false, '
      'and entry '
      'WHEN pumping [AnimatedDraggableItem] '
      'THEN should show expected widgets and have expected values',
      (WidgetTester tester) async {
    // given
    const givenEnableAnimation = true;
    const givenEnableLongPress = true;
    const givenEnabled = false;
    const givenLongPressDelay = Duration(seconds: 100);
    final givenEntry = MapEntry(0, builder.getGridItemEntity());
    const givenChild = UniqueTestWidget();

    // when
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              AnimatedDraggableItem(
                child: givenChild,
                enableAnimation: givenEnableAnimation,
                enableLongPress: givenEnableLongPress,
                entry: givenEntry,
                enabled: givenEnabled,
                longPressDelay: givenLongPressDelay,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // then
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedPositioned &&
            widget.top == givenEntry.value.localPosition.dy &&
            widget.left == givenEntry.value.localPosition.dx &&
            widget.width == givenEntry.value.size.width &&
            widget.height == givenEntry.value.size.height),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DraggableItem &&
            widget.child is SizedBox &&
            (widget.child as SizedBox).child == givenChild &&
            widget.enableLongPress == givenEnableLongPress &&
            widget.id == givenEntry.key &&
            widget.longPressDelay == givenLongPressDelay &&
            !widget.enabled),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN [AnimatedDraggableItem] '
      'WHEN dragging '
      'THEN should call onDragUpdate', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenEnableAnimation = true;
    const givenText = 'hallo';
    const givenChild = Text(givenText);
    final givenEntry = MapEntry(
      0,
      builder.getGridItemEntity(
        size: const Size(100, 100),
      ),
    );

    Offset? expectedPosition;
    Size? expectedSize;
    int? expectedId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: Stack(
              children: [
                AnimatedDraggableItem(
                  child: givenChild,
                  enableAnimation: givenEnableAnimation,
                  enableLongPress: givenEnableLongPress,
                  entry: givenEntry,
                  onDragUpdate: (
                    int id,
                    Offset position,
                    Size size,
                  ) {
                    expectedPosition = position;
                    expectedId = id;
                    expectedSize = size;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    // start dragging
    final gesture = await tester.startGesture(
      tester.getCenter(find.text(givenText)),
      pointer: 7,
    );
    await tester.pump();

    // move dragged object
    await gesture.moveTo(const Offset(200, 200));
    await tester.pumpAndSettle();

    // then
    expect(expectedPosition, isNotNull);
    expect(expectedSize, isNotNull);
    expect(expectedId, equals(givenEntry.key));
  });

  testWidgets(
      'GIVEN [AnimatedDraggableItem] and willBeRemoved = true '
      'WHEN item was loaded '
      'THEN should call onRemoveItem', (WidgetTester tester) async {
    // given
    const givenEnableLongPress = false;
    const givenEnableAnimation = true;
    const givenText = 'hallo';
    const givenChild = Text(givenText);
    final givenEntry = MapEntry(
      0,
      builder.getGridItemEntity(
        size: const Size(100, 100),
      ),
    );

    int? expectedKey;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1000,
            width: 1000,
            child: Stack(
              children: [
                AnimatedDraggableItem(
                  child: givenChild,
                  enableAnimation: givenEnableAnimation,
                  enableLongPress: givenEnableLongPress,
                  entry: givenEntry,
                  willBeRemoved: true,
                  onRemoveItem: (int key) {
                    expectedKey = key;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // when
    await tester.pumpAndSettle();

    // then
    expect(expectedKey, equals(givenEntry.key));
  });
}
