import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle bodyText = TextStyle(color: AppColors.darkText);

  static const TextStyle linkText = TextStyle(
    color: AppColors.primary,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hintText = TextStyle(color: AppColors.grey);
}
