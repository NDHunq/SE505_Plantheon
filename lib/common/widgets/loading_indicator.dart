import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? padding;

  const LoadingIndicator({Key? key, this.size = 48, this.padding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Image.asset(
          'assets/gif/spin.gif',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
