import 'package:flutter/material.dart';

/// A premium theme definition.
class AppTheme {
  final String id;
  final String name;
  final Color seedColor;
  final String description;

  const AppTheme({
    required this.id,
    required this.name,
    required this.seedColor,
    required this.description,
  });
}

/// All available themes for HealMind.
class AppThemes {
  AppThemes._();

  static const defaultTheme = AppTheme(
    id: 'default',
    name: 'Soft Lavender',
    seedColor: Color(0xFF9B8EC4),
    description: 'Calm & gentle — the original',
  );

  static const ocean = AppTheme(
    id: 'ocean',
    name: 'Ocean Calm',
    seedColor: Color(0xFF00897B),
    description: 'Deep teal — like ocean waves',
  );

  static const sunset = AppTheme(
    id: 'sunset',
    name: 'Sunset Glow',
    seedColor: Color(0xFFFF7043),
    description: 'Warm coral — golden hour',
  );

  static const forest = AppTheme(
    id: 'forest',
    name: 'Forest Peace',
    seedColor: Color(0xFF43A047),
    description: 'Rich green — nature\'s embrace',
  );

  static const rose = AppTheme(
    id: 'rose',
    name: 'Rose Bliss',
    seedColor: Color(0xFFEC407A),
    description: 'Soft pink — gentle & loving',
  );

  static const midnight = AppTheme(
    id: 'midnight',
    name: 'Midnight Sky',
    seedColor: Color(0xFF5C6BC0),
    description: 'Deep indigo — starry night',
  );

  static const all = [defaultTheme, ocean, sunset, forest, rose, midnight];

  static const premium = [ocean, sunset, forest, rose, midnight];

  static AppTheme byId(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTheme,
    );
  }
}