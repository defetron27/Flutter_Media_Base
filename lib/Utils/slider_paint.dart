import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SliderPaint extends CustomPainter {
  double sliderPercentage;
  double sliderSize;
  Color sliderColor;

  SliderPaint(this.sliderPercentage, this.sliderSize, this.sliderColor);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    this.sliderPercentage = (sliderPercentage / 100) * 6.282;

    var paint = Paint();
    paint.color = sliderColor;

    var path = Path();

    path.addArc(
      Rect.fromCircle(
        center: Offset(
          width / 2,
          height / 2,
        ),
        radius: sliderSize + (sliderSize / 10),
      ),
      1.6,
      sliderPercentage,
    );

    path.lineTo(width / 2, height / 2);

    path.close();

    canvas.drawPath(path, paint);

    paint.color = Colors.grey[200];

    canvas.drawCircle(
      Offset(
        width / 2,
        height / 2,
      ),
      sliderSize,
      paint,
    );
  }

  @override
  bool shouldRepaint(SliderPaint oldDelegate) {
    return true;
  }
}
