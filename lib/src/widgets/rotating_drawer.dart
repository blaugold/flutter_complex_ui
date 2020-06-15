import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef RotatingDrawerHeaderBuilder = PreferredSizeWidget Function(
  BuildContext context,
  Animation<double> animation,
);

class RotatingDrawer extends StatefulWidget {
  RotatingDrawer({
    @required this.drawer,
    @required this.content,
    this.header,
    this.drawerWidth = 300,
  })  : assert(drawer != null),
        assert(content != null),
        assert(drawerWidth != null);

  final RotatingDrawerHeaderBuilder header;
  final Widget drawer;
  final Widget content;
  final double drawerWidth;

  @override
  RotatingDrawerState createState() => RotatingDrawerState();
}

class RotatingDrawerState extends State<RotatingDrawer>
    with SingleTickerProviderStateMixin {
  static RotatingDrawerState of(BuildContext context) =>
      context.findAncestorStateOfType<RotatingDrawerState>();

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = _animationController;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> toggle() {
    setState(() {
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
    });
    return _animationController.isDismissed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget header;
    header = widget.header != null
        ? MediaQuery.removePadding(
            context: context,
            child: Builder(
              builder: (context) {
                final header = widget.header(context, _animation);
                return Container(
                  height: header.preferredSize.height +
                      MediaQuery.of(this.context).viewPadding.vertical,
                  child: header,
                );
              },
            ),
          )
        : Container(height: 0);

    final drawerWidth = widget.drawerWidth;
    final rotatingEdgeWidth = 1.0;
    final perspective = .001;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _animation,
          builder: (context, _) => SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Tween(
                    end: drawerWidth,
                    begin: constraints.maxWidth,
                  ).evaluate(_animation),
                  child: header,
                ),
                Flexible(
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset:
                            Offset(-drawerWidth * (1 - _animation.value), 0),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, perspective)
                            ..rotateY(math.pi * .5 * (1 - _animation.value)),
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: drawerWidth),
                            child: widget.drawer,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(drawerWidth * _animation.value, 0),
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, perspective)
                            ..rotateY(-math.pi * .5 * _animation.value),
                          alignment: Alignment.centerLeft,
                          child: widget.content,
                        ),
                      ),
                      // Add a small blurred line, where drawer and content meet,
                      // when rotating. Otherwise the background bleeds through
                      // sometimes.
                      if (_animation.value > 0 && _animation.value < 1)
                        Transform.translate(
                          offset: Offset(
                            drawerWidth * _animation.value -
                                (rotatingEdgeWidth / 2),
                            0,
                          ),
                          child: ClipRect(
                            clipBehavior: Clip.antiAlias,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: rotatingEdgeWidth,
                                sigmaY: rotatingEdgeWidth,
                              ),
                              child: Container(
                                width: rotatingEdgeWidth,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails event) {
    // TODO
    setState(() {
      _animation = _animationController;
    });
  }

  void _onDragUpdate(DragUpdateDetails event) {
    _animationController.value +=
        event.primaryDelta / MediaQuery.of(context).size.width;
  }

  void _onDragEnd(DragEndDetails event) {
    if (_animationController.isDismissed || _animationController.isCompleted)
      return;

    final visualVelocity =
        event.primaryVelocity / MediaQuery.of(context).size.width;
    _animationController.fling(velocity: visualVelocity);
  }
}
