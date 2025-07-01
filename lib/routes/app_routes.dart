import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/item_details_screen/item_details_screen.dart';
import '../presentation/search_screen/search_screen.dart';
import '../presentation/post_item_screen/post_item_screen.dart';
import '../presentation/verification_screen/verification_screen.dart';
import '../presentation/messages_screen/messages_screen.dart';
import '../presentation/admin_panel_screen/admin_panel_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String authenticationScreen = '/authentication-screen';
  static const String homeScreen = '/home-screen';
  static const String profileScreen = '/profile-screen';
  static const String itemDetailsScreen = '/item-details-screen';
  static const String searchScreen = '/search-screen';
  static const String postItemScreen = '/post-item-screen';
  static const String verificationScreen = '/verification-screen';
  static const String messagesScreen = '/messages-screen';
  static const String adminPanelScreen = '/admin-panel-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    authenticationScreen: (context) => const AuthenticationScreen(),
    homeScreen: (context) => const HomeScreen(),
    profileScreen: (context) => const ProfileScreen(),
    itemDetailsScreen: (context) => const ItemDetailsScreen(),
    searchScreen: (context) => const SearchScreen(),
    postItemScreen: (context) => const PostItemScreen(),
    verificationScreen: (context) => const VerificationScreen(),
    messagesScreen: (context) => const MessagesScreen(),
    adminPanelScreen: (context) => const AdminPanelScreen(),
  };
}