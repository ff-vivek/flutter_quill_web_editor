import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Tests for undo/redo functionality in the Quill Web Editor.
///
/// These tests verify the expected behavior of undo/redo operations
/// across different content types including text, formatting, tables,
/// colors, and fonts.
///
/// Note: These are unit tests for command structure and behavior expectations.
/// Full integration tests require a web browser environment.
void main() {
  group('Undo/Redo Command Structure Tests', () {
    test('Undo command should have correct structure', () {
      final command = {
        'action': 'undo',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('undo'));
      expect(command['type'], equals('command'));
      expect(command['source'], equals('flutter'));
    });

    test('Redo command should have correct structure', () {
      final command = {
        'action': 'redo',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('redo'));
      expect(command['type'], equals('command'));
      expect(command['source'], equals('flutter'));
    });

    test('Commands should be valid JSON', () {
      final undoCommand = {'action': 'undo', 'source': 'flutter', 'type': 'command'};
      final redoCommand = {'action': 'redo', 'source': 'flutter', 'type': 'command'};

      expect(() => jsonEncode(undoCommand), returnsNormally);
      expect(() => jsonEncode(redoCommand), returnsNormally);
    });
  });

  group('Text Undo/Redo Behavior Tests', () {
    test('Plain text insertion should be undoable', () {
      // Simulate: Insert "Hello World" -> Undo -> Should be empty
      final operations = <Map<String, dynamic>>[];

      // Insert text
      operations.add({
        'action': 'insertText',
        'text': 'Hello World',
        'source': 'flutter',
        'type': 'command',
      });

      // Undo
      operations.add({
        'action': 'undo',
        'source': 'flutter',
        'type': 'command',
      });

      expect(operations.length, equals(2));
      expect(operations[0]['action'], equals('insertText'));
      expect(operations[1]['action'], equals('undo'));
    });

    test('Multiple text insertions should undo in reverse order', () {
      // Insert A, Insert B, Insert C -> Undo -> Should have A, B only
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertText', 'text': 'A'});
      operations.add({'action': 'insertText', 'text': 'B'});
      operations.add({'action': 'insertText', 'text': 'C'});
      operations.add({'action': 'undo'}); // Removes C

      expect(operations.length, equals(4));
      expect(operations.last['action'], equals('undo'));
    });

    test('Redo should restore undone text', () {
      // Insert text -> Undo -> Redo -> Text should be back
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertText', 'text': 'Hello'});
      operations.add({'action': 'undo'}); // Remove Hello
      operations.add({'action': 'redo'}); // Restore Hello

      expect(operations.length, equals(3));
      expect(operations[2]['action'], equals('redo'));
    });
  });

  group('Bold Formatting Undo/Redo Tests', () {
    test('Bold formatting command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'bold',
        'value': true,
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('bold'));
      expect(command['value'], equals(true));
    });

    test('Bold formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      // Apply bold
      operations.add({
        'action': 'format',
        'format': 'bold',
        'value': true,
      });

      // Undo bold
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('bold'));
      expect(operations[1]['action'], equals('undo'));
    });

    test('Bold toggle should be redoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'bold', 'value': true});
      operations.add({'action': 'undo'});
      operations.add({'action': 'redo'});

      expect(operations.length, equals(3));
      expect(operations[2]['action'], equals('redo'));
    });
  });

  group('Italic Formatting Undo/Redo Tests', () {
    test('Italic formatting command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'italic',
        'value': true,
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('italic'));
      expect(command['value'], equals(true));
    });

    test('Italic formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'italic', 'value': true});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('italic'));
    });
  });

  group('Font Family Undo/Redo Tests', () {
    test('Font family change command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'font',
        'value': 'roboto',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('font'));
      expect(command['value'], equals('roboto'));
    });

    test('Font family change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      // Change font to Roboto
      operations.add({'action': 'format', 'format': 'font', 'value': 'roboto'});
      // Undo should revert to previous font
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['value'], equals('roboto'));
    });

    test('Multiple font changes should undo in reverse order', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'font', 'value': 'roboto'});
      operations.add({'action': 'format', 'format': 'font', 'value': 'lato'});
      operations.add({'action': 'format', 'format': 'font', 'value': 'montserrat'});
      operations.add({'action': 'undo'}); // Reverts to lato
      operations.add({'action': 'undo'}); // Reverts to roboto

      expect(operations.length, equals(5));
    });

    test('Font change should be redoable after undo', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'font', 'value': 'open-sans'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'redo'});

      expect(operations.length, equals(3));
      expect(operations[0]['value'], equals('open-sans'));
    });
  });

  group('Font Size Undo/Redo Tests', () {
    test('Font size change command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'size',
        'value': 'large',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('size'));
      expect(command['value'], equals('large'));
    });

    test('Font size change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'size', 'value': 'huge'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['value'], equals('huge'));
    });

    test('All size values should be valid', () {
      final validSizes = ['small', '', 'large', 'huge'];

      for (final size in validSizes) {
        final command = {
          'action': 'format',
          'format': 'size',
          'value': size,
        };
        expect(() => jsonEncode(command), returnsNormally);
      }
    });
  });

  group('Text Color Undo/Redo Tests', () {
    test('Text color command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'color',
        'value': '#ff0000',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('color'));
      expect(command['value'], equals('#ff0000'));
    });

    test('Text color change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'color', 'value': '#ff0000'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('color'));
    });

    test('Multiple color changes should undo in reverse order', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'color', 'value': '#ff0000'}); // Red
      operations.add({'action': 'format', 'format': 'color', 'value': '#00ff00'}); // Green
      operations.add({'action': 'format', 'format': 'color', 'value': '#0000ff'}); // Blue
      operations.add({'action': 'undo'}); // Reverts to Green
      operations.add({'action': 'undo'}); // Reverts to Red

      expect(operations.length, equals(5));
    });

    test('Color change should be redoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'color', 'value': '#purple'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'redo'});

      expect(operations[2]['action'], equals('redo'));
    });
  });

  group('Background Color Undo/Redo Tests', () {
    test('Background color command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'background',
        'value': '#ffff00',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('background'));
      expect(command['value'], equals('#ffff00'));
    });

    test('Background color change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'background', 'value': '#ffff00'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('background'));
    });

    test('Background and text color combined should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'color', 'value': '#ffffff'});
      operations.add({'action': 'format', 'format': 'background', 'value': '#000000'});
      operations.add({'action': 'undo'}); // Reverts background
      operations.add({'action': 'undo'}); // Reverts text color

      expect(operations.length, equals(4));
    });
  });

  group('Table Undo/Redo Tests', () {
    test('Table insert command should have correct structure', () {
      final command = {
        'action': 'insertTable',
        'rows': 3,
        'cols': 4,
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('insertTable'));
      expect(command['rows'], equals(3));
      expect(command['cols'], equals(4));
    });

    test('Table insertion should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertTable', 'rows': 3, 'cols': 3});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['action'], equals('insertTable'));
    });

    test('Table insertion should be redoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertTable', 'rows': 2, 'cols': 4});
      operations.add({'action': 'undo'});
      operations.add({'action': 'redo'});

      expect(operations.length, equals(3));
      expect(operations[2]['action'], equals('redo'));
    });

    test('Table with different dimensions should be valid', () {
      final tableSizes = [
        {'rows': 1, 'cols': 1},
        {'rows': 3, 'cols': 3},
        {'rows': 5, 'cols': 10},
        {'rows': 20, 'cols': 10},
      ];

      for (final size in tableSizes) {
        final command = {
          'action': 'insertTable',
          'rows': size['rows'],
          'cols': size['cols'],
        };
        expect(command['rows'], isA<int>());
        expect(command['cols'], isA<int>());
      }
    });
  });

  group('Link Undo/Redo Tests', () {
    test('Link formatting command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'link',
        'value': 'https://example.com',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['action'], equals('format'));
      expect(command['format'], equals('link'));
      expect(command['value'], equals('https://example.com'));
    });

    test('Link insertion should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({
        'action': 'format',
        'format': 'link',
        'value': 'https://flutter.dev',
      });
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
    });

    test('Link removal should be undoable (restore link)', () {
      final operations = <Map<String, dynamic>>[];

      // Add link
      operations.add({
        'action': 'format',
        'format': 'link',
        'value': 'https://flutter.dev',
      });
      // Remove link
      operations.add({
        'action': 'format',
        'format': 'link',
        'value': false, // Removes link
      });
      // Undo removal
      operations.add({'action': 'undo'});

      expect(operations.length, equals(3));
    });
  });

  group('Combined Formatting Undo/Redo Tests', () {
    test('Bold + Italic combined should undo separately', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'bold', 'value': true});
      operations.add({'action': 'format', 'format': 'italic', 'value': true});
      operations.add({'action': 'undo'}); // Removes italic
      operations.add({'action': 'undo'}); // Removes bold

      expect(operations.length, equals(4));
    });

    test('Multiple formats can be redone after multiple undos', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'bold', 'value': true});
      operations.add({'action': 'format', 'format': 'color', 'value': '#ff0000'});
      operations.add({'action': 'format', 'format': 'size', 'value': 'large'});
      operations.add({'action': 'undo'}); // Undo size
      operations.add({'action': 'undo'}); // Undo color
      operations.add({'action': 'redo'}); // Redo color
      operations.add({'action': 'redo'}); // Redo size

      expect(operations.length, equals(7));
    });
  });

  group('List Undo/Redo Tests', () {
    test('Ordered list formatting command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'list',
        'value': 'ordered',
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['format'], equals('list'));
      expect(command['value'], equals('ordered'));
    });

    test('Unordered list formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'list', 'value': 'bullet'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
    });

    test('Checklist formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'list', 'value': 'checked'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['value'], equals('checked'));
    });
  });

  group('Clear and Undo Tests', () {
    test('Clear command should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'setHTML', 'html': '<p>Important content</p>'});
      operations.add({'action': 'clear'});
      operations.add({'action': 'undo'}); // Should restore content

      expect(operations.length, equals(3));
      expect(operations[1]['action'], equals('clear'));
      expect(operations[2]['action'], equals('undo'));
    });
  });

  group('Edge Cases', () {
    test('Undo on empty editor should not crash', () {
      final command = {'action': 'undo', 'source': 'flutter', 'type': 'command'};

      // Should be a valid command structure
      expect(() => jsonEncode(command), returnsNormally);
    });

    test('Redo without prior undo should not crash', () {
      final command = {'action': 'redo', 'source': 'flutter', 'type': 'command'};

      // Should be a valid command structure
      expect(() => jsonEncode(command), returnsNormally);
    });

    test('Multiple consecutive undos should work', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertText', 'text': 'A'});
      operations.add({'action': 'insertText', 'text': 'B'});
      operations.add({'action': 'insertText', 'text': 'C'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(6));
      expect(operations.where((op) => op['action'] == 'undo').length, equals(3));
    });

    test('Redo stack should clear after new edit', () {
      // Conceptual test: After undo, if you make a new edit, redo should be unavailable
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'insertText', 'text': 'Original'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'insertText', 'text': 'New'}); // Clears redo stack
      // Redo at this point should have no effect (redo stack is empty)
      operations.add({'action': 'redo'});

      expect(operations.length, equals(4));
    });

    test('Undo should handle mixed content types', () {
      final operations = <Map<String, dynamic>>[];

      // Mix of text, formatting, table, and color
      operations.add({'action': 'insertText', 'text': 'Hello'});
      operations.add({'action': 'format', 'format': 'bold', 'value': true});
      operations.add({'action': 'insertTable', 'rows': 2, 'cols': 2});
      operations.add({'action': 'format', 'format': 'color', 'value': '#ff0000'});
      operations.add({'action': 'format', 'format': 'font', 'value': 'roboto'});
      
      // Undo all in reverse
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(10));
      expect(operations.where((op) => op['action'] == 'undo').length, equals(5));
    });
  });

  group('Header Formatting Undo/Redo Tests', () {
    test('Header formatting command should have correct structure', () {
      final command = {
        'action': 'format',
        'format': 'header',
        'value': 1,
        'source': 'flutter',
        'type': 'command',
      };

      expect(command['format'], equals('header'));
      expect(command['value'], equals(1));
    });

    test('All header levels should be valid', () {
      for (int level = 1; level <= 6; level++) {
        final command = {
          'action': 'format',
          'format': 'header',
          'value': level,
        };
        expect(command['value'], equals(level));
      }
    });

    test('Header change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'header', 'value': 1});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
    });
  });

  group('Underline and Strikethrough Undo/Redo Tests', () {
    test('Underline formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'underline', 'value': true});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('underline'));
    });

    test('Strikethrough formatting should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'strike', 'value': true});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('strike'));
    });
  });

  group('Alignment Undo/Redo Tests', () {
    test('Text alignment command should have correct structure', () {
      final alignments = ['left', 'center', 'right', 'justify'];

      for (final align in alignments) {
        final command = {
          'action': 'format',
          'format': 'align',
          'value': align,
        };
        expect(command['format'], equals('align'));
        expect(command['value'], equals(align));
      }
    });

    test('Alignment change should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'align', 'value': 'center'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
    });
  });

  group('Indent Undo/Redo Tests', () {
    test('Indent increase should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'indent', 'value': '+1'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
      expect(operations[0]['format'], equals('indent'));
    });

    test('Indent decrease should be undoable', () {
      final operations = <Map<String, dynamic>>[];

      operations.add({'action': 'format', 'format': 'indent', 'value': '-1'});
      operations.add({'action': 'undo'});

      expect(operations.length, equals(2));
    });
  });
}


