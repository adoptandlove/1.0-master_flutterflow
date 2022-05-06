import 'package:flutter/material.dart';

class AppProgressIndicator extends StatelessWidget {
  final Color color;

  const AppProgressIndicator({
    Key key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: this.color != null ? this.color : baseTheme.primaryColor),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}
