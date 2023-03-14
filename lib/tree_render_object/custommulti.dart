import 'dart:math';

import 'package:flutter/material.dart';
import 'package:treeview/tree_render_object/treewidget.dart';


class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  var data = NodeData.defaultData();
  final transformationController = TransformationController();
  Size size = Size.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  double _getRightBoundary(Size screenSize) {
    final double leftBoundary = max(size.width - screenSize.width, 0);
    final bottomBoundary = max(size.height - screenSize.height, 0);
    if (leftBoundary > bottomBoundary ) {
      return leftBoundary;
    } else if (size.aspectRatio != 0){
      return bottomBoundary * 2 * 2  * size.aspectRatio;
    }

    return 0;
  }

  double _getBottomBoundary(Size screenSize) {
    final double leftBoundary = max(size.width - screenSize.width, 0);
    final double bottomBoundary = max(size.height - screenSize.height, 0);
    if (leftBoundary > bottomBoundary ) {
      return size.aspectRatio != 0 ? (leftBoundary * 2 * 2 / size.aspectRatio): 0;
    } else{
      return bottomBoundary * 2;
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractiveViewer(
                  clipBehavior: Clip.hardEdge,
                  maxScale: 1.0,
                  minScale: 0.1,
                  panEnabled: true,
                  transformationController: transformationController,
                  boundaryMargin: EdgeInsets.all(double.infinity),
                  // boundaryMargin: EdgeInsets.only(
                  //   right: _getRightBoundary(screenSize),//max(0, size.width - screenSize.width),
                  //   // left: _getLeftBoundary(screenSize) /2,//max(0, size.width - screenSize.width),
                  //   bottom: _getBottomBoundary(screenSize),
                  //   // top: _getBottomBoundary(screenSize) /4,
                  //   // size.aspectRatio != 0
                  //   //     ? (max(0, size.width - screenSize.width) * 2 * size.aspectRatio)
                  //   //     : 0,
                  // ),
                  child: Container(
                    width: 500,
                    height: 500,
                    color: Colors.grey,
                    // child: GraphView(
                    //   onSizeChange: (Size size) {
                    //     setState(() {
                    //       this.size = size;
                    //     });
                    //     print("+++ bottom ${_getBottomBoundary(screenSize)}");
                    //   },
                    //   data: data,
                    //   lineColor: const Color.fromRGBO(32, 32, 32, 1),
                    //   builder: (level, key, data) {
                    //     if (level == 0) {
                    //       return Container(
                    //           color: const Color.fromRGBO(66, 81, 75, 1),
                    //           child: Center(
                    //               child: Text(
                    //             data.content,
                    //             style:
                    //                 const TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
                    //           )));
                    //     } else if (level == 1) {
                    //       return Container(
                    //           color: const Color.fromRGBO(88, 110, 102, 1),
                    //           child: Center(
                    //               child: Text("$key - ${data.content}",
                    //                   style: const TextStyle(
                    //                       color: Colors.white, fontWeight: FontWeight.w400))));
                    //     }
                    //     return Container(
                    //       padding: const EdgeInsets.all(8),
                    //       color: const Color.fromRGBO(226, 234, 235, 1),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Text("$key ${data.content}"),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                  ),
                ),
              ),
            ),
            OutlinedButton(
                onPressed: () {
                  data.nodes.first.nodes.removeAt(0);
                  setState(() {});
                },
                child: const Text("Delete"))
          ],
        ),
      ),
    );
  }
}

typedef NodeWidgetBuilder = Widget Function(int level, String key, NodeData data);

class GraphView extends StatelessWidget {
  GraphView({
    super.key,
    required this.builder,
    required this.data,
    required this.onSizeChange,
    double lineWidth = 2.0,
    Color lineColor = Colors.black,
  }) : paint = Paint()
          ..color = lineColor
          ..strokeWidth = lineWidth
          ..strokeCap = StrokeCap.round;

  final NodeData data;
  final NodeWidgetBuilder builder;
  final Paint paint;

  final Size fixedNodeSize = const Size(150, 60);
  final double spacingBetweenLv = 48;
  final double spacingBetweenChildLv2 = 24;
  final OnWidgetSizeChange onSizeChange;

  @override
  Widget build(BuildContext context) {
    return TreeLayout(
      onSizeChange: onSizeChange,
      children: [
        _buildRootNode(
          startX: fixedNodeSize.width / 2,
          isHideLine: data.nodes.isEmpty,
          child: Padding(
            padding: EdgeInsets.only(bottom: spacingBetweenLv / 2),
            child: SizedBox(
              height: fixedNodeSize.height,
              width: fixedNodeSize.width,
              child: builder(0, "", data),
            ),
          ),
        ),
        for (int i = 0; i < data.nodes.length; i++)
          _buildBranchLv1(branch: i, node: data.nodes[i], type: _getHorizontalTopLine(data, i))
      ],
    );
  }

