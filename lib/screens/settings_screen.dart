import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoRefreshEnabled = true;
  bool _notificationsEnabled = true;
  int _defaultRefreshInterval = 300;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoRefreshEnabled = prefs.getBool('auto_refresh') ?? true;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _defaultRefreshInterval = prefs.getInt('default_refresh_interval') ?? 300;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_refresh', _autoRefreshEnabled);
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setInt('default_refresh_interval', _defaultRefreshInterval);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Widget Settings',
            children: [
              SwitchListTile(
                title: const Text('Auto Refresh'),
                subtitle: const Text('Automatically refresh widgets'),
                value: _autoRefreshEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoRefreshEnabled = value;
                  });
                  _saveSettings();
                },
              ),
              ListTile(
                title: const Text('Default Refresh Interval'),
                subtitle: Text(_getRefreshIntervalText()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showRefreshIntervalDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get notified when widgets fail to update'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Licenses'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Data',
            children: [
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Remove all widgets and settings'),
                trailing: const Icon(Icons.warning, color: Colors.red),
                onTap: () => _showClearDataDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  String _getRefreshIntervalText() {
    if (_defaultRefreshInterval < 60) {
      return '${_defaultRefreshInterval} seconds';
    } else if (_defaultRefreshInterval < 3600) {
      return '${(_defaultRefreshInterval / 60).round()} minutes';
    } else {
      return '${(_defaultRefreshInterval / 3600).round()} hours';
    }
  }

  void _showRefreshIntervalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Refresh Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${_getRefreshIntervalText()}'),
            const SizedBox(height: 16),
            Slider(
              value: _defaultRefreshInterval.toDouble(),
              min: 60,
              max: 3600,
              divisions: 11,
              onChanged: (value) {
                setState(() {
                  _defaultRefreshInterval = value.toInt();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your widgets and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}