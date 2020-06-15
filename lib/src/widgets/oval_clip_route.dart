import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final _kOpacityTween = TweenSequence([
  TweenSequenceItem(
    tween: Tween(
      begin: .0,
      end: 1.0,
    ),
    weight: 20,
  ),
  TweenSequenceItem(
    weight: 80,
    tween: ConstantTween(1.0),
  ),
]);

class CircleClipRoute<T> extends PageRoute<T> {
  CircleClipRoute({
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

  Tween<Rect> _clipRectTween;

  final _childKey = GlobalKey();

  void _updateClipRectTween() {
    final renderBox = expandFrom.findRenderObject() as RenderBox;
    final navigatorBox = navigator.context.findRenderObject() as RenderBox;

    final expandFromRect =
        renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final navigatorRect =
        navigatorBox.localToGlobal(Offset.zero) & navigatorBox.size;

    final expansionCenter = expandFromRect.center;
    final expandedClipRectSide = [
          navigatorRect.topLeft - expansionCenter,
          navigatorRect.topRight - expansionCenter,
          navigatorRect.bottomLeft - expansionCenter,
          navigatorRect.bottomRight - expansionCenter,
        ].map((delta) => delta.distance).reduce(max) *
        2;

    final expandedClipRect = Rect.fromCenter(
      center: expandFromRect.center,
      height: expandedClipRectSide,
      width: expandedClipRectSide,
    );

    setState(() {
      _clipRectTween = RectTween(
        begin: expandFromRect,
        end: expandedClipRect,
      );
    });
  }

  @override
  TickerFuture didPush() {
    _updateClipRectTween();
    return super.didPush();
  }

  @override
  bool didPop(T result) {
    _updateClipRectTween();
    return super.didPop(result);
  }

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
    child = KeyedSubtree(key: _childKey, child: child);

    final clipRectAnimation = _clipRectTween.animate(animation);
    final transition = FadeTransition(
      opacity: _kOpacityTween.animate(animation),
      child: Stack(children: [
        _buildShadow(clipRectAnimation),
        _buildClip(clipRectAnimation, child),
        _buildDecoration(clipRectAnimation),
      ]),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) =>
            animation.isCompleted || animation.isDismissed ? child : transition,
      ),
    );
  }

  ClipOval _buildClip(Animation<Rect> clipRectAnimation, Widget child) {
    return ClipOval(
      clipper: _RectTransitionClipper(
        animation: clipRectAnimation,
      ),
      child: child,
    );
  }

  AnimatedBuilder _buildDecoration(Animation<Rect> clipRectAnimation) {
    return AnimatedBuilder(
      animation: clipRectAnimation,
      builder: (context, _) => Positioned.fromRect(
        rect: clipRectAnimation.value.inflate(1),
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  AnimatedBuilder _buildShadow(Animation<Rect> clipRectAnimation) {
    return AnimatedBuilder(
      animation: clipRectAnimation,
      builder: (context, _) => Positioned.fromRect(
        rect: clipRectAnimation.value,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RectTransitionClipper extends CustomClipper<Rect> {
  const _RectTransitionClipper({
    @required this.animation,
  })  : assert(animation != null),
        super(reclip: animation);

  final Animation<Rect> animation;

  @override
  Rect getClip(Size size) => animation.value;

  @override
  bool shouldReclip(_RectTransitionClipper old) => animation != old.animation;
}
