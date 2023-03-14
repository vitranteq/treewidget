import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TreeLayout extends MultiChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;
  TreeLayout({
    Key? key,
    List<Widget> children = const <Widget>[],
    required this.onSizeChange
  }) : super(key: key, children: children);

  @override
  RenderTreeLayout createRenderObject(BuildContext context) {
    return RenderTreeLayout(onSizeChange: onSizeChange);
  }
}

class RenderTreeLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TreeParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TreeParentData> {
  Size? currentSize;
  final OnWidgetSizeChange onSizeChange;

  RenderTreeLayout({required this.onSizeChange });

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! TreeParentData) {
      child.parentData = TreeParentData();
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.biggest;
      assert(size.isFinite);
      return;
    }
    // Determine available width and height
    final double availableWidth = constraints.maxWidth;
    double totalHeight = 0;
    double totalWidth = 0;

    // Layout children in a column
    var child = firstChild;
    RenderBox? last;
    RenderBox? root;
    while (child != null) {
      // Measure child size
      child.layout(
        BoxConstraints(
          maxWidth: availableWidth,
        ),
        parentUsesSize: true,
      );
      final TreeParentData childParentData = child.parentData as TreeParentData;
      if (root == null) {
        root = child;
        childParentData.offset = Offset(0, totalHeight);
        totalHeight += child.size.height;
      } else {
        last = child;
        childParentData.offset = Offset(totalWidth, root.size.height);
        totalWidth += child.size.width;
        totalHeight = max(totalHeight, root.size.height + child.size.height);
      }
      child = childParentData.nextSibling;
    }
    final TreeParentData rootParentData = root!.parentData as TreeParentData;
    rootParentData.offset = Offset((totalWidth - (last != null ? last.size.width : 0))/2, 0);

    final newSize = Size(last != null ? totalWidth : root.size.width, totalHeight);
    size = constraints.constrain(newSize);
    if (currentSize != newSize) {
      currentSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSizeChange(newSize);
      });
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

class TreeParentData extends ContainerBoxParentData<RenderBox> {}


typedef OnWidgetSizeChange = void Function(Size size);

class WidgetSizeRenderObject extends RenderProxyBox {

  final OnWidgetSizeChange onSizeChange;
  Size? currentSize;

  WidgetSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    try {
      Size? newSize = child?.size;

      if (newSize != null && currentSize != newSize) {
        currentSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSizeChange(newSize);
        });
      }
    } catch (e) {
      print(e);
    }
  }
}

class WidgetSizeOffsetWrapper extends SingleChildRenderObjectWidget {

  final OnWidgetSizeChange onSizeChange;

  const WidgetSizeOffsetWrapper({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return WidgetSizeRenderObject(onSizeChange);
  }
}