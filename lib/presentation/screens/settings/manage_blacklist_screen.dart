import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/blacklist_viewmodel.dart';

class ManageBlacklistScreen extends ConsumerWidget {
  const ManageBlacklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Platform.isAndroid) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          title: const Text('Lista Negra',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text(
            'El bloqueo de aplicaciones solo está disponible en Android.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
          ),
        ),
      );
    }

    final installedAppsAsync = ref.watch(installedAppsProvider);
    final blacklistedPackagesAsync = ref.watch(blacklistViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Bloqueo de Aplicaciones',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        shadowColor: const Color.fromARGB(25, 0, 0, 0),
      ),
      body: installedAppsAsync.when(
        data: (apps) {
          final blacklistedPackages = blacklistedPackagesAsync.value ?? [];

          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final isBlacklisted =
                  blacklistedPackages.contains(app.packageName);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isBlacklisted
                        ? const Color.fromARGB(75, 239, 68, 68)
                        : const Color(0xFFE2E8F0),
                    width: isBlacklisted ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: app.icon != null
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(app.icon!),
                          backgroundColor: Colors.transparent,
                        )
                      : const CircleAvatar(child: Icon(Icons.android)),
                  title: Text(
                    app.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  subtitle: Text(
                    app.packageName,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  trailing: Switch(
                    value: isBlacklisted,
                    activeThumbColor: const Color(0xFFEF4444),
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
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
