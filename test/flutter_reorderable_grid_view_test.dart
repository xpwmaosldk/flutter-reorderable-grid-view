import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/flutter_reorderable_grid_view.dart';
import 'package:flutter_reorderable_grid_view/widgets/animated_draggable_item.dart';
import 'package:flutter_reorderable_grid_view/widgets/draggable_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'GIVEN children '
      'WHEN pumping [FlutterReorderableGridView] '
      'THEN should show expected widgets and have default values',
      (WidgetTester tester) async {
    // given
    const givenChildren = <Widget>[
      Text('hallo1'),
      Text('hallo2'),
      Text('hallo3'),
      Text('hallo4'),
    ];

    // when
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
          ),
        ),
      ),
    );

    // then
    const expectedSpacing = 8;
    const expectedRunSpacing = 8;

    expect(find.byWidget(givenChildren[0]), findsOneWidget);
    expect(find.byWidget(givenChildren[1]), findsOneWidget);
    expect(find.byWidget(givenChildren[2]), findsOneWidget);
    expect(find.byWidget(givenChildren[3]), findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is FlutterReorderableGridView &&
            widget.enableLongPress &&
            widget.enableAnimation &&
            widget.spacing == expectedSpacing &&
            widget.runSpacing == expectedRunSpacing),
        findsOneWidget);

    expect(
        find.byWidgetPredicate(
            (widget) => widget is DraggableItem && widget.enableLongPress),
        findsNWidgets(givenChildren.length));

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Wrap &&
            widget.runSpacing == expectedRunSpacing &&
            widget.spacing == expectedSpacing),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN children, enableLongPress = false, spacing = 24.0 and runSpacing 20.0 '
      'WHEN pumping [FlutterReorderableGridView] '
      'THEN should show expected widgets and have default values',
      (WidgetTester tester) async {
    // given
    const givenChildren = <Widget>[
      Text('hallo1'),
      Text('hallo2'),
      Text('hallo3'),
      Text('hallo4'),
    ];
    const givenRunSpacing = 20.0;
    const givenSpacing = 24.0;

    // when
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
            enableLongPress: false,
            enableAnimation: false,
            runSpacing: givenRunSpacing,
            spacing: givenSpacing,
          ),
        ),
      ),
    );

    // then
    expect(find.byWidget(givenChildren[0]), findsOneWidget);
    expect(find.byWidget(givenChildren[1]), findsOneWidget);
    expect(find.byWidget(givenChildren[2]), findsOneWidget);
    expect(find.byWidget(givenChildren[3]), findsOneWidget);

    expect(
        find.byWidgetPredicate(
            (widget) => widget is DraggableItem && !widget.enableLongPress),
        findsNWidgets(givenChildren.length));

    expect(
        find.byWidgetPredicate((widget) =>
            widget is FlutterReorderableGridView &&
            !widget.enableLongPress &&
            !widget.enableAnimation &&
            widget.spacing == givenSpacing &&
            widget.runSpacing == givenRunSpacing),
        findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is Wrap &&
            widget.runSpacing == givenRunSpacing &&
            widget.spacing == givenSpacing),
        findsOneWidget);
  });

  testWidgets(
      'GIVEN children '
      'WHEN pumping [FlutterReorderableGridView] finished '
      'THEN should show expected widgets and have default values',
      (WidgetTester tester) async {
    // given
    const givenChildren = <Widget>[
      Text('hallo1'),
      Text('hallo2'),
      Text('hallo3'),
      Text('hallo4'),
    ];
    const givenRunSpacing = 20.0;
    const givenSpacing = 24.0;

    // when
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
            enableLongPress: false,
            enableAnimation: false,
            runSpacing: givenRunSpacing,
            spacing: givenSpacing,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // then
    expect(find.byWidget(givenChildren[0]), findsOneWidget);
    expect(find.byWidget(givenChildren[1]), findsOneWidget);
    expect(find.byWidget(givenChildren[2]), findsOneWidget);
    expect(find.byWidget(givenChildren[3]), findsOneWidget);

    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedDraggableItem &&
            !widget.enableLongPress &&
            !widget.enableAnimation),
        findsNWidgets(givenChildren.length));
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedDraggableItem && widget.key == const Key('0')),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedDraggableItem && widget.key == const Key('1')),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedDraggableItem && widget.key == const Key('2')),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((widget) =>
            widget is AnimatedDraggableItem && widget.key == const Key('3')),
        findsOneWidget);

    expect(find.byType(Wrap), findsNothing);
  });

  testWidgets(
      'GIVEN pumped [FlutterReorderableGridView] with enableLongPress = false '
      'WHEN dragging text1 to text2 without releasing drag '
      'THEN should change swap position between text1 and text2',
      (WidgetTester tester) async {
    // given
    const givenText1 = 'hallo1';
    const givenText2 = 'hallo2';
    const givenText3 = 'hallo3';
    const givenText4 = 'hallo4';

    const givenChildren = <Widget>[
      Text(givenText1),
      Text(givenText2),
      Text(givenText3),
      Text(givenText4),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
            enableLongPress: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    // start dragging
    final firstLocation = tester.getCenter(find.text(givenText1));
    final gesture = await tester.startGesture(
      firstLocation,
      pointer: 7,
    );
    await tester.pump();

    // move dragged object
    final secondLocation = tester.getCenter(find.text(givenText2));
    await gesture.moveTo(secondLocation);
    await tester.pumpAndSettle();

    // then
    expect(tester.getCenter(find.text(givenText1)), equals(secondLocation));
    expect(tester.getCenter(find.text(givenText2)), equals(firstLocation));
  });

  testWidgets(
      'GIVEN pumped [FlutterReorderableGridView] with enableLongPress = false '
      'WHEN dragging text1 to text4 without releasing drag '
      'THEN should change swap position of all given texts',
      (WidgetTester tester) async {
    // given
    const givenText1 = 'hallo1';
    const givenText2 = 'hallo2';
    const givenText3 = 'hallo3';
    const givenText4 = 'hallo4';

    const givenChildren = <Widget>[
      Text(givenText1),
      Text(givenText2),
      Text(givenText3),
      Text(givenText4),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
            enableLongPress: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    // start dragging
    final givenText1StartLocation = tester.getCenter(find.text(givenText1));
    final givenText2StartLocation = tester.getCenter(find.text(givenText2));
    final givenText3StartLocation = tester.getCenter(find.text(givenText3));
    final givenText4StartLocation = tester.getCenter(find.text(givenText4));

    final gesture = await tester.startGesture(
      givenText1StartLocation,
      pointer: 7,
    );
    await tester.pump();

    // move dragged object
    await gesture.moveTo(givenText4StartLocation);
    await tester.pumpAndSettle();

    // then
    final givenText1EndLocation = tester.getCenter(find.text(givenText1));
    final givenText2EndLocation = tester.getCenter(find.text(givenText2));
    final givenText3EndLocation = tester.getCenter(find.text(givenText3));
    final givenText4EndLocation = tester.getCenter(find.text(givenText4));

    expect(givenText1EndLocation, equals(givenText4StartLocation));
    expect(givenText2EndLocation, equals(givenText1StartLocation));
    expect(givenText3EndLocation, equals(givenText2StartLocation));
    expect(givenText4EndLocation, equals(givenText3StartLocation));
  });

  testWidgets(
      'GIVEN pumped [FlutterReorderableGridView] with enableLongPress = false '
      'WHEN dragging text4 to text2 without releasing drag '
      'THEN should change swap position of all given texts',
      (WidgetTester tester) async {
    // given
    const givenText1 = 'hallo1';
    const givenText2 = 'hallo2';
    const givenText3 = 'hallo3';
    const givenText4 = 'hallo4';

    const givenChildren = <Widget>[
      Text(givenText1),
      Text(givenText2),
      Text(givenText3),
      Text(givenText4),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FlutterReorderableGridView(
            children: givenChildren,
            enableLongPress: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // when
    // start dragging
    final givenText1StartLocation = tester.getCenter(find.text(givenText1));
    final givenText2StartLocation = tester.getCenter(find.text(givenText2));
    final givenText3StartLocation = tester.getCenter(find.text(givenText3));
    final givenText4StartLocation = tester.getCenter(find.text(givenText4));

    final gesture = await tester.startGesture(
      givenText4StartLocation,
      pointer: 7,
    );
    await tester.pump();

    // move dragged object
    await gesture.moveTo(givenText2StartLocation);
    await tester.pumpAndSettle();

    // then
    final givenText1EndLocation = tester.getCenter(find.text(givenText1));
    final givenText2EndLocation = tester.getCenter(find.text(givenText2));
    final givenText3EndLocation = tester.getCenter(find.text(givenText3));
    final givenText4EndLocation = tester.getCenter(find.text(givenText4));

    expect(givenText1EndLocation, equals(givenText1StartLocation));
    expect(givenText2EndLocation, equals(givenText3StartLocation));
    expect(givenText3EndLocation, equals(givenText4StartLocation));
    expect(givenText4EndLocation, equals(givenText2StartLocation));
  });
}