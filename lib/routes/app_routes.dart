import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/books/add_book_screen.dart';
import '../screens/books/edit_book_screen.dart';

class AppRoutes {

  static const login = "/";
  static const register = "/register";
  static const home = "/home";
  static const addBook = "/addBook";
  static const editBook = "/editBook";

  static Map<String, WidgetBuilder> routes = {

    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    addBook: (context) => const AddBookScreen(),
    editBook: (context) => const EditBookScreen(),

  };
}