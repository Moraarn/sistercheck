import 'package:flutter/material.dart';

const double appRadius = 30.0;
const double appBorderRadius = 10.0;
const double appElevation = 10.0;
const double appPadding = 10.0;
const double appMargin = 10.0;
const double appIconSize = 24.0;
const double appIconButtonSize = 48.0;
const double appItemSpacing = 10.0;

class ProblemChipData {
  final String label;
  final IconData icon;
  final Color color;

  const ProblemChipData({
    required this.label,
    required this.icon,
    required this.color,
  });
}

const List<ProblemChipData> problemChips = [
  ProblemChipData(
    label: 'Engine Repair',
    icon: Icons.engineering,
    color: Colors.red,
  ),
  ProblemChipData(
    label: 'Transmission',
    icon: Icons.settings,
    color: Colors.indigo,
  ),
  ProblemChipData(
    label: 'Electrical Systems',
    icon: Icons.electric_bolt,
    color: Colors.amber,
  ),
  ProblemChipData(
    label: 'Brake Systems',
    icon: Icons.speed,
    color: Colors.blue,
  ),
  ProblemChipData(
    label: 'Suspension & Steering',
    icon: Icons.directions_car,
    color: Colors.purple,
  ),

  ProblemChipData(
    label: 'General Maintenance',
    icon: Icons.build,
    color: Colors.orange,
  ),
];
