import 'dart:ui';

import 'package:a_star/a_star.dart';
import 'package:flutter/material.dart';

class GridDrawer extends StatelessWidget {
  const GridDrawer(this.grid, this.width, {Key? key}) : super(key: key);
  final List<GridCell> grid;
  final int width;
  int get height => grid.isEmpty ? 0 : grid.length ~/ width;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(
        width,
        height,
        grid,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  GridPainter(this.width, this.height, this.grid);
  final int width;
  final int height;
  final List<GridCell> grid;
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
  @override
  void paint(Canvas canvas, Size size) {
    double cellDim = 20;
    Size cellSize = Size(cellDim, cellDim);
    for (int y = 0; y < height; y += 1) {
      for (int x = 0; x < width; x += 1) {
        grid[x + (y * width)]
            .paint(canvas, cellSize, Offset(x * cellDim, y * cellDim));
      }
    }
  }
}

abstract class GridCell with Node<GridCell> {
  GridCell(this.x, this.y);

  List<Direction>? get directions => null;
  final int x;
  final int y;
  void paint(Canvas canvas, Size size, Offset offset);
}

class Empty extends GridCell {
  Empty(int x, int y) : super(x, y);

  @override
  void paint(Canvas canvas, Size size, Offset offset) {}
  @override
  String toString() => "_($x, $y)";
}

class Road extends GridCell {
  @override
  final List<Direction> directions;

  Road(this.directions, int x, int y) : super(x, y);
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    canvas.drawRect(offset & size, Paint()..color = Colors.grey[800]!);
    canvas.drawVertices(
        Vertices(
            VertexMode.triangles,
            directions
                .expand((element) => element.toTriangle(offset, size))
                .toList()),
        BlendMode.dst,
        Paint()..color = Colors.grey);
  }

  @override
  String toString() => "ROAD(directions: $directions, (x $x, $y y))";
}

class CarRoad extends Road {
  final Direction carDir;
  final Color color;

  CarRoad(List<Direction> directions, this.carDir, this.color, int x, int y)
      : super(directions, x, y);
  @override
  void paint(Canvas canvas, Size size, Offset offset) {
    super.paint(canvas, size, offset);
    if (carDir.asTriangle(offset, size).isEmpty) {
      canvas.drawRect(
          size.center(offset) - size.bottomRight(Offset.zero) / 4 & size / 2,
          Paint()..color = color);
    }
    canvas.drawVertices(
        Vertices(
            VertexMode.triangles,
            carDir.toTriangle(
                size.center(offset) - size.bottomRight(Offset.zero) / 4,
                size / 2)),
        BlendMode.dst,
        Paint()..color = color);
  }

  @override
  String toString() => "CARROAD(directions: $directions, (x $x, y $y))";
}

class Direction {
  final int dx;
  final int dy;

  Direction(this.dx, this.dy);
  List<Offset> toTriangle(Offset offset, Size size) {
    List<Offset> tri = asTriangle(offset, size);
    return tri;
  }

  @override
  String toString() => "($dx, $dy)";
  double size2 = 5;
  List<Offset> asTriangle(Offset offset, Size size) {
    switch (dx * 2 + dy) {
      case 2: //right
        return [
          offset + Offset(size.width, size.height / 2),
          offset + Offset(size.width - size2, (size.height / 2) + size2),
          offset + Offset(size.width - size2, (size.height / 2) - size2)
        ];
      case 1: //down
        return [
          offset + Offset(size.width / 2, size.height),
          offset + Offset((size.width / 2) + size2, size.height - size2),
          offset + Offset((size.width / 2) - size2, size.height - size2)
        ];
      case -1: //up
        return [
          offset + Offset(size.width / 2, 0),
          offset + Offset((size.width / 2) + size2, size2),
          offset + Offset((size.width / 2) - size2, size2)
        ];
      case -2: //left
        return [
          offset + Offset(0, size.height / 2),
          offset + Offset(size2, (size.height / 2) + size2),
          offset + Offset(size2, (size.height / 2) - size2)
        ];
      default:
        return [];
    }
  }
}
