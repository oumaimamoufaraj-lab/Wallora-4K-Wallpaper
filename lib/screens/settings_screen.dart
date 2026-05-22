import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _versionLabel = '…';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
    } catch (_) {
      if (mounted) setState(() => _versionLabel = '1.0.0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About & privacy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Wallora 4K Wallpaper',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text('Version $_versionLabel', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 24),
          const Text('Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'Wallora 4K Wallpaper shows bundled wallpapers only. We do not upload your images.\n\n'
            '• Photos: Used when you tap Like or Download to save a wallpaper.\n'
            '• Favorites: Stored only on this device.\n'
            '• No ads, no analytics SDKs, no sale of personal data.',
            style: TextStyle(color: Colors.grey.shade800, height: 1.45, fontSize: 15),
          ),
          const SizedBox(height: 24),
          const Text('Content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'You must own or license all artwork before publishing to the App Store.',
            style: TextStyle(color: Colors.grey.shade800, height: 1.45, fontSize: 15),
          ),
          const SizedBox(height: 24),
          const Text('App Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Text(
            'Host docs/PRIVACY_POLICY.md at a public URL for App Store Connect. '
            'Bundle ID: com.wallora.wallpaper.',
            style: TextStyle(color: Colors.grey.shade800, height: 1.45, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
