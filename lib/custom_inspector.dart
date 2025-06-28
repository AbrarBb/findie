
  import 'dart:convert';
import 'dart:html' as html;
import 'dart:js_interop';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:web/web.dart' as web;

var backendURL = "https://findie2271back.builtwithrocket.new/log-inspected-widget";

class CustomWidgetInspector extends StatefulWidget {
  final Widget child;

  const CustomWidgetInspector({Key? key, required this.child})
      : super(key: key);

  @override
  State<CustomWidgetInspector> createState() => _CustomWidgetInspectorState();
}

class _CustomWidgetInspectorState extends State<CustomWidgetInspector> {
  RenderObject? _selectedRenderObject;
  Element? _selectedElement;
  final GlobalKey _childKey = GlobalKey();
  bool isInspectorEnabled = false;

  void _handlePointerEvent(PointerEvent event) {
    if (!isInspectorEnabled) return;

    if (event is PointerDownEvent) {
      _updateSelection(event.position);
      //_handleTap();
    }
  }

  void _updateSelection(Offset position) {
    final RenderObject? userRender = _childKey.currentContext?.findRenderObject();
    if (userRender == null) return;

    final RenderObject? target = _findRenderObjectAtPosition(position, userRender);

    if (target != null && target != userRender) {
      if (_selectedRenderObject != target) {
        final Element? element = _findElementForRenderObject(target);
        setState(() {
          _selectedRenderObject = target;
          _selectedElement = element;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  void _handleTap() {
    if (_selectedElement != null && isInspectorEnabled) {
      try {
        var location = _getWidgetLocation(_selectedElement!);
        var widgetName =
        _selectedElement!.widget.runtimeType.toString();
        var parentWidgetName =
        _getParentWidgetType(_selectedElement!);
        var properties =
        _extractWidgetProperties(_selectedElement!);
        if (location.isNotEmpty && widgetName.isNotEmpty) {
          var widgetInfo = <String, dynamic>{};
          widgetInfo['widgetName'] = widgetName;
          widgetInfo['parentWidgetName'] = parentWidgetName;
          widgetInfo['location'] = location;
          widgetInfo['props'] = properties;
          _sendWidgetInformation(widgetInfo);
        }
      } catch (err, st) {
        print("Error sending widget info: $err || $st");
      }
    }
  }

  @override
  void initState() {
    _listenEvent();
    super.initState();
  }

  _listenEvent() {
    web.window.addEventListener(
        'message',
            (web.Event event) {
          try {
            final messageEvent = event as web.MessageEvent;
            if (messageEvent.data != null) {
              final eventData = messageEvent.data.dartify();
              if (eventData is Map) {
                if (eventData.containsKey('inspectToggle')) {
                  isInspectorEnabled = eventData['inspectToggle'];
                } else if (eventData.containsKey('outsideEventEnabled')) {
                  FocusManager.instance.primaryFocus?.unfocus();
                }
                setState(() {});
              }
            }
          } catch (e) {
            // print('error listening message: $e');
          }
        }.toJS);
  }

  void _handleHover(PointerHoverEvent event) {
    if (!isInspectorEnabled) return;

    final RenderObject? userRender = _childKey.currentContext?.findRenderObject();
    if (userRender == null) return;

    final RenderObject? target = _findRenderObjectAtPosition(event.position, userRender);

    if (target != null && target != userRender) {
      if (_selectedRenderObject != target) {
        final Element? element = _findElementForRenderObject(target);
        setState(() {
          _selectedRenderObject = target;
          _selectedElement = element;
        });
      }
    } else if (_selectedRenderObject != null) {
      setState(() {
        _selectedRenderObject = null;
        _selectedElement = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (isInspectorEnabled && _selectedRenderObject != null) {
            setState(() {
              _selectedRenderObject = null;
              _selectedElement = null;
            });
          }
          return false;
        },
        child: Stack(
          children: [
            // Main child widget - no IgnorePointer wrapper
            MouseRegion(
                onExit: (_) {
                  if (isInspectorEnabled) {
                    setState(() {
                      _selectedRenderObject = null;
                      _selectedElement = null;
                    });
                  }
                },
                // onHover: isInspectorEnabled ? _handleHover : null,
                child: KeyedSubtree(
                  key: _childKey,
                  child: Stack(
                    children: [
                      widget.child, // Original UI
                      if (isInspectorEnabled)
                        Positioned.fill(
                          child: Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: _handlePointerEvent,
                            onPointerHover: _handleHover,
                            onPointerMove: _handlePointerEvent,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: _handleTap,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Overlay showing the selected widget
            if (isInspectorEnabled && _selectedRenderObject != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _InspectorOverlayPainter(
                      selectedRenderObject: _selectedRenderObject!,
                      selectedElement: _selectedElement,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  RenderObject? _findRenderObjectAtPosition(
      Offset position,
      RenderObject root,
      ) {
    // Simple hit test to find the smallest render object at the given position
    final List<RenderObject> hits = <RenderObject>[];
    _hitTestHelper(hits, position, root, root.getTransformTo(null));

    if (hits.isEmpty) return null;

    // Sort by size (smallest first)
    hits.sort((RenderObject a, RenderObject b) {
      final Size sizeA = a.semanticBounds.size;
      final Size sizeB = b.semanticBounds.size;
      return (sizeA.width * sizeA.height).compareTo(sizeB.width * sizeB.height);
    });

    return hits.first;
  }

  bool _hitTestHelper(
      List<RenderObject> hits,
      Offset position,
      RenderObject object,
      Matrix4 transform,
      ) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);

    // Check children first
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i -= 1) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) {
        continue;
      }
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) {
        continue;
      }

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, position, child, childTransform)) {
        hit = true;
      }
    }

    // Check this object
    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      hits.add(object);
    }

    return hit;
  }

  Element? _findElementForRenderObject(RenderObject renderObject) {
    Element? result;
    void visitor(Element element) {
      if (element.renderObject == renderObject) {
        result = element;
        return;
      }
      element.visitChildren(visitor);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visitor);
    return result;
  }
}

class _InspectorOverlayPainter extends CustomPainter {
  final RenderObject selectedRenderObject;
  final Element? selectedElement;

  _InspectorOverlayPainter({
    required this.selectedRenderObject,
    required this.selectedElement,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!selectedRenderObject.attached) return;

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(128, 128, 128, 255);

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color.fromARGB(128, 64, 64, 128);

    // Transform to the coordinate system of the selected object
    final Matrix4 transform = selectedRenderObject.getTransformTo(null);
    final Rect bounds = selectedRenderObject.semanticBounds;

    canvas.save();
    canvas.transform(transform.storage);
    canvas.drawRect(bounds.deflate(0.5), fillPaint);
    canvas.drawRect(bounds.deflate(0.5), borderPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InspectorOverlayPainter oldDelegate) {
    return selectedRenderObject != oldDelegate.selectedRenderObject ||
        selectedElement != oldDelegate.selectedElement;
  }
}

String _getParentWidgetType(Element element) {
  Element? parent;
  element.visitAncestorElements((Element ancestor) {
    parent = ancestor;
    return false;
  });
  return parent?.widget.runtimeType.toString() ?? 'None';
}

String _getWidgetLocation(Element element) {
  const wrapperWidgetTypeNames = {
    'Obx',
    'GetX',
    'GetBuilder',
    'Observer',
    'Consumer',
    'Provider',
    'Builder',
    'BlocBuilder',
    'BlocListener',
    'BlocProvider',
    'Selector',
    'ValueListenableBuilder',
    'AnimatedBuilder',
    'StreamBuilder',
    'FutureBuilder',
    'SizedBox',
    'Positioned',
    'Center',
    'Expanded',
  };
  String widgetTypeName =
      element.widget.runtimeType.toString().split('<').first;
  if (wrapperWidgetTypeNames.contains(widgetTypeName)) {
    Element? childElement;
    element.visitChildren((child) {
      childElement ??= child;
    });
    if (childElement != null) {
      return _getWidgetLocation(childElement!);
    }
  }

  String? location;

  void check(Element e) {
    DiagnosticsNode node = e.toDiagnosticsNode();
    var delegate = InspectorSerializationDelegate(
      service: WidgetInspectorService.instance,
      summaryTree: true,
      subtreeDepth: 1,
      includeProperties: true,
      expandPropertyValues: true,
    );
    final Map<String, Object?> json = node.toJsonMap(delegate);
    if (json.containsKey('creationLocation')) {
      final Map creationLocation = json['creationLocation'] as Map;
      final String filePath = creationLocation['file']?.toString() ?? '';
      if (filePath.isNotEmpty &&
          !filePath.contains('/packages/flutter') &&
          !filePath.contains('pub.dev') &&
          !filePath.contains('/custom') &&
          !filePath.contains('/common')) {
        final String fileName = filePath.split("/").last;
        final String line = creationLocation['line']?.toString() ?? '0';
        final String column = creationLocation['column']?.toString() ?? '0';
        location = '$filePath:$line:$column';
      }
    }
  }

  check(element);
  if (location != null) return location!;
  element.visitAncestorElements((Element ancestor) {
    check(ancestor);
    return location == null;
  });
  return location ?? '';
}

Map<String, dynamic> _extractWidgetProperties(Element element) {
  final Map<String, dynamic> properties = {};
  final Widget currentWidget = element.widget;
  // List of wrapper widget type names (as strings) that require checking their immediate child
  const wrapperWidgetTypeNames = {
    'Obx',
    'GetX',
    'GetBuilder',
    'Observer',
    'Consumer',
    'Provider',
    'Builder',
    'BlocBuilder',
    'BlocListener',
    'BlocProvider',
    'Selector',
    'ValueListenableBuilder',
    'AnimatedBuilder',
    'StreamBuilder',
    'FutureBuilder',
    'SizedBox',
    'Positioned',
    'Center',
    'Expanded',
  };
  // If the current widget is a wrapper and has an immediate child, use that child.
  Widget effectiveWidget = currentWidget;
  String widgetTypeName =
      effectiveWidget.runtimeType.toString().split('<').first;
  if (wrapperWidgetTypeNames.contains(widgetTypeName)) {
    // This finds only immediate child.
    Widget? immediateChild;
    element.visitChildElements((Element child) {
      immediateChild = child.widget;
    });
    if (immediateChild != null) {
      effectiveWidget = immediateChild!;
    }
  }

  // Check if the effective widget is a Text.
  if (effectiveWidget is Text) {
    properties['type'] = effectiveWidget.runtimeType.toString();
    properties['key'] = effectiveWidget.key?.toString() ?? 'null';
    properties['text'] = effectiveWidget.data;
    properties['style'] = getTextStyle(effectiveWidget.style, element);
    properties['textAlign'] = effectiveWidget.textAlign?.toString() ?? 'null';
    return properties;
  }
  if (currentWidget is Builder) {
    // Check for AppBar widget in children or ancestors.
    final appBarWidget = _findWidgetOfTypeInAncestors<AppBar>(element);
    if (appBarWidget is AppBar) {
      properties['type'] = 'AppBar';
      properties['backgroundColor'] = appBarWidget.backgroundColor != null
          ? colorToHex(appBarWidget.backgroundColor!)
          : 'null';
      properties['centerTitle'] = appBarWidget.centerTitle.toString();
      properties['foregroundColor'] = appBarWidget.foregroundColor != null
          ? colorToHex(appBarWidget.foregroundColor!)
          : 'null';
      properties['elevation'] = appBarWidget.elevation.toString();
      final Widget? title = appBarWidget.title;
      if (title is Text) {
        properties['title'] = title.data ?? 'null';
      } else {
        properties['title'] = 'null';
      }
      return properties;
    }
    // Check for ElevatedButton or OutlinedButton in children or ancestors.
    final buttonWidget =
        _findWidgetOfTypeInAncestors<ElevatedButton>(element) ??
            _findWidgetOfTypeInAncestors<OutlinedButton>(element);
    if (buttonWidget != null) {
      properties['type'] = buttonWidget.runtimeType.toString();
      if (buttonWidget is ElevatedButton) {
        properties['backgroundColor'] =
            widgetStatePropertyToResolvedValues<Color?>(
              buttonWidget.style?.backgroundColor,
                  (color) => colorToHex(color!),
            );
        properties['foregroundColor'] =
            widgetStatePropertyToResolvedValues<Color?>(
              buttonWidget.style?.foregroundColor,
                  (color) => colorToHex(color!),
            );
        properties['iconColor'] = widgetStatePropertyToResolvedValues<Color?>(
          buttonWidget.style?.iconColor,
              (color) => colorToHex(color!),
        );
        properties['shadowColor'] = widgetStatePropertyToResolvedValues<Color?>(
          buttonWidget.style?.shadowColor,
              (color) => colorToHex(color!),
        );
        properties['overlayColor'] =
            widgetStatePropertyToResolvedValues<Color?>(
              buttonWidget.style?.overlayColor,
                  (color) => colorToHex(color!),
            );
        properties['textStyle'] =
            widgetStatePropertyToResolvedValues<TextStyle?>(
              buttonWidget.style?.textStyle,
                  (value) => value.toString(),
            );
        properties['elevation'] = widgetStatePropertyToResolvedValues<double?>(
          buttonWidget.style?.elevation,
              (value) => value.toString(),
        );
        properties['padding'] =
            widgetStatePropertyToResolvedValues<EdgeInsetsGeometry?>(
              buttonWidget.style?.padding,
                  (value) => value.toString(),
            );
        properties['shape'] =
            widgetStatePropertyToResolvedValues<OutlinedBorder?>(
              buttonWidget.style?.shape,
                  (value) => value.toString(),
            );
        properties['minimumSize'] = widgetStatePropertyToResolvedValues<Size?>(
          buttonWidget.style?.minimumSize,
              (value) => value.toString(),
        );
        properties['maximumSize'] = widgetStatePropertyToResolvedValues<Size?>(
          buttonWidget.style?.maximumSize,
              (value) => value.toString(),
        );
      }
      final Widget? child = (buttonWidget as dynamic).child;
      if (child is Text) {
        properties['text'] = child.data ?? 'null';
      } else {
        properties['text'] = 'null';
      }
      return properties;
    }
  }
  // Check for RichText widget in children or ancestors.
  final richTextWidget = _findWidgetOfTypeInChildren<RichText>(element);
  if (richTextWidget is RichText) {
    properties['type'] = 'RichText';
    // Extract the root TextSpan
    final TextSpan rootTextSpan = richTextWidget.text as TextSpan;
    // Recursive function to extract properties from TextSpan and its children
    Map<String, dynamic> extractTextSpanProperties(TextSpan textSpan) {
      final Map<String, dynamic> spanProperties = {};
      // Add text and style
      spanProperties['text'] = textSpan.text ?? '';
      spanProperties['style'] = getTextStyle(textSpan.style, element);
      // Recursively process children
      if (textSpan.children != null && textSpan.children!.isNotEmpty) {
        spanProperties['children'] = textSpan.children!
            .map((child) => extractTextSpanProperties(child as TextSpan))
            .toList();
      } else {
        spanProperties['children'] = [];
      }
      return spanProperties;
    }

    // Extract properties from the root TextSpan
    properties['textSpan'] = extractTextSpanProperties(rootTextSpan);
    return properties;
  }
  // Check for TextField widget in children or ancestors.
  final textFieldWidget = _findWidgetOfTypeInAncestors<TextField>(element);
  if (textFieldWidget is TextField) {
    properties['type'] = 'TextField';
    properties['text'] = textFieldWidget.controller?.text ?? 'null';
    properties['style'] = getTextStyle(textFieldWidget.style, element);
    final decoration = {
      'border': textFieldWidget.decoration?.border.toString() ?? 'null',
      'enabledBorder':
      textFieldWidget.decoration?.enabledBorder.toString() ?? 'null',
      'focusedBorder':
      textFieldWidget.decoration?.focusedBorder.toString() ?? 'null',
      'disabledBorder':
      textFieldWidget.decoration?.disabledBorder.toString() ?? 'null',
      'errorBorder':
      textFieldWidget.decoration?.errorBorder.toString() ?? 'null',
      'focusedErrorBorder':
      textFieldWidget.decoration?.focusedErrorBorder.toString() ?? 'null',
      'fillColor': textFieldWidget.decoration?.fillColor != null
          ? colorToHex(textFieldWidget.decoration!.fillColor!)
          : 'null',
      'filled': textFieldWidget.decoration?.filled.toString() ?? 'null',
      'hintText': textFieldWidget.decoration?.hintText.toString() ?? 'null',
      'hintStyle': getTextStyle(textFieldWidget.decoration?.hintStyle, element),
      'labelText': textFieldWidget.decoration?.labelText.toString() ?? 'null',
      'labelStyle': getTextStyle(textFieldWidget.decoration?.labelStyle, element),
      'prefixIcon': textFieldWidget.decoration?.prefixIcon.toString() ?? 'null',
      'prefixIconConstraints':
      textFieldWidget.decoration?.prefixIconConstraints.toString() ??
          'null',
      'suffixIcon': textFieldWidget.decoration?.suffixIcon.toString() ?? 'null',
      'suffixIconConstraints':
      textFieldWidget.decoration?.suffixIconConstraints.toString() ??
          'null',
      'counterText': textFieldWidget.decoration?.counterText.toString(),
    };
    properties['decoration'] = decoration;
    return properties;
  }
  const containerWrapperTypeNames = {
    'LimitedBox',
    'Align',
    'Padding',
    'ColoredBox',
    'ClipPath',
    'DecoratedBox',
    'ConstrainedBox',
    'Transform',
  };
  Container? containerConfig; // declared outside the if block
  if (containerWrapperTypeNames.contains(
    currentWidget.runtimeType.toString(),
  )) {
    element.visitAncestorElements((Element ancestor) {
      if (ancestor.widget is Container) {
        containerConfig = ancestor.widget as Container;
        return false; // Stop when found.
      }
      return true;
    });
    if (containerConfig != null) {
      effectiveWidget = containerConfig!;
    }
  }
  final Widget containerWidget = containerConfig ?? effectiveWidget;
  properties['type'] = containerWidget.runtimeType.toString();
  properties['key'] = containerWidget.key?.toString() ?? 'null';
  if (containerWidget is Container) {
    properties['color'] = containerWidget.color != null
        ? colorToHex(containerWidget.color!)
        : "null";
    properties['width'] =
        containerWidget.constraints?.maxWidth.toString() ?? 'null';
    properties['height'] =
        containerWidget.constraints?.maxHeight.toString() ?? 'null';
    properties['padding'] = containerWidget.padding?.toString() ?? 'null';
    properties['margin'] = containerWidget.margin?.toString() ?? 'null';
    if (containerWidget.decoration is BoxDecoration) {
      final boxDecoration = containerWidget.decoration as BoxDecoration;
      final decoration = {
        'color': boxDecoration.color != null
            ? colorToHex(boxDecoration.color!)
            : "null",
        'border': boxDecoration.border.toString(),
        'borderRadius': boxDecoration.borderRadius.toString(),
        'boxShadow': boxDecoration.boxShadow.toString(),
        'gradient': boxDecoration.gradient.toString(),
        'image': boxDecoration.image.toString(),
        'shape': boxDecoration.shape.toString(),
      };
      properties['decoration'] = decoration;
    }
    properties['alignment'] = containerWidget.alignment?.toString() ?? 'null';
  }
  return properties;
}

Widget? _findWidgetOfTypeInChildren<T>(Element element) {
  if (element.widget is T) {
    return element.widget;
  }
  Widget? foundWidget;
  element.visitChildElements((child) {
    foundWidget ??= _findWidgetOfTypeInChildren<T>(child);
  });
  return foundWidget;
}

// Helper function to find a widget of interest in the ancestor hierarchy (upward).
Widget? _findWidgetOfTypeInAncestors<T>(Element element) {
  Widget? foundWidget;
  element.visitAncestorElements((ancestor) {
    if (ancestor.widget is T) {
      foundWidget = ancestor.widget;
      return false; // Stop visiting further ancestors once the widget is found.
    }
    return true; // Continue visiting ancestors.
  });
  return foundWidget;
}

Map<String, dynamic> getTextStyle(TextStyle? style, BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;

    return {
      'color': style?.color != null
          ? colorToHex(style!.color!)
          : (defaultStyle.color != null ? colorToHex(defaultStyle.color!) : 'null'),
      'fontSize': style?.fontSize?.round().toString() ??
          defaultStyle.fontSize?.round().toString() ??
          'null',
      'backgroundColor': style?.backgroundColor != null
          ? colorToHex(style!.backgroundColor!)
          : (defaultStyle.backgroundColor != null
          ? colorToHex(defaultStyle.backgroundColor!)
          : 'null'),
      'fontWeight': style?.fontWeight?.toString() ??
          defaultStyle.fontWeight?.toString() ??
          'null',
      'fontStyle': style?.fontStyle?.toString() ??
          defaultStyle.fontStyle?.toString() ??
          'null',
      'fontFamily': style?.fontFamily ??
          defaultStyle.fontFamily ??
          'null',
      'letterSpacing': style?.letterSpacing?.toString() ??
          defaultStyle.letterSpacing?.toString() ??
          'null',
      'wordSpacing': style?.wordSpacing?.toString() ??
          defaultStyle.wordSpacing?.toString() ??
          'null',
      'textBaseline': style?.textBaseline?.toString() ??
          defaultStyle.textBaseline?.toString() ??
          'null',
      'height': style?.height?.toString() ??
          defaultStyle.height?.toString() ??
          'null',
      'overflow': style?.overflow?.toString() ??
          defaultStyle.overflow?.toString() ??
          'null',
    };
  }

String colorToHex(Color color) {
  var alphaColor =
  (color.a * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  var redColor =
  (color.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  var greenColor =
  (color.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  var blueColor =
  (color.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase();
  return '0X$alphaColor$redColor$greenColor$blueColor';
}

Map<String, String> widgetStatePropertyToResolvedValues<T>(
    WidgetStateProperty<T>? stateProperty,
    String Function(T value) valueToString,
    ) {
  if (stateProperty == null) {
    return {};
  }
  // Map to store state names and their corresponding resolved values.
  final Map<String, String> resolvedValues = {};
  // Add the default state (no specific state).
  final T? defaultValue = stateProperty.resolve({});
  if (defaultValue != null) {
    resolvedValues['default'] = valueToString(defaultValue);
  }
  return resolvedValues;
}

void _sendWidgetInformation(Map<String, dynamic> widgetInfo) {
  try {
    final payload = widgetInfo;

    final jsonData = jsonEncode(payload);
    final request = html.HttpRequest();
    request.open('POST', backendURL, async: true);
    request.setRequestHeader('Content-Type', 'application/json');

    request.onReadyStateChange.listen((_) {
      if (request.readyState == html.HttpRequest.DONE) {
        if (request.status == 200) {
          print('Successfully reported widgetInfo');
        } else {
          print('Error reporting widget information');
        }
      }
    });

    request.onError.listen((event) {
      print('Failed to send widget information');
    });

    request.send(jsonData);
  } catch (e) {
    print('Exception while reporting overflow error: $e');
  }
}
  