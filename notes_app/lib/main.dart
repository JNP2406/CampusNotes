import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/providers/auth.provider.dart';
import 'package:notes_app/screens/auth/login_screen.dart';
import 'package:notes_app/screens/auth/register_screen.dart';
import 'package:notes_app/screens/notes/home_screen.dart';
import 'package:notes_app/screens/notes/semester_screen.dart';
import 'package:notes_app/screens/notes/course_screen.dart';
import 'package:notes_app/screens/friends/friends_screen.dart';
import 'package:notes_app/screens/friends/profile_screen.dart';
import 'package:notes_app/screens/notes/create_semester_screen.dart';
import 'package:notes_app/screens/notes/create_course_screen.dart';
import 'package:notes_app/screens/friends/search_friend_screen.dart';
import 'package:notes_app/screens/friends/friend_notes_screen.dart';
import 'package:notes_app/screens/friends/friend_semester_screen.dart';
import 'package:notes_app/screens/friends/friend_course_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class _NoTransitionBuilder extends PageTransitionsBuilder {
  const _NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoTransitionBuilder(),
            TargetPlatform.iOS: _NoTransitionBuilder(),
          },
        ),
      ),
      initialRoute: '/register',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/semester': (context) => const SemesterScreen(),
        '/course': (context) => const CourseScreen(),
        '/friends': (context) => const FriendsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/create-semester': (context) => const CreateSemesterScreen(),
        '/create-course': (context) => const CreateCourseScreen(),
        '/search-friend': (context) => const SearchFriendScreen(),
        '/friend-notes': (context) => const FriendNotesScreen(),
        '/friend-semester': (context) => const FriendSemesterScreen(),
        '/friend-course': (context) => const FriendCourseScreen(),
      },
    );
  }
}