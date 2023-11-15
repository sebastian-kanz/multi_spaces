import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlideAction extends StatelessWidget {
  const SlideAction({
    Key? key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.fct,
    this.flex = 1,
  }) : super(key: key);

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final int flex;
  final Function fct;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      flex: flex,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onPressed: (BuildContext context) => fct(context),
      icon: icon,
      label: label,
    );
  }
}
