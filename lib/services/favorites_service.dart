import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_recipes';

  Future<List<Meal>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null) {
      return [];
    }

    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.map((json) => Meal.fromJson(json)).toList();
  }

  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();
    return favorites.any((meal) => meal.idMeal == mealId);
  }

  Future<void> toggleFavorite(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    final index = favorites.indexWhere((m) => m.idMeal == meal.idMeal);

    if (index != -1) {
      favorites.removeAt(index);
    } else {
      favorites.add(meal);
    }

    final String favoritesJson = json.encode(
      favorites.map((m) => m.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, favoritesJson);
  }

  Future<void> addFavorite(Meal meal) async {
    final favorites = await getFavorites();
    if (!favorites.any((m) => m.idMeal == meal.idMeal)) {
      favorites.add(meal);
      final prefs = await SharedPreferences.getInstance();
      final String favoritesJson = json.encode(
        favorites.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    }
  }

  Future<void> removeFavorite(String mealId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((m) => m.idMeal == mealId);

    final prefs = await SharedPreferences.getInstance();
    final String favoritesJson = json.encode(
      favorites.map((m) => m.toJson()).toList(),
    );
    await prefs.setString(_favoritesKey, favoritesJson);
  }
}
