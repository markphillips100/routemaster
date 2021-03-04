part of '../routemaster.dart';

// TODO: This might be better called something else as it could be used for something other than tab bars
// Suggestions: IndexPlan, IndexedPlan, NestedPlan
class TabPlan extends RoutePlan {
  final String pathTemplate;
  final Widget Function(RouteInfo info, TabRouteState routeState) builder;
  final List<String> paths;

  TabPlan(
    this.pathTemplate,
    this.builder, {
    required this.paths,
  });

  @override
  RouteState createState(Routemaster delegate, RouteInfo routeInfo) {
    return TabRouteState(this, delegate, routeInfo);
  }
}

class TabRouteState extends SinglePageRouteState {
  final TabPlan plan;
  final Routemaster delegate;
  final RouteInfo routeInfo;

  TabRouteState(
    this.plan,
    this.delegate,
    this.routeInfo,
  ) {
    routes = plan.paths.map((path) {
      final elements = delegate._getAllRoutes(path).skip(1).toList();
      return _StackRouteState(delegate: delegate, routes: elements);
    }).toList();
  }

  int _index = 0;
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;
      delegate._markNeedsUpdate();
    }
  }

  late List<_StackRouteState> routes;

  int? getIndexForPath(String path) {
    int i = 0;
    for (String initialPath in plan.paths) {
      if (path.startsWith(initialPath)) {
        return i;
      }
      i++;
    }

    return null;
  }

  void setNewPath(List<RouteState> newRoutes) {
    final tabIndex = getIndexForPath(newRoutes[0].routeInfo.path)!;
    this.index = tabIndex;
    this.routes[tabIndex]._setRoutes(newRoutes);
    this.delegate._markNeedsUpdate();
  }

  @override
  RouteState get currentRoute {
    return routes[index].currentRoute;
  }

  @override
  Page createPage() {
    return MaterialPage<void>(
      child: plan.builder(routeInfo, this),
      key: ValueKey(routeInfo.path),
    );
  }

  @override
  bool maybeSetRoutes(Iterable<RouteState?> routes) {
    final newIndex = getIndexForPath(routes.toList()[0]!.routeInfo.path);
    if (newIndex == null) {
      return false;
    }

    this.index = index;
    this.routes[index]._setRoutes(routes.toList());
    return true;
  }

  @override
  bool maybePush(RouteState route) {
    final index = getIndexForPath(route.routeInfo.path);
    if (index == null) {
      return false;
    }

    this.routes[index].push(route);
    return true;
  }

  @override
  bool maybePop() {
    return routes[index].maybePop();
  }

  // Removed for now, might come back later
  // static TabRoute of(BuildContext context) {
  //   return context.dependOnInheritedWidgetOfExactType<_TabRouteWidget>()!.route;
  // }
}

// class _TabRouteWidget extends InheritedWidget {
//   final TabRoute route;

//   _TabRouteWidget({required this.route}) : assert(route != null), super(child: child);

//   @override
//   bool updateShouldNotify(covariant InheritedWidget oldWidget) {
//     return false;
//   }
// }