  Widget _buildBranchLv1(
      {required int branch, required NodeData node, required _HorizontalLine type}) {
    const double spacing = 16;
    return CustomPaint(
      painter: _TopLine(
          positionX: fixedNodeSize.width / 2,
          height: spacingBetweenLv / 2,
          type: type,
          painter: paint),
      child: Padding(
        padding: EdgeInsets.only(top: spacingBetweenLv / 2, right: spacingBetweenLv),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRootNode(
                  startX: spacing,
                  isHideLine: node.nodes.isEmpty,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacingBetweenLv / 2),
                    child: SizedBox(
                      width: fixedNodeSize.width,
                      height: fixedNodeSize.height,
                      child: builder(1, "${branch + 1}", node),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: spacing),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  for (int i = 0; i < node.nodes.length; i++)
                    _buildNodeLV2(
                        branch: branch,
                        position: i,
                        data: node.nodes[i],
                        last: i == node.nodes.length - 1)
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodeLV2(
      {required int branch, required int position, required NodeData data, bool last = false}) {
    const double spacing = 32;
    return CustomPaint(
      painter: _LeftLine(last: last, spacing: spacing, painter: paint),
      child: Padding(
        padding: EdgeInsets.only(
            top: spacingBetweenChildLv2 / 2, left: spacing, bottom: spacingBetweenChildLv2 / 2),
        child: Container(
          constraints:
              BoxConstraints(minWidth: fixedNodeSize.width, minHeight: fixedNodeSize.height),
          child: builder(2, "${branch + 1}.${position + 1}", data),
        ),
      ),
    );
  }

  _HorizontalLine _getHorizontalTopLine(NodeData node, int branch) {
    final length = node.nodes.length;
    if (length == 1 || length == 0) return _HorizontalLine.none;
    if (branch == 0) return _HorizontalLine.left;
    if (branch == length - 1) return _HorizontalLine.right;
    return _HorizontalLine.all;
  }

  Widget _buildRootNode({required Widget child, required double startX, required bool isHideLine}) {
    return CustomPaint(
      painter: _BottomLine(
          height: isHideLine ? 0 : spacingBetweenLv / 2, startX: startX, painter: paint),
      child: child,
    );
  }
}

class _LeftLine extends CustomPainter {
  final double spacing;
  final bool last;
  final Paint painter;

  _LeftLine({this.last = false, required this.spacing, required this.painter});

  @override
  void paint(Canvas canvas, Size size) {
    Offset startingVerticalOffset = const Offset(0, 0);
    Offset endingVerticalOffset = Offset(0, last ? size.height / 2 : size.height);

    Offset startingHorizontalOffset = Offset(0, size.height / 2);
    Offset endingHorizontalOffset = Offset(spacing, size.height / 2);

    canvas.drawLine(startingVerticalOffset, endingVerticalOffset, painter);
    canvas.drawLine(startingHorizontalOffset, endingHorizontalOffset, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _HorizontalLine { left, all, right, none }

class _TopLine extends CustomPainter {
  final double height;
  final double positionX;
  final _HorizontalLine type;
  final Paint painter;

  _TopLine(
      {this.positionX = 0,
      required this.height,
      this.type = _HorizontalLine.all,
      required this.painter});

  @override
  void paint(Canvas canvas, Size size) {
    // top
    Offset startingVerticalOffset = Offset(positionX, 0);
    Offset endingVerticalOffset = Offset(positionX, height);
    if (type != _HorizontalLine.none) {
      Offset startingHorizontalOffset = Offset(getStartHorizontalLine(), 0);
      Offset endingHorizontalOffset = Offset(getEndHorizontalLine(size), 0);

      canvas.drawLine(startingHorizontalOffset, endingHorizontalOffset, painter);
    }
    canvas.drawLine(startingVerticalOffset, endingVerticalOffset, painter);
  }

  double getStartHorizontalLine() {
    if (type == _HorizontalLine.left) {
      return positionX;
    }
    return 0;
  }

  double getEndHorizontalLine(Size size) {
    if (type == _HorizontalLine.all) {
      return size.width;
    } else if (type == _HorizontalLine.left) {
      return size.width;
    }
    return positionX;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomLine extends CustomPainter {
  final double height;
  final double startX;
  final Paint painter;

  _BottomLine({required this.height, required this.startX, required this.painter});

  @override
  void paint(Canvas canvas, Size size) {
    if (height > 0) {
      Offset startingOffset = Offset(startX, size.height - height);
      Offset endingOffset = Offset(startX, size.height);
      canvas.drawLine(startingOffset, endingOffset, painter);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NodeData {
  final String content;
  final List<NodeData> nodes;

  NodeData({required this.content, this.nodes = const []});

  static NodeData defaultData() {
    return NodeData(content: "WBS", nodes: [
      NodeData(content: "", nodes: [
        NodeData(
            content:
                " 1 sdjg sjdhg sdmgj sjdg sgmjsg ,sjdhg sgsdkjgh sg,sdjhfg d,fgkb ,kdjsg s,dkrgj s,jkrg rg"),
        // NodeData(content: "2"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
        // NodeData(content: "3"),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: []),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
      NodeData(content: "", nodes: [
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
        NodeData(content: ""),
      ]),
    ]);
  }
}

extension on NodeData {
  WBS toWBS(String prev) {
    return WBS(
        data: content,
        num: prev,
        children: nodes.map((e) => e.toWBS("$prev.${nodes.indexOf(e).toString()}")).toList());
  }
}

class WBS {
  final String data;
  final String num;
  final List<WBS> children;

  WBS({required this.data, this.num = "", this.children = const []});

  @override
  String toString() {
    return "$data\n$num\n${children.toString()}";
  }
}
