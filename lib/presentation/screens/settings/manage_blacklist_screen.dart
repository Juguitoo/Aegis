import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/blacklist_viewmodel.dart';

class ManageBlacklistScreen extends ConsumerWidget {
  const ManageBlacklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!Platform.isAndroid) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Lista negra', style: textTheme.displayMedium),
        ),
        body: Center(
          child: Text(
            'El bloqueo de aplicaciones solo está disponible en Android.',
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final installedAppsAsync = ref.watch(installedAppsProvider);
    final blacklistedPackagesAsync = ref.watch(blacklistViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text('Bloqueo de aplicaciones', style: textTheme.displayMedium),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),
      body: Column(
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          Expanded(
            child: installedAppsAsync.when(
              data: (apps) {
                final blacklistedPackages =
                    blacklistedPackagesAsync.value ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isBlacklisted =
                        blacklistedPackages.contains(app.packageName);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isBlacklisted
                              ? colorScheme.error.withValues(alpha: 0.5)
                              : colorScheme.outline.withValues(alpha: 0.2),
                          width: isBlacklisted ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: app.icon != null
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(app.icon!),
                                backgroundColor: Colors.transparent,
                              )
                            : const CircleAvatar(child: Icon(Icons.android)),
                        title: Text(
                          app.name,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          app.packageName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Switch(
                          value: isBlacklisted,
                          activeThumbColor: colorScheme.error,
                          activeTrackColor:
                              colorScheme.error.withValues(alpha: 0.2),
                          inactiveTrackColor:
                              colorScheme.outline.withValues(alpha: 0.2),
                          onChanged: (value) {
                            ref
                                .read(blacklistViewModelProvider.notifier)
                                .toggleAppStatus(
                                  app.packageName,
                                  app.name,
                                  !value,
                                );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary)),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
