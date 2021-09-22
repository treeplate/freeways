import 'package:flutter/material.dart';
import 'package:freeways/grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<GridCell> grid = [
    //row 0
    Road(
      [
        Direction(1, 0),
      ],
    ),
    Road(
      [
        Direction(1, 0),
      ],
    ),
    Road(
      [
        Direction(0, 1),
      ],
    ),
    //row 1
    Road(
      [
        Direction(0, -1),
      ],
    ),
    Empty(),
    Road(
      [
        Direction(0, 1),
      ],
    ),
    //row 2
    Road(
      [
        Direction(0, -1),
      ],
    ),
    Road(
      [
        Direction(-1, 0),
      ],
    ),
    Road(
      [
        Direction(-1, 0),
      ],
    ),
  ];
  List<Destination> goals = [Destination(1, Colors.blue)];
  List<int> starts = [1];
  List<Color> colors = [Colors.green, Colors.yellow, Colors.blue];
  int get width => 3;
  int tN = 0;
  void tick() {
    tN++;
    List<int> nopes = [];
    for (int x = 0; x < width; x++) {
      ys:
      for (int y = 0; y < grid.length ~/ width; y++) {
        if (grid[y * width + x] is CarRoad && !nopes.contains(y * width + x)) {
          for (Destination goal in goals) {
            if (goal.color == (grid[(y) * width + (x)] as CarRoad).color &&
                (y) == goal.y &&
                (x) == width - 1) {
              grid[(y) * width + (x)] = Road(grid[y * width + x].directions!);
              continue ys;
            }
          }
          List<Direction> dirs = grid[y * width + x]
              .directions!
              .where(
                (dir) =>
                    dir.dx + x < width &&
                    dir.dx + x >= 0 &&
                    dir.dy + y < grid.length ~/ width &&
                    dir.dy + y >= 0 &&
                    grid[(y + dir.dy) * width + (x + dir.dx)]
                            .runtimeType
                            .toString() ==
                        (Road).toString(),
              )
              .toList();
          Direction dir = dirs.isEmpty ? Direction(0, 0) : dirs.first;
          nopes.add((y + dir.dy) * width + (x + dir.dx));
          grid[(y + dir.dy) * width + (x + dir.dx)] = CarRoad(
              grid[(y + dir.dy) * width + (x + dir.dx)].directions!,
              dir,
              (grid[y * width + x] as CarRoad).color);
          if (dir.dx != 0 || dir.dy != 0) {
            grid[y * width + x] = Road(grid[y * width + x].directions!);
          }
        }
      }
    }
    setState(() {
      if (tN % 2 == 0) {
        for (int start in starts) {
          colors.shuffle();
          if (grid[start * width] is! CarRoad) {
            grid[start * width] = CarRoad(
                grid[start * width].directions!, Direction(0, 0), colors.first);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FloatingActionButton(
          onPressed: tick,
        ),
      ),
      body: Center(
        child: GridDrawer(grid, width),
      ),
    );
  }
}

class Destination {
  Destination(this.y, this.color);
  final int y;
  final Color color;
}
