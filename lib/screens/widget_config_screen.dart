import 'package:flutter/material.dart';
import '../services/widget_service.dart';
import '../models/api_widget.dart';
import '../services/api_service.dart';

class WidgetConfigScreen extends StatefulWidget {
  const WidgetConfigScreen({super.key});

  @override
  State<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends State<WidgetConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _apiUrlController;
  late TextEditingController _dataPathController;
  final WidgetService _widgetService = WidgetService();
  
  late Color _selectedColor;
  late int _refreshInterval;
  bool _isValidating = false;
  String? _validationMessage;
  ApiWidget? _widget;

  final List<Color> _colorOptions = [
    const Color(0xFF6750A4),
    const Color(0xFF00677F),
    const Color(0xFF0D47A1),
    const Color(0xFF388E3C),
    const Color(0xFFFF6F00),
    const Color(0xFFD32F2F),
    const Color(0xFF7B1FA2),
    const Color(0xFF455A64),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_widget == null) {
      final widgetId = ModalRoute.of(context)?.settings.arguments as String?;
      if (widgetId != null) {
        _widget = _widgetService.getWidget(widgetId);
        if (_widget != null) {
          _initializeControllers();
        }
      }
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: _widget!.name);
    _apiUrlController = TextEditingController(text: _widget!.apiUrl);
    _dataPathController = TextEditingController(text: _widget!.dataPath);
    _selectedColor = _widget!.color;
    _refreshInterval = _widget!.refreshInterval;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiUrlController.dispose();
    _dataPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_widget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Widget Configuration')),
        body: const Center(child: Text('Widget not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildPreviewCard(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Widget Information',
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Widget Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a widget name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiUrlController,
                  decoration: InputDecoration(
                    labelText: 'API URL',
                    border: const OutlineInputBorder(),
                    suffixIcon: _isValidating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: _validateApiUrl,
                          ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an API URL';
                    }
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                if (_validationMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationMessage!,
                    style: TextStyle(
                      color: _validationMessage!.contains('valid')
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dataPathController,
                  decoration: const InputDecoration(
                    labelText: 'Data Path (optional)',
                    hintText: 'data.value or items.0.name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Appearance',
              children: [
                const Text('Color'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colorOptions.map((color) {
                    final isSelected = color == _selectedColor;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Refresh Settings',
              children: [
                Text('Refresh interval: ${_getRefreshIntervalText()}'),
                Slider(
                  value: _refreshInterval.toDouble(),
                  min: 60,
                  max: 3600,
                  divisions: 11,
                  onChanged: (value) {
                    setState(() {
                      _refreshInterval = value.toInt();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _updateWidget,
              child: const Text('Update Widget'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _nameController.text.isEmpty ? 'Widget Name' : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _widget!.cachedData ?? 'No data available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${_formatDateTime(_widget!.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  String _getRefreshIntervalText() {
    if (_refreshInterval < 60) {
      return '${_refreshInterval}s';
    } else if (_refreshInterval < 3600) {
      return '${(_refreshInterval / 60).round()}m';
    } else {
      return '${(_refreshInterval / 3600).round()}h';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _validateApiUrl() async {
    if (_apiUrlController.text.isEmpty) return;

    setState(() {
      _isValidating = true;
      _validationMessage = null;
    });

    try {
      final isValid = await ApiService.validateApiUrl(_apiUrlController.text);
      setState(() {
        _validationMessage = isValid ? 'API URL is valid' : 'API URL is not accessible';
      });
    } catch (e) {
      setState(() {
        _validationMessage = 'Error validating API URL';
      });
    } finally {
      setState(() {
        _isValidating = false;
      });
    }
  }

  void _updateWidget() {
    if (_formKey.currentState!.validate()) {
      final updatedWidget = _widget!.copyWith(
        name: _nameController.text,
        apiUrl: _apiUrlController.text,
        dataPath: _dataPathController.text,
        color: _selectedColor,
        refreshInterval: _refreshInterval,
        lastUpdated: DateTime.now(),
      );

      _widgetService.updateWidget(updatedWidget);
      Navigator.pop(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete "${_widget!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _widgetService.deleteWidget(_widget!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}