import 'package:flutter/material.dart';
import '../services/widget_service.dart';
import '../widgets/widget_card.dart';

class WidgetListScreen extends StatefulWidget {
  const WidgetListScreen({super.key});

  @override
  State<WidgetListScreen> createState() => _WidgetListScreenState();
}

class _WidgetListScreenState extends State<WidgetListScreen> {
  final WidgetService _widgetService = WidgetService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _widgetService.addListener(_onWidgetServiceChanged);
    _initializeWidgets();
  }

  Future<void> _initializeWidgets() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await _widgetService.loadWidgets();
    }
  }

  @override
  void dispose() {
    _widgetService.removeListener(_onWidgetServiceChanged);
    super.dispose();
  }

  void _onWidgetServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Widgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _widgetService.refreshAllWidgets();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _widgetService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _widgetService.widgets.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => _widgetService.refreshAllWidgets(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _widgetService.widgets.length,
                      itemBuilder: (context, index) {
                        final widget = _widgetService.widgets[index];
                        return WidgetCard(
                          widget: widget,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/config',
                              arguments: widget.id,
                            );
                          },
                          onRefresh: () {
                            _widgetService.refreshWidget(widget.id);
                          },
                          onDelete: () {
                            _showDeleteDialog(context, widget.id, widget.name);
                          },
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Widget'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.widgets_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No widgets yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first widget to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/create');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Widget'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String widgetId, String widgetName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Widget'),
        content: Text('Are you sure you want to delete "$widgetName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _widgetService.deleteWidget(widgetId);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}