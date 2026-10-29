import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/lesson_model.dart';
import '../common/where_is_this_from_sheet.dart';

class ConceptMapScreen extends StatefulWidget {
  const ConceptMapScreen({
    super.key,
    required this.title,
    required this.conceptMap,
    required this.rawNoteLines,
  });

  final String title;
  final ConceptMapModel conceptMap;
  final List<String> rawNoteLines;

  @override
  State<ConceptMapScreen> createState() => _ConceptMapScreenState();
}

class _ConceptMapScreenState extends State<ConceptMapScreen> {
  final TransformationController _transformController =
      TransformationController();
  ConceptNodeModel? _selectedNode;

  // Calculated node positions
  final Map<String, Offset> _nodePositions = {};
  final double _nodeWidth = 170.0;
  final double _nodeHeight = 65.0;

  @override
  void initState() {
    super.initState();
    _layoutNodes();
  }

  void _layoutNodes() {
    final nodes = widget.conceptMap.nodes;
    if (nodes.isEmpty) return;

    // Distribute nodes in a hierarchical / layered grid
    const startX = 60.0;
    const startY = 80.0;
    const spacingX = 230.0;
    const spacingY = 130.0;

    int cols = (nodes.length <= 4) ? 2 : 3;

    for (int i = 0; i < nodes.length; i++) {
      int row = i ~/ cols;
      int col = i % cols;

      // Slight zigzag offset for organic appearance
      double offsetY = (col % 2 == 1) ? 35.0 : 0.0;

      _nodePositions[nodes[i].id] = Offset(
        startX + (col * spacingX),
        startY + (row * spacingY) + offsetY,
      );
    }
  }

  void _onTapCanvas(TapUpDetails details) {
    final localPos = details.localPosition;
    ConceptNodeModel? tappedNode;

    for (final node in widget.conceptMap.nodes) {
      final pos = _nodePositions[node.id];
      if (pos == null) continue;

      final rect = Rect.fromLTWH(pos.dx, pos.dy, _nodeWidth, _nodeHeight);
      if (rect.contains(localPos)) {
        tappedNode = node;
        break;
      }
    }

    if (tappedNode != null) {
      setState(() => _selectedNode = tappedNode);
      WhereIsThisFromSheet.show(
        context,
        title: tappedNode.label,
        sourceLines: tappedNode.sourceLines,
        rawNoteLines: widget.rawNoteLines,
      );
    }
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} – Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _resetZoom,
            tooltip: 'Reset Zoom & Center',
          ),
        ],
      ),
      body: widget.conceptMap.nodes.isEmpty
          ? const Center(child: Text('No concept map data available.'))
          : Stack(
              children: [
                InteractiveViewer(
                  transformationController: _transformController,
                  boundaryMargin: const EdgeInsets.all(500),
                  minScale: 0.4,
                  maxScale: 2.8,
                  constrained: false,
                  child: GestureDetector(
                    onTapUp: _onTapCanvas,
                    child: Container(
                      width: 900,
                      height: 800,
                      color: theme.scaffoldBackgroundColor,
                      child: CustomPaint(
                        painter: _ConceptMapPainter(
                          nodes: widget.conceptMap.nodes,
                          edges: widget.conceptMap.edges,
                          positions: _nodePositions,
                          nodeWidth: _nodeWidth,
                          nodeHeight: _nodeHeight,
                          colorScheme: colorScheme,
                          selectedNodeId: _selectedNode?.id,
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating helper banner
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pinch to zoom. Tap any node to inspect source line grounding.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ConceptMapPainter extends CustomPainter {
  const _ConceptMapPainter({
    required this.nodes,
    required this.edges,
    required this.positions,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.colorScheme,
    this.selectedNodeId,
  });

  final List<ConceptNodeModel> nodes;
  final List<ConceptEdgeModel> edges;
  final Map<String, Offset> positions;
  final double nodeWidth;
  final double nodeHeight;
  final ColorScheme colorScheme;
  final String? selectedNodeId;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Edges
    final edgePaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    for (final edge in edges) {
      final fromPos = positions[edge.from];
      final toPos = positions[edge.to];
      if (fromPos == null || toPos == null) continue;

      final start = Offset(
        fromPos.dx + nodeWidth / 2,
        fromPos.dy + nodeHeight / 2,
      );
      final end = Offset(toPos.dx + nodeWidth / 2, toPos.dy + nodeHeight / 2);

      // Draw curved bezier path
      final path = Path();
      path.moveTo(start.dx, start.dy);
      final controlPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2 - 25,
      );
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
      canvas.drawPath(path, edgePaint);

      // Draw Arrow at end
      final angle = atan2(end.dy - controlPoint.dy, end.dx - controlPoint.dx);
      const arrowSize = 10.0;
      final arrowPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(
          end.dx - arrowSize * cos(angle - pi / 6),
          end.dy - arrowSize * sin(angle - pi / 6),
        )
        ..lineTo(
          end.dx - arrowSize * cos(angle + pi / 6),
          end.dy - arrowSize * sin(angle + pi / 6),
        )
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);

      // Draw Edge Label
      if (edge.label.isNotEmpty) {
        final textSpan = TextSpan(
          text: edge.label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)
          ..layout();
        tp.paint(
          canvas,
          Offset(controlPoint.dx - tp.width / 2, controlPoint.dy - 10),
        );
      }
    }

    // 2. Draw Nodes
    for (final node in nodes) {
      final pos = positions[node.id];
      if (pos == null) continue;

      final isSelected = node.id == selectedNodeId;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx, pos.dy, nodeWidth, nodeHeight),
        const Radius.circular(12),
      );

      // Node shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: isSelected ? 0.2 : 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRRect(rect.shift(const Offset(0, 3)), shadowPaint);

      // Node background
      final bgPaint = Paint()
        ..color = isSelected
            ? colorScheme.primary.withValues(alpha: 0.15)
            : colorScheme.surface
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rect, bgPaint);

      // Node border
      final borderPaint = Paint()
        ..color = isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.7)
        ..strokeWidth = isSelected ? 2.5 : 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rect, borderPaint);

      // Node text
      final textSpan = TextSpan(
        text: node.label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '...',
      )..layout(maxWidth: nodeWidth - 24);

      textPainter.paint(canvas, Offset(pos.dx + 12, pos.dy + 12));

      // Citation chip indicator
      if (node.sourceLines.isNotEmpty) {
        final citeSpan = TextSpan(
          text: 'Lines: ${node.sourceLines.join(",")}',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        );
        final citePainter = TextPainter(
          text: citeSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        citePainter.paint(
          canvas,
          Offset(pos.dx + 12, pos.dy + nodeHeight - 18),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConceptMapPainter oldDelegate) {
    return oldDelegate.selectedNodeId != selectedNodeId ||
        oldDelegate.colorScheme != colorScheme;
  }
}
