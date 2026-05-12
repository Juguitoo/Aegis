import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/blacklist_repository.dart';
import 'package:aegis/presentation/viewmodels/blacklist_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'blacklist_viewmodel_test.mocks.dart';

@GenerateMocks([InstalledApps, PackageInfo, BlacklistRepository])
void main() {
  group('BlacklistViewModel', () {
    late MockBlacklistRepository mockBlacklistRepository;
    late ProviderContainer container;

    setUp(() {
      mockBlacklistRepository = MockBlacklistRepository();
      container = ProviderContainer(
        overrides: [
          blacklistRepositoryProvider
              .overrideWithValue(mockBlacklistRepository),
        ],
      );

      PackageInfo.setMockInitialValues(
        appName: "Aegis",
        packageName: "com.example.aegis",
        version: "1.0",
        buildNumber: "1",
        buildSignature: "buildSignature",
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('blacklist is fetched from repository', () {
      final blacklist = ['com.example.app1', 'com.example.app2'];

      when(mockBlacklistRepository.watchBlacklistedPackages())
          .thenAnswer((_) => Stream.value(blacklist));

      final listener = container.listen(blacklistViewModelProvider, (_, __) {});

      expect(
        listener.read(),
        const AsyncValue<List<String>>.loading(),
      );
    });

    test('toggleAppStatus adds app to blacklist', () async {
      const packageName = 'com.example.newapp';
      const appName = 'New App';

      when(mockBlacklistRepository.addAppToBlacklist(packageName, appName))
          .thenAnswer((_) => Future.value(1));

      await container
          .read(blacklistViewModelProvider.notifier)
          .toggleAppStatus(packageName, appName, false);

      verify(mockBlacklistRepository.addAppToBlacklist(packageName, appName))
          .called(1);
    });

    test('toggleAppStatus removes app from blacklist', () async {
      const packageName = 'com.example.existingapp';
      const appName = 'Existing App';

      when(mockBlacklistRepository.removeAppFromBlacklist(packageName))
          .thenAnswer((_) => Future.value(1));

      await container
          .read(blacklistViewModelProvider.notifier)
          .toggleAppStatus(packageName, appName, true);

      verify(mockBlacklistRepository.removeAppFromBlacklist(packageName))
          .called(1);
    });
  });
}
