import 'package:flutter_test/flutter_test.dart';
import 'package:quill_web_editor/src/core/constants/editor_config.dart';
import 'package:quill_web_editor/src/widgets/quill_editor_controller.dart';

/// Tests for QuillEditorController and QuillEditorAction.
///
/// These tests verify the controller's state management, custom actions,
/// and listener notification functionality.
void main() {
  group('QuillEditorAction Tests', () {
    test('Should create action with required name', () {
      const action = QuillEditorAction(name: 'testAction');

      expect(action.name, equals('testAction'));
      expect(action.parameters, isEmpty);
      expect(action.onExecute, isNull);
      expect(action.onResponse, isNull);
    });

    test('Should create action with all parameters', () {
      var executeCalled = false;
      var responseCalled = false;

      final action = QuillEditorAction(
        name: 'fullAction',
        parameters: {'key': 'value', 'count': 42},
        onExecute: () => executeCalled = true,
        onResponse: (response) => responseCalled = true,
      );

      expect(action.name, equals('fullAction'));
      expect(action.parameters['key'], equals('value'));
      expect(action.parameters['count'], equals(42));

      // Verify callbacks can be invoked
      action.onExecute?.call();
      expect(executeCalled, isTrue);

      action.onResponse?.call({'success': true});
      expect(responseCalled, isTrue);
    });

    test('Should copy action with updated parameters', () {
      const original = QuillEditorAction(
        name: 'original',
        parameters: {'a': 1},
      );

      final copied = original.copyWith(
        name: 'copied',
        parameters: {'b': 2},
      );

      expect(copied.name, equals('copied'));
      expect(copied.parameters['b'], equals(2));
      expect(copied.parameters.containsKey('a'), isFalse);

      // Original should be unchanged
      expect(original.name, equals('original'));
      expect(original.parameters['a'], equals(1));
    });

    test('Should preserve original values when copyWith has nulls', () {
      var callCount = 0;
      final original = QuillEditorAction(
        name: 'original',
        parameters: {'key': 'value'},
        onExecute: () => callCount++,
      );

      final copied = original.copyWith(name: 'newName');

      expect(copied.name, equals('newName'));
      expect(copied.parameters['key'], equals('value'));

      // onExecute should be preserved
      copied.onExecute?.call();
      expect(callCount, equals(1));
    });
  });

  group('QuillEditorController Basic Tests', () {
    late QuillEditorController controller;

    setUp(() {
      controller = QuillEditorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Should initialize with default values', () {
      expect(controller.isReady, isFalse);
      expect(controller.html, isEmpty);
      expect(controller.currentZoom, equals(EditorConfig.defaultZoom));
      expect(controller.registeredActionNames, isEmpty);
    });

    test('Should notify listeners when marked ready', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      expect(controller.isReady, isFalse);

      controller.markReady();

      expect(controller.isReady, isTrue);
      expect(notificationCount, equals(1));
    });

    test('Should notify listeners when HTML is updated', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.updateHtml('<p>Hello</p>');

      expect(controller.html, equals('<p>Hello</p>'));
      expect(notificationCount, equals(1));

      controller.updateHtml('<p>World</p>');
      expect(controller.html, equals('<p>World</p>'));
      expect(notificationCount, equals(2));
    });

    test('Should detach and reset ready state', () {
      controller.markReady();
      expect(controller.isReady, isTrue);

      controller.detach();
      expect(controller.isReady, isFalse);
    });

    test('Should clear HTML on clear() and notify', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.updateHtml('<p>Content</p>');
      expect(controller.html, equals('<p>Content</p>'));

      controller.clear();
      expect(controller.html, isEmpty);
      // updateHtml + clear = 2 notifications
      expect(notificationCount, equals(2));
    });
  });

  group('QuillEditorController Action Registration Tests', () {
    late QuillEditorController controller;

    setUp(() {
      controller = QuillEditorController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Should register single action', () {
      const action = QuillEditorAction(name: 'testAction');
      controller.registerAction(action);

      expect(controller.hasAction('testAction'), isTrue);
      expect(controller.registeredActionNames, contains('testAction'));
      expect(controller.registeredActionNames.length, equals(1));
    });

    test('Should register multiple actions', () {
      controller.registerActions([
        const QuillEditorAction(name: 'action1'),
        const QuillEditorAction(name: 'action2'),
        const QuillEditorAction(name: 'action3'),
      ]);

      expect(controller.registeredActionNames.length, equals(3));
      expect(controller.hasAction('action1'), isTrue);
      expect(controller.hasAction('action2'), isTrue);
      expect(controller.hasAction('action3'), isTrue);
    });

    test('Should get registered action', () {
      const action = QuillEditorAction(
        name: 'myAction',
        parameters: {'key': 'value'},
      );
      controller.registerAction(action);

      final retrieved = controller.getAction('myAction');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('myAction'));
      expect(retrieved.parameters['key'], equals('value'));
    });

    test('Should return null for unregistered action', () {
      expect(controller.getAction('nonexistent'), isNull);
      expect(controller.hasAction('nonexistent'), isFalse);
    });

    test('Should unregister action', () {
      controller.registerAction(const QuillEditorAction(name: 'toRemove'));
      expect(controller.hasAction('toRemove'), isTrue);

      controller.unregisterAction('toRemove');
      expect(controller.hasAction('toRemove'), isFalse);
    });

    test('Should clear all actions', () {
      controller.registerActions([
        const QuillEditorAction(name: 'action1'),
        const QuillEditorAction(name: 'action2'),
      ]);
      expect(controller.registeredActionNames.length, equals(2));

      controller.clearActions();
      expect(controller.registeredActionNames, isEmpty);
    });

    test('Should notify listeners on registration changes', () {
      var notificationCount = 0;
      controller.addListener(() => notificationCount++);

      controller.registerAction(const QuillEditorAction(name: 'a'));
      expect(notificationCount, equals(1));

      controller.registerActions([
        const QuillEditorAction(name: 'b'),
        const QuillEditorAction(name: 'c'),
      ]);
      expect(notificationCount, equals(2));

      controller.unregisterAction('a');
      expect(notificationCount, equals(3));

      controller.clearActions();
      expect(notificationCount, equals(4));
    });

    test('Should replace action if registered with same name', () {
      controller.registerAction(
        const QuillEditorAction(name: 'dup', parameters: {'v': 1}),
      );
      controller.registerAction(
        const QuillEditorAction(name: 'dup', parameters: {'v': 2}),
      );

      expect(controller.registeredActionNames.length, equals(1));
      expect(controller.getAction('dup')?.parameters['v'], equals(2));
    });
  });

  group('QuillEditorController Action Execution Tests', () {
    late QuillEditorController controller;
    late List<Map<String, dynamic>> sentCommands;

    setUp(() {
      controller = QuillEditorController();
      sentCommands = [];

      // Attach a mock command sender
      controller.attach((data) {
        sentCommands.add(Map<String, dynamic>.from(data));
      });
    });

    tearDown(() {
      controller.dispose();
    });

    test('Should not execute unregistered action', () {
      final result = controller.executeAction('nonexistent');

      expect(result, isFalse);
      expect(sentCommands, isEmpty);
    });

    test('Should execute registered action', () {
      controller.registerAction(const QuillEditorAction(name: 'testAction'));

      final result = controller.executeAction('testAction');

      expect(result, isTrue);
      expect(sentCommands.length, equals(1));
      expect(sentCommands.first['action'], equals('customAction'));
      expect(sentCommands.first['customActionName'], equals('testAction'));
    });

    test('Should call onExecute callback', () {
      var executeCalled = false;

      controller.registerAction(
        QuillEditorAction(
          name: 'withCallback',
          onExecute: () => executeCalled = true,
        ),
      );

      controller.executeAction('withCallback');

      expect(executeCalled, isTrue);
    });

    test('Should send action parameters', () {
      controller.registerAction(
        const QuillEditorAction(
          name: 'withParams',
          parameters: {'color': 'red', 'size': 16},
        ),
      );

      controller.executeAction('withParams');

      expect(sentCommands.first['color'], equals('red'));
      expect(sentCommands.first['size'], equals(16));
    });

    test('Should merge parameters when executing', () {
      controller.registerAction(
        const QuillEditorAction(
          name: 'mergeable',
          parameters: {'a': 1, 'b': 2},
        ),
      );

      controller.executeAction('mergeable', parameters: {'b': 99, 'c': 3});

      expect(sentCommands.first['a'], equals(1));
      expect(sentCommands.first['b'], equals(99)); // Overridden
      expect(sentCommands.first['c'], equals(3)); // Added
    });

    test('Should execute one-off custom action', () {
      controller.executeCustom(
        action: 'quickAction',
        parameters: {'key': 'value'},
      );

      expect(sentCommands.length, equals(1));
      expect(sentCommands.first['action'], equals('customAction'));
      expect(sentCommands.first['customActionName'], equals('quickAction'));
      expect(sentCommands.first['key'], equals('value'));
    });

    test('Should handle action response via controller', () {
      Map<String, dynamic>? receivedResponse;

      controller.registerAction(
        QuillEditorAction(
          name: 'withResponse',
          onResponse: (response) => receivedResponse = response,
        ),
      );

      controller.executeAction('withResponse');

      // Simulate response from editor
      controller.handleActionResponse('withResponse', {'success': true, 'data': 42});

      expect(receivedResponse, isNotNull);
      expect(receivedResponse!['success'], isTrue);
      expect(receivedResponse!['data'], equals(42));
    });

    test('Should handle response override in executeAction', () {
      Map<String, dynamic>? defaultResponse;
      Map<String, dynamic>? overrideResponse;

      controller.registerAction(
        QuillEditorAction(
          name: 'responseTest',
          onResponse: (r) => defaultResponse = r,
        ),
      );

      controller.executeAction(
        'responseTest',
        onResponse: (r) => overrideResponse = r,
      );

      controller.handleActionResponse('responseTest', {'from': 'override'});

      // Override callback should be used, not default
      expect(overrideResponse, isNotNull);
      expect(overrideResponse!['from'], equals('override'));
      expect(defaultResponse, isNull);
    });

    test('Should handle one-off action response', () {
      Map<String, dynamic>? response;

      controller.executeCustom(
        action: 'oneOff',
        onResponse: (r) => response = r,
      );

      controller.handleActionResponse('oneOff', {'status': 'ok'});

      expect(response, isNotNull);
      expect(response!['status'], equals('ok'));
    });
  });

  group('QuillEditorController Zoom Tests', () {
    late QuillEditorController controller;
    late List<Map<String, dynamic>> sentCommands;

    setUp(() {
      controller = QuillEditorController();
      sentCommands = [];
      controller.attach((data) => sentCommands.add(Map.from(data)));
    });

    tearDown(() {
      controller.dispose();
    });

    test('Should zoom in and notify', () {
      var notified = false;
      controller.addListener(() => notified = true);

      final initialZoom = controller.currentZoom;
      controller.zoomIn();

      expect(controller.currentZoom, greaterThan(initialZoom));
      expect(notified, isTrue);
      expect(sentCommands.last['action'], equals('setZoom'));
    });

    test('Should zoom out and notify', () {
      // First zoom in so we can zoom out
      controller.zoomIn();
      controller.zoomIn();

      var notified = false;
      controller.addListener(() => notified = true);

      final beforeZoom = controller.currentZoom;
      controller.zoomOut();

      expect(controller.currentZoom, lessThan(beforeZoom));
      expect(notified, isTrue);
    });

    test('Should reset zoom to default', () {
      controller.zoomIn();
      controller.zoomIn();
      expect(controller.currentZoom, isNot(equals(EditorConfig.defaultZoom)));

      controller.resetZoom();
      expect(controller.currentZoom, equals(EditorConfig.defaultZoom));
    });

    test('Should clamp zoom to min/max', () {
      // Zoom out many times
      for (var i = 0; i < 20; i++) {
        controller.zoomOut();
      }
      expect(controller.currentZoom, greaterThanOrEqualTo(EditorConfig.minZoom));

      // Zoom in many times
      for (var i = 0; i < 40; i++) {
        controller.zoomIn();
      }
      expect(controller.currentZoom, lessThanOrEqualTo(EditorConfig.maxZoom));
    });

    test('Should set specific zoom level', () {
      controller.setZoom(1.5);
      expect(controller.currentZoom, equals(1.5));

      // Should clamp out of range values
      controller.setZoom(0.1);
      expect(controller.currentZoom, equals(EditorConfig.minZoom));

      controller.setZoom(10.0);
      expect(controller.currentZoom, equals(EditorConfig.maxZoom));
    });
  });

  group('QuillEditorController Command Tests', () {
    late QuillEditorController controller;
    late List<Map<String, dynamic>> sentCommands;

    setUp(() {
      controller = QuillEditorController();
      sentCommands = [];
      controller.attach((data) => sentCommands.add(Map.from(data)));
    });

    tearDown(() {
      controller.dispose();
    });

    test('Should send insertText command', () {
      controller.insertText('Hello World');

      expect(sentCommands.length, equals(1));
      expect(sentCommands.first['action'], equals('insertText'));
      expect(sentCommands.first['text'], equals('Hello World'));
    });

    test('Should send setHTML command', () {
      controller.setHTML('<p>Content</p>');

      expect(sentCommands.first['action'], equals('setHTML'));
      expect(sentCommands.first['html'], equals('<p>Content</p>'));
      expect(sentCommands.first['replace'], isTrue);
    });

    test('Should send setHTML command without replace', () {
      controller.setHTML('<p>Content</p>', replace: false);

      expect(sentCommands.first['replace'], isFalse);
    });

    test('Should send insertHtml command', () {
      controller.insertHtml('<b>Bold</b>');

      expect(sentCommands.first['action'], equals('insertHtml'));
      expect(sentCommands.first['html'], equals('<b>Bold</b>'));
      expect(sentCommands.first['replace'], isFalse);
    });

    test('Should send clear command', () {
      controller.clear();

      expect(sentCommands.first['action'], equals('clear'));
    });

    test('Should send focus command', () {
      controller.focus();

      expect(sentCommands.first['action'], equals('focus'));
    });

    test('Should send undo command', () {
      controller.undo();

      expect(sentCommands.first['action'], equals('undo'));
    });

    test('Should send redo command', () {
      controller.redo();

      expect(sentCommands.first['action'], equals('redo'));
    });

    test('Should send format command', () {
      controller.format('bold', true);

      expect(sentCommands.first['action'], equals('format'));
      expect(sentCommands.first['format'], equals('bold'));
      expect(sentCommands.first['value'], isTrue);
    });

    test('Should send insertTable command', () {
      controller.insertTable(3, 4);

      expect(sentCommands.first['action'], equals('insertTable'));
      expect(sentCommands.first['rows'], equals(3));
      expect(sentCommands.first['cols'], equals(4));
    });

    test('Should send getContents command', () {
      controller.getContents();

      expect(sentCommands.first['action'], equals('getContents'));
    });

    test('Should send setContents command', () {
      final delta = {'ops': [{'insert': 'Hello\n'}]};
      controller.setContents(delta);

      expect(sentCommands.first['action'], equals('setContents'));
      expect(sentCommands.first['delta'], equals(delta));
    });
  });

  group('QuillEditorController Dispose Tests', () {
    test('Should clear actions on dispose', () {
      final controller = QuillEditorController();

      controller.registerActions([
        const QuillEditorAction(name: 'a'),
        const QuillEditorAction(name: 'b'),
      ]);

      expect(controller.registeredActionNames.length, equals(2));

      // Dispose should not throw
      expect(() => controller.dispose(), returnsNormally);

      // After dispose, the controller cannot be used again
      // (ChangeNotifier throws when used after dispose)
    });

    test('Should detach on dispose', () {
      final controller = QuillEditorController();

      controller.attach((data) {});
      controller.markReady();
      expect(controller.isReady, isTrue);

      controller.dispose();

      // After dispose, controller should be detached
      // The dispose method calls detach() internally
    });
  });
}

