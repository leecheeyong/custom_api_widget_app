import 'package:flutter/material.dart';
import '../services/widget_service.dart';
import '../models/api_widget.dart';
import '../services/api_service.dart';

class CreateWidgetScreen extends StatefulWidget {
  const CreateWidgetScreen({super.key});

  @override
  State<CreateWidgetScreen> createState() => _CreateWidgetScreenState();
}

class _CreateWidgetScreenState extends State<CreateWidgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiUrlController = TextEditingController();
  final _dataPathController = TextEditingController();
  final WidgetService _widgetService = WidgetService();
  
  Color _selectedColor = const Color(0xFF6750A4);
  int _refreshInterval = 300; // 5 minutes
  bool _isValidating = false;
  String? _validationMessage;

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
  void dispose() {
    _nameController.dispose();
    _apiUrlController.dispose();
    _dataPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Widget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSection(
              title: 'Widget Information',
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Widget Name',
                    hintText: 'Enter widget name',
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
                    hintText: 'https://api.example.com/data',
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
              onPressed: _createWidget,
              child: const Text('Create Widget'),
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

  void _createWidget() {
    if (_formKey.currentState!.validate()) {
      final widget = ApiWidget(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        apiUrl: _apiUrlController.text,
        dataPath: _dataPathController.text,
        color: _selectedColor,
        refreshInterval: _refreshInterval,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      _widgetService.addWidget(widget);
      Navigator.pop(context);
    }
  }
}