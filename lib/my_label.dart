import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyLabel extends StatelessWidget {
  final String title;
  final String subtitle;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  MyLabel(this.title, this.subtitle, {this.titleStyle, this.subtitleStyle});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = titleStyle ?? TextStyle(fontSize: 15);
    final TextStyle subtextStyle = subtitleStyle ??
        TextStyle(color: Theme.of(context).textTheme.headline1.color);
    return Column(
      children: [
        Text(
          subtitle,
          style: subtextStyle,
        ),
        Text(
          title,
          style: textStyle,
        )
      ],
    );
  }
}
