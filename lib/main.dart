import 'package:flutter/material.dart';

import 'core/core_registry.dart';
import 'pages/metro_guide_editor_page.dart';
import 'pages/road_editor_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CoreRegistry.instance.initialize();
  runApp(const TrafficSignApp());
}

class TrafficSignApp extends StatelessWidget {
  const TrafficSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '标志设计器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '标志设计器',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(
                  context,
                  '轨道交通编辑器',
                  Icons.train,
                  const Color(0xFF001D31),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MetroGuideEditorPage(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _buildCard(
                  context,
                  '道路编辑器',
                  Icons.signpost,
                  const Color(0xFF1A1A2E),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoadEditorPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
