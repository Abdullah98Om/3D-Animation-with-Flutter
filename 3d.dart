import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

class RealisticPaperEffect extends StatefulWidget {
  @override
  _RealisticPaperEffectState createState() => _RealisticPaperEffectState();
}

class _RealisticPaperEffectState extends State<RealisticPaperEffect> {
  double pitch = 0.0, roll = 0.0;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;

    _sub = RotationSensor.orientationStream.listen((data) {
      setState(() {
        pitch = _clamp(data.eulerAngles.pitch, -0.3, 0.3);
        roll = _clamp(data.eulerAngles.roll, -0.3, 0.3);
      });
    });
  }

  double _clamp(double v, double minV, double maxV) =>
      v < minV ? minV : (v > maxV ? maxV : v);

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shadowOffset = Offset(
        roll * 33,
        // 0
        -pitch * 33);

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            children: [
              // الظل الخلفي
              Positioned.fill(
                child: Transform.translate(
                  offset: shadowOffset,
                  child: Opacity(
                    opacity: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Colors.white.withOpacity(0.1), // الإطار الخفيف
                            width: 1.5,
                          ),
                          color:
                              Colors.white.withOpacity(0.1), // الشفافية البيضاء
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: _buildImage(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // الصورة الأمامية
              Positioned.fill(
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.00003) // منظور
                      ..rotateY(roll)
                    // ..rotateX(-pitch)
                    ,
                    child: _buildImage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl:
              "https://img.freepik.com/free-photo/misurina-sunset_181624-34793.jpg?semt=ais_hybrid&w=740",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
