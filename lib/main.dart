// ignore_for_file: avoid_print

import 'dart:async';

import 'package:a_star/a_star.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'grid.dart';

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

class _MyHomePageState extends State<MyHomePage> implements Graph<GridCell> {
  List<GridCell> grid = [
    Empty(0, 0),
  ];
  List<Destination> goals = [
    Destination(0, 3, Colors.green),
    Destination(1, 0, Colors.red),
    Destination(3, 4, Colors.yellow),
    Destination(4, 1, Colors.blue),
  ];
  List<List<int>> starts = [
    [0, 1],
    [3, 0],
    [1, 4],
    [4, 3]
  ];
  List<Color> colors = [Colors.green, Colors.yellow, Colors.blue, Colors.red];
  int width = 1;
  int tN = 0;
  void parse() async {
    int w = 0;
    int l = 0;
    grid = [];
    List<List<int>> starts2 = starts;
    starts = [];
    String str = await rootBundle.loadString("world.roads");
    cs:
    for (String char in str.split('')) {
      switch (char) {
        case '\n':
          l++;
          width = w;
          w = 0;
          continue cs;
        case 'L':
          grid.add(Road([Direction(0, -1), Direction(1, 0)], w, l));
          break;
        case 'R':
          grid.add(Road([Direction(1, 0), Direction(0, 1)], w, l));
          break;
        case '\\':
          grid.add(Road([Direction(0, 1), Direction(-1, 0)], w, l));
          break;
        case '/':
          grid.add(Road([Direction(-1, 0), Direction(0, -1)], w, l));
          break;
        case '|':
          grid.add(Road([Direction(0, 1), Direction(0, -1)], w, l));
          break;
        case '[':
          grid.add(
              Road([Direction(0, 1), Direction(0, -1), Direction(1, 0)], w, l));
          break;
        case '_':
          grid.add(Empty(w, l));
          break;
        case "A":
          grid.add(Road([Direction(0, -1)], w, l));
          break;
        case "V":
          grid.add(Road([Direction(0, 1)], w, l));
          break;
        case "<":
          grid.add(Road([Direction(-1, 0)], w, l));
          break;
        case ">":
          grid.add(Road([Direction(1, 0)], w, l));
          break;
      }
      w++;
    }
    starts = starts2;
    setState(() {});
  }

  late final AStar aStar = AStar<GridCell>(this);

  void tick(_) {
    tN++;
    List<int> nopes = [];
    for (int x = 0; x < width; x++) {
      ys:
      for (int y = 0; y < grid.length ~/ width; y++) {
        if (grid[y * width + x] is CarRoad && !nopes.contains(y * width + x)) {
          for (Destination goal in goals) {
            if (goal.color == (grid[(y) * width + (x)] as CarRoad).color &&
                (y) == goal.y &&
                (x) == goal.x) {
              grid[(y) * width + (x)] =
                  Road(grid[y * width + x].directions!, x, y);
              continue ys;
            }
          }
          Destination goal = goals.firstWhere((element) =>
              element.color == (grid[y * width + x] as CarRoad).color);
          Iterable steps = aStar.findPathSync(
              grid[y * width + x], grid[goal.y * width + goal.x]);
          Direction dir;
          if (steps.isEmpty) {
            print(
                "hmm... ${grid[y * width + x]} to ${goal.x} ${goal.y} failed.");
            dir = Direction(0, 0);
          } else {
            steps = steps.skip(1);
            dir = Direction(steps.first.x - x as int, steps.first.y - y as int);
            if (steps.first is CarRoad) dir = Direction(0, 0);
          }
          nopes.add((y + dir.dy) * width + (x + dir.dx));
          grid[(y + dir.dy) * width + (x + dir.dx)] = CarRoad(
              grid[(y + dir.dy) * width + (x + dir.dx)].directions!,
              dir,
              (grid[y * width + x] as CarRoad).color,
              (x + dir.dx),
              (y + dir.dy));
          if (dir.dx != 0 || dir.dy != 0) {
            grid[y * width + x] = Road(grid[y * width + x].directions!, x, y);
          }
        }
      }
    }
    setState(() {
      if (tN % 1 == 0) {
        for (List<int> start in starts) {
          colors.shuffle();
          if (grid[start[1] * width + start[0]] is! CarRoad) {
            grid[start[1] * width + start[0]] = CarRoad(
                grid[start[1] * width + start[0]].directions!,
                Direction(1, 0),
                colors.first,
                start[0],
                start[1]);
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    parse();
    Timer.periodic(const Duration(milliseconds: 250), tick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridDrawer(grid, width),
      ),
    );
  }

  @override
  Iterable<GridCell> get allNodes => grid.toList();

  @override
  num getDistance(GridCell a, GridCell b) {
    return b is CarRoad ? 2 : 1;
  }

  @override
  num getHeuristicDistance(GridCell a, GridCell b) {
    return 1;
  }

  @override
  Iterable<GridCell> getNeighboursOf(GridCell node) sync* {
    if (node.x > 0 &&
        node.directions!.any((x) => x.dx == -1) &&
        grid[(node.y * width + node.x) - 1] is Road) {
      //("$node - 1");
      yield grid[(node.y * width + node.x) - 1];
    }
    if (node.y > 0 &&
        node.directions!.any((x) => x.dy == -1) &&
        grid[(node.y * width + node.x) - width] is Road) {
      //("$node - w");
      yield grid[(node.y * width + node.x) - width];
    }
    if (node.y < (grid.length ~/ width) - 1 &&
        node.directions!.any((x) => x.dy == 1) &&
        grid[(node.y * width + node.x) + width] is Road) {
      //("$node + w");
      yield grid[(node.y * width + node.x) + width];
    }
    if (node.x < width - 1 &&
        node.directions!.any((x) => x.dx == 1) &&
        grid[(node.y * width + node.x) + 1] is Road) {
      //("$node + 1");
      yield grid[(node.y * width + node.x) + 1];
    }
  }
}

class Destination {
  Destination(this.x, this.y, this.color);
  final int x;
  final int y;
  final Color color;
}
