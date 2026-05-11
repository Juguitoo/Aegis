import 'dart:io';
import 'dart:ui';
import 'package:aegis/core/providers/general_providers.dart';
import 'package:aegis/core/services/notification_service.dart';
import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/presentation/screens/main_desktop_layout.dart';
import 'package:aegis/presentation/screens/main_mobile_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  await NotificationService.init();
  await NotificationService.requestPermissions();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(1200, 750),
      center: true,
      title: 'Aegis Productivity',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const ProviderScope(child: AegisApp()));
}

class AegisApp extends ConsumerWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el factor de escala interno de la app
    final textScale = ref.watch(textScaleProvider);

    return MaterialApp(
      title: 'Aegis Productivity',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      themeMode: ref.watch(themeModeProvider),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        );
      },
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MainMobileLayout();
          } else {
            return const MainDesktopLayout();
          }
        },
      ),
    );
  }
}
