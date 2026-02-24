import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/helpers/scroll_behavior.dart';
import 'package:nethive_neo/internationalization/internationalization.dart';
import 'package:nethive_neo/router/router.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await initGlobals();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLevelProvider()),
        ChangeNotifierProvider(create: (_) => IncidenciaProvider()),
        ChangeNotifierProvider(create: (_) => BandejaIAProvider()),
        ChangeNotifierProvider(create: (_) => TecnicoProvider()),
        ChangeNotifierProvider(create: (_) => InventarioProvider()),
        ChangeNotifierProvider(create: (_) => SlaProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => AuditoriaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es', 'MX');
  ThemeMode _themeMode = AppTheme.themeMode;

  void setLocale(Locale value) => setState(() => _locale = value);
  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MaterialApp.router(
        title: 'Terranex — Smart City Operations',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'MX')],
        theme:
            ThemeData(brightness: Brightness.light, dividerColor: Colors.grey),
        darkTheme:
            ThemeData(brightness: Brightness.dark, dividerColor: Colors.grey),
        themeMode: _themeMode,
        routerConfig: router,
        scrollBehavior: MyCustomScrollBehavior(),
      ),
    );
  }
}
