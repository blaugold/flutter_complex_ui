import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CircularClipRoute<T> extends PageRoute<T> {
  CircularClipRoute({
    @required this.expandFrom,
    @required this.builder,
    this.curve = Curves.easeInOutCubic,
    this.reverseCurve = Curves.easeInOutCubic,
    this.maintainState = false,
    this.transitionDuration = const Duration(milliseconds: 759),
  })  : assert(expandFrom != null),
        assert(builder != null),
        assert(curve != null),
        assert(reverseCurve != null),
        assert(maintainState != null),
        assert(transitionDuration != null);

  final BuildContext expandFrom;

  final WidgetBuilder builder;

  final Curve curve;

  final Curve reverseCurve;

  @override
  final bool maintainState;

  @override
  final Duration transitionDuration;

  // The expandFrom context is used when popping this route, to update the
  // _clipRectTween. This is necessary to handle changes to the layout of
  // the routes below this one (e.g. window is resized), therefore they must be
  // kept around.
  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: curve,
      reverseCurve: reverseCurve,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final renderBox = expandFrom.findRenderObject() as RenderBox;
    final navigatorBox = navigator.context.findRenderObject() as RenderBox;
    final expandingRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final contentRect =
        navigatorBox.localToGlobal(Offset.zero) & navigatorBox.size;

    return CircularClipTransition(
      animation: animation,
      expandingRect: expandingRect,
      contentRect: contentRect,
      child: child,
    );
  }
}

final _kOpacityTween = TweenSequence([
  TweenSequenceItem(
    tween: Tween(
      begin: .0,
      end: 1.0,
    ),
    weight: 10,
  ),
  TweenSequenceItem(
    weight: 90,
    tween: ConstantTween(1.0),
  ),
]);

final _kCircleBorderWidth = 2.0;

const _kCircleBackgroundDecoration = BoxDecoration(
  shape: BoxShape.circle,
  boxShadow: [
    const BoxShadow(
      color: Colors.black38,
      blurRadius: 100,
    ),
  ],
);

final _kCircleForegroundDecoration = BoxDecoration(
  shape: BoxShape.circle,
  border: Border.all(
    color: Colors.white,
    width: _kCircleBorderWidth,
  ),
);

class CircularClipTransition extends StatelessWidget {
  const CircularClipTransition({
    Key key,
    @required this.animation,
    @required this.expandingRect,
    @required this.contentRect,
    @required this.child,
  })  : assert(animation != null),
        assert(expandingRect != null),
        assert(contentRect != null),
        assert(child != null),
        super(key: key);

  final Animation<double> animation;
  final Rect expandingRect;
  final Rect contentRect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clipRectAnimation = _buildClipRectAnimation();

    return FadeTransition(
      opacity: _kOpacityTween.animate(animation),
      child: Stack(
        children: [
          _buildDecoration(clipRectAnimation, _kCircleBackgroundDecoration),
          _buildChildClipper(clipRectAnimation),
          _buildDecoration(clipRectAnimation, _kCircleForegroundDecoration),
        ],
      ),
    );
  }

  Animation<Rect> _buildClipRectAnimation() {
    final expandedClipCircleRadius = [
      contentRect.topLeft,
      contentRect.topRight,
      contentRect.bottomLeft,
      contentRect.bottomRight,
    ].map((corner) => (corner - expandingRect.center).distance).reduce(max);

    final expandedClipRectSide = expandedClipCircleRadius * 2;

    final expandedClipRect = Rect.fromCenter(
      center: expandingRect.center,
      height: expandedClipRectSide,
      width: expandedClipRectSide,
    );

    final clipRectTween = RectTween(
      begin: expandingRect,
      end: expandedClipRect,
    );

    return clipRectTween.animate(animation);
  }

  ClipOval _buildChildClipper(Animation<Rect> clipRectAnimation) {
    return ClipOval(
      clipper: _RectAnimationClipper(animation: clipRectAnimation),
      child: child,
    );
  }

  Widget _buildDecoration(
    Animation<Rect> clipRectAnimation,
    Decoration decoration,
  ) {
    return AnimatedBuilder(
      animation: clipRectAnimation,
      builder: (context, child) {
        return Positioned.fromRect(
          rect: clipRectAnimation.value.inflate(_kCircleBorderWidth),
          child: child,
        );
      },
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: decoration,
        ),
      ),
    );
  }
}

class _RectAnimationClipper extends CustomClipper<Rect> {
  _RectAnimationClipper({
    @required this.animation,
  })  : assert(animation != null),
        super(reclip: animation);

  final Animation<Rect> animation;

  @override
  Rect getClip(Size size) => animation.value;

  @override
  bool shouldReclip(_RectAnimationClipper oldClipper) =>
      animation != oldClipper.animation;
}
