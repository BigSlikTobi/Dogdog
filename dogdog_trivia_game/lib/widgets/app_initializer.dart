import 'package:flutter/material.dart';
import '../services/image_service.dart';

/// Widget that handles app initialization including image preloading
class AppInitializer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onInitializationComplete;

  const AppInitializer({
    super.key,
    required this.child,
    this.onInitializationComplete,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initializationStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initializationStatus = 'Loading images...';
      });

      // Add a small delay to ensure the loading screen is visible
      await Future.delayed(const Duration(milliseconds: 100));

      // Preload critical images
      await ImageService.preloadCriticalImages(context);

      setState(() {
        _initializationStatus = 'Ready!';
      });

      // Add another small delay before showing the child
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        _isInitialized = true;
      });

      widget.onInitializationComplete?.call();
    } catch (error) {
      debugPrint('App initialization error: $error');
      // Continue anyway - images will load on demand
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _initializationStatus,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
