import 'package:flutter/material.dart';

const kLogoColors = {
  'background': Color(0xFFF5F2EB),
  'backgroundLogin': Color(0xFFFDF7EF),
  'redOrange': Color(0xFFE85D4C),
  'yellowOrange': Color(0xFFF0A84A),
  'green': Color(0xFF5DB87A),
  'teal': Color(0xFF3BA99A),
  'darkTeal': Color(0xFF2D8B7E),
  'title': Color(0xFF2C2C2C),
  'subtitle': Color(0xFF5A5A5A),
  'stickerYellow': Color(0xFFF7E98E),
  'stickerBlue': Color(0xFFA8D0E6),
  'signUpPink': Color(0xFFD85A6A),
};

class Logo extends StatelessWidget {
  final bool small;

  const Logo({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    const barColors = [
      kLogoColors['redOrange']!,
      kLogoColors['yellowOrange']!,
      kLogoColors['green']!,
      kLogoColors['teal']!,
      kLogoColors['darkTeal']!,
    ];
    const rotations = [-8.0, -4.0, 0.0, 4.0, 8.0];
    final barWidth = small ? 12.0 : 14.0;
    final barHeight = small ? 36.0 : 48.0;
    final gap = small ? 5.0 : 6.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Transform.rotate(
          angle: rotations[i] * 3.14159 / 180,
          child: Container(
            width: barWidth,
            height: barHeight,
            margin: EdgeInsets.only(right: i < 4 ? gap : 0),
            decoration: BoxDecoration(
              color: barColors[i],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
