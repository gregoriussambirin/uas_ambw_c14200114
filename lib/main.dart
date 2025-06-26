import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas_c14200114/screens/auth/login_screen.dart';
import 'package:uas_c14200114/screens/get_started_screen.dart';
import 'package:uas_c14200114/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  
  await Supabase.initialize(
    
    url: 'https://lzezavgzydiuhmkbgjxb.supabase.co',
    
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6ZXphdmd6eWRpdWhta2JnanhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4Mzc1NjksImV4cCI6MjA2NjQxMzU2OX0.PTSpQ-YcqIBCpu9yuXzk3pMfxd8NMuMevA1amFbst2s',
    
  );

  
  final prefs = await SharedPreferences.getInstance();
  final bool hasRunBefore = prefs.containsKey('hasRunBefore');

  runApp(MyApp(hasRunBefore: hasRunBefore));
}

class MyApp extends StatelessWidget {
  final bool hasRunBefore;

  const MyApp({Key? key, required this.hasRunBefore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Recipe Keeper',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white, 
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          buttonColor: Colors.deepPurple,
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      
      initialRoute: hasRunBefore ? '/' : '/get_started',
      routes: {
        '/get_started': (context) => const GetStartedScreen(),
        '/': (context) {
          
          return StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (snapshot.hasData && snapshot.data!.session != null) {
                return const HomeScreen();
              } else {
                
                return const LoginScreen();
              }
            },
          );
        },
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
