import 'package:flutter/material.dart';

import 'slider_paint.dart';

class CircleSlider extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final EdgeInsetsGeometry backgroundMargin;
  final BorderRadiusGeometry backgroundBorderRadius;
  final double sliderSize;
  final Color sliderColor;
  final double sliderPercentage;
  final double textSize;
  final Color textColor;
  final String textFamily;
  final AnimationController sliderController;

  CircleSlider({
    Key key,
    @required this.width,
    @required this.height,
    @required this.backgroundColor,
    @required this.backgroundMargin,
    @required this.backgroundBorderRadius,
    @required this.sliderSize,
    @required this.sliderColor,
    @required this.sliderPercentage,
    this.textSize = 15.0,
    this.textColor = Colors.black,
    this.textFamily = "ConcertOne-Regular",
   this.sliderController,
  }) : super(key: key);

  _CircleSliderState createState() => _CircleSliderState(
        width,
        height,
        backgroundColor,
        backgroundMargin,
        backgroundBorderRadius,
        sliderSize,
        sliderColor,
        sliderPercentage,
        textSize,
        textColor,
        textFamily,
        sliderController,
      );
}

class _CircleSliderState extends State<CircleSlider>
    with SingleTickerProviderStateMixin {
  double width;
  double height;
  Color backgroundColor;
  double sliderSize;
  Color sliderColor;
  double sliderPercentage;
  double textSize;
  Color textColor;
  String textFamily;
  AnimationController sliderController;
  EdgeInsetsGeometry backgroundMargin;
  BorderRadiusGeometry backgroundBorderRadius;

  Animation<double> percentageAnimation;

  _CircleSliderState(this.width,
    this.height,
    this.backgroundColor,
    this.backgroundMargin,
    this.backgroundBorderRadius,
    this.sliderSize,
    this.sliderColor,
    this.sliderPercentage,
    this.textSize,
    this.textColor,
    this.textFamily,
    this.sliderController,);

  @override
  void initState() {
    super.initState();

     if(sliderController != null)
      {
        
    percentageAnimation = Tween(
      begin: 0.0,
      end: sliderPercentage,
    ).animate(sliderController);
      }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: backgroundMargin,
      decoration: BoxDecoration(
        borderRadius: backgroundBorderRadius,
        color: backgroundColor,
        shape: BoxShape.rectangle,
      ),
      child: sliderController != null ? AnimatedBuilder(
        animation: sliderController,
        builder: (context, widget) {
          return CustomPaint(
            painter: SliderPaint(
              percentageAnimation.value,
              sliderSize,
              sliderColor,
            ),
            child: Container(
              width: width,
              height: height,
              child: Center(
                child: Text(
                  percentageAnimation.value.floor().toString() + "%",
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontFamily: textFamily,
                  ),
                ),
              ),
            ),
          );
        },
      ) : CustomPaint(
            painter: SliderPaint(
              sliderPercentage,
              sliderSize,
              sliderColor,
            ),
            child: Container(
              width: width,
              height: height,
              child: Center(
                child: Text(
                  sliderPercentage.floor().toString() + "%",
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontFamily: textFamily,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
