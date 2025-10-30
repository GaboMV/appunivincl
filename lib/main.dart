import 'package:appuniv/database/database_service.dart';
import 'package:appuniv/features/login/presentation/login.dart';
import 'package:appuniv/widgets/start_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async{
    WidgetsFlutterBinding.ensureInitialized();
   // Initialize the database
 
 runApp(const ProviderScope(child: AppAccesible()));}
class AppAccesible extends StatelessWidget {
  const AppAccesible({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Inclusiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const AppStartUpWidget(),
    );
  }
}