import 'package:flutter/material.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/item_details_screen/item_details_screen.dart';
import '../presentation/search_screen/search_screen.dart';
import '../presentation/post_item_screen/post_item_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String authenticationScreen = '/authentication-screen';
  static const String homeScreen = '/home-screen';
  static const String profileScreen = '/profile-screen';
  static const String itemDetailsScreen = '/item-details-screen';
  static const String searchScreen = '/search-screen';
  static const String postItemScreen = '/post-item-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => AuthenticationScreen(),
    authenticationScreen: (context) => AuthenticationScreen(),
    homeScreen: (context) => HomeScreen(),
    profileScreen: (context) => ProfileScreen(),
    itemDetailsScreen: (context) => ItemDetailsScreen(),
    searchScreen: (context) => SearchScreen(),
    postItemScreen: (context) => PostItemScreen(),
    // TODO: Add your other routes here
  };
}
