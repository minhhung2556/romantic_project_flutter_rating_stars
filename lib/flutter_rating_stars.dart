library flutter_rating_stars;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/generated/assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StarRating extends StatefulWidget {
  final double maxValue;
  final double value;
  final int starCount;
  final double starSize;
  final Color valueLabelColor;
  final TextStyle valueLabelTextStyle;
  final double valueLabelRadius;
  final double starSpacing;
  final bool maxValueVisibility;
  final bool valueLabelVisibility;
  final Duration animationDuration;
  final EdgeInsets valueLabelPadding;
  final EdgeInsets valueLabelMargin;
  final Color starOffColor;
  final Color starColor;
  final Function(double value)? onValueChanged;
  final Widget Function(int index, Color? color)? starBuilder;

  const StarRating({
    Key? key,
    this.value = 0,
    this.starCount = 5,
    this.starSize = 20,
    this.valueLabelColor = const Color(0xff9b9b9b),
    this.valueLabelTextStyle = const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.normal,
        fontSize: 12.0),
    this.valueLabelRadius = 10,
    this.maxValue = 5,
    this.starSpacing = 2,
    this.maxValueVisibility = true,
    this.valueLabelVisibility = true,
    this.animationDuration = Duration.zero,
    this.valueLabelPadding =
        const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
    this.valueLabelMargin = const EdgeInsets.only(right: 8),
    this.starOffColor = const Color(0xffe7e8ea),
    this.starColor = Colors.yellow,
    this.onValueChanged,
    this.starBuilder,
  }) : super(key: key);

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: _calculateDuration());
    animationController!.forward(from: 0);
    super.initState();
  }

  Duration _calculateDuration() {
    var millis = (widget.animationDuration.inMilliseconds *
            widget.value /
            widget.maxValue)
        .round();
    return Duration(milliseconds: millis);
  }

  @override
  void didUpdateWidget(covariant StarRating oldWidget) {
    if (widget.value != oldWidget.value) {
      animationController!.duration = _calculateDuration();
      animationController!.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.valueLabelVisibility)
          Container(
            padding: widget.valueLabelPadding,
            margin: widget.valueLabelMargin,
            child: Text(
                "${widget.value.toStringAsPrecision(2)}${widget.maxValueVisibility ? '/${widget.maxValue.toStringAsPrecision(2)}' : ''}",
                style: widget.valueLabelTextStyle),
            decoration: BoxDecoration(
                color: widget.valueLabelColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(widget.valueLabelRadius)),
          ),
        Stack(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.starCount,
                (index) {
                  return Container(
                    margin: index == widget.starCount - 1
                        ? null
                        : EdgeInsets.symmetric(
                            horizontal: widget.starSpacing / 2),
                    alignment: Alignment.center,
                    child: _starWidget(index, true, widget.starOffColor),
                  );
                },
              ),
            ),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: animationController!,
                builder: (context, child) {
                  return ClipRect(
                    child: Container(
                      child: Align(
                        widthFactor: max(
                            0,
                            min(widget.maxValue.toDouble(),
                                widget.value / widget.maxValue)),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            widget.starCount,
                            (index) {
                              return Container(
                                margin: index == widget.starCount - 1
                                    ? null
                                    : EdgeInsets.symmetric(
                                        horizontal: widget.starSpacing / 2),
                                alignment: Alignment.center,
                                child: Transform.scale(
                                  scale: Tween<double>(begin: 0.0, end: 1.0)
                                      .chain(CurveTween(
                                          curve: Interval(0.15 * index, 1.0,
                                              curve: Curves.elasticOut)))
                                      .evaluate(animationController!),
                                  child: _starWidget(
                                      index, false, widget.starColor),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _starWidget(int index, bool action, [Color? color]) {
    var _star = widget.starBuilder != null
        ? SizedBox(
            child: widget.starBuilder!(index, color),
            width: widget.starSize,
            height: widget.starSize,
          )
        : SvgPicture.asset(
            Assets.assetsStarOff,
            width: widget.starSize,
            height: widget.starSize,
            package: 'flutter_rating_stars',
            color: color,
          );
    if (!action) return _star;
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.starSize / 2))),
        minimumSize: MaterialStateProperty.all<Size>(
            Size(widget.starSize, widget.starSize)),
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
        elevation: MaterialStateProperty.all<double>(0.0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        overlayColor:
            MaterialStateProperty.all<Color>(widget.starColor.withOpacity(0.2)),
        animationDuration: Duration(milliseconds: 100),
      ),
      onPressed: widget.onValueChanged == null
          ? null
          : () {
              var v = index + 1.0;
              print('_StarRatingState._starWidget.onValueChanged: $v');
              widget.onValueChanged!(v);
            },
      child: _star,
    );
  }
}
