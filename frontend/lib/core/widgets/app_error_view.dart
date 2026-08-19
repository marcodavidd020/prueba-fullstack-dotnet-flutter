import 'package:flutter/material.dart';
import 'package:sol_catalog/core/error/failure.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    required this.failure,
    this.onRetry,
    super.key,
  });

  final Failure failure;

  final VoidCallback? onRetry;

  IconData get _icon => switch (failure) {
    NetworkFailure() => Icons.cloud_off_outlined,
    NotFoundFailure() => Icons.search_off_outlined,
    UnauthorizedFailure() => Icons.lock_outline,
    ConflictFailure() => Icons.sync_problem_outlined,
    ValidationFailure() => Icons.error_outline,
    _ => Icons.warning_amber_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 56, color: scheme.error),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: texts.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
