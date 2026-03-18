import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/blacklist_repository.dart';

final installedAppsProvider = FutureProvider<List<AppInfo>>((ref) async {
  List<AppInfo> apps = await InstalledApps.getInstalledApps(
    excludeSystemApps: true,
    withIcon: true,
  );

  final packageInfo = await PackageInfo.fromPlatform();
  final myPackageName = packageInfo.packageName;

  apps.removeWhere((app) => app.packageName == myPackageName);

  apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return apps;
});

class BlacklistViewModel extends StreamNotifier<List<String>> {
  BlacklistRepository get _repository => ref.read(blacklistRepositoryProvider);

  @override
  Stream<List<String>> build() {
    return _repository.watchBlacklistedPackages();
  }

  Future<void> toggleAppStatus(
      String packageName, String appName, bool isCurrentlyBlacklisted) async {
    if (isCurrentlyBlacklisted) {
      await _repository.removeAppFromBlacklist(packageName);
    } else {
      await _repository.addAppToBlacklist(packageName, appName);
    }
  }
}

final blacklistViewModelProvider =
    StreamNotifierProvider<BlacklistViewModel, List<String>>(() {
  return BlacklistViewModel();
});
