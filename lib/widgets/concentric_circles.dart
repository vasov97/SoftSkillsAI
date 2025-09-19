import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';

class ConcentricCircles extends StatelessWidget {
  const ConcentricCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Spoljašnji krug (samo border)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
            ),
          ),
          // Unutrašnji krug (popunjen)
          Container(
            width: 116,
            height: 116,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                context.l10n.getStarted,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
