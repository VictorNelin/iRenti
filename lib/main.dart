import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/messages_bloc.dart';
import 'package:irenti/repository/catalog_repository.dart';
import 'package:irenti/repository/messages_repository.dart';
import 'package:irenti/repository/user_repository.dart';

import 'pages/auth/welcome.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/catalog/catalog.dart';
import 'pages/catalog/catalog_filter.dart';
import 'pages/catalog/catalog_filter_metro.dart';
import 'pages/catalog/catalog_info.dart';
import 'pages/catalog/catalog_single.dart';
import 'pages/catalog/map.dart';
import 'pages/messages/dialogs.dart';
import 'pages/messages/single_dialog.dart';
import 'pages/profile/profile.dart';
import 'pages/settings/settings.dart';

void main() {
  if (kReleaseMode) {
    debugPrint = (_, {wrapWidth}) {};
  }
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final UserRepository _userRepository = UserRepository();
  final CatalogRepository _catalogRepository = CatalogRepository();
  final MessagesRepository _messagesRepository = MessagesRepository();
  AuthenticationBloc _authenticationBloc;
  MessagesBloc _messagesBloc;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.add(AppStarted());
    _messagesBloc = MessagesBloc(messagesRepository: _messagesRepository);
  }

  @override
  void dispose() {
    _authenticationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(value: _userRepository),
        RepositoryProvider<MessagesRepository>.value(value: _messagesRepository),
        RepositoryProvider<CatalogRepository>.value(value: _catalogRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(builder: (_) => _authenticationBloc),
          BlocProvider<MessagesBloc>(builder: (_) => _messagesBloc),
        ],
        child: MaterialApp(
          title: 'iRenti',
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          builder: (context, child) {
            return ShowCaseWidget(
              builder: Builder(builder: (ctx) => child),
            );
          },
          home: BlocBuilder(
            bloc: _authenticationBloc,
            builder: (context, state) {
              if (state is Unauthenticated) {
                return WelcomePage();
              }
              if (state is Authenticated) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _messagesBloc.add(MessagesInitEvent(state.user.uid));
                  Navigator.pushReplacementNamed(context, '/main');
                });
              }
              return Material(child: SizedBox.expand());
            },
          ),
          routes: {
            '/login': (ctx) => const LoginPage(),
            '/register': (ctx) => const RegisterPage(),
            '/profile': (ctx) => const ProfilePage(),
            '/catalog': (ctx) => const CatalogPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/main') {
              return CupertinoPageRoute(
                builder: (ctx) => CupertinoTabScaffold(
                  tabBar: CupertinoTabBar(
                    currentIndex: settings.arguments ?? 0,
                    backgroundColor: const Color(0xff272d30),
                    activeColor: const Color(0x80ffffff),
                    inactiveColor: const Color(0xffffffff),
                    items: [
                      const BottomNavigationBarItem(icon: Icon(Icons.home)),
                      const BottomNavigationBarItem(icon: Icon(Icons.star)),
                      BottomNavigationBarItem(
                        icon: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            const Icon(Icons.message),
                            BlocBuilder(
                              bloc: _messagesBloc,
                              builder: (ctx, state) {
                                if (state is MessagesLoadedState && state.unreadCount > 0) {
                                  return Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFEF5353),
                                      ),
                                      alignment: Alignment.center,
                                      width: 16,
                                      height: 16,
                                      child: Text(
                                        state.unreadCount.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                      const BottomNavigationBarItem(icon: Icon(Icons.person)),
                    ],
                  ),
                  tabBuilder: (ctx, i) {
                    switch (i) {
                      case 0:
                        return const CatalogPage();
                      case 1:
                        return const CatalogPage(favorites: true);
                      case 2:
                        return const DialogsPage();
                      case 3:
                        return ProfilePage(firstRun: settings.arguments != null);
                    }
                    return Material(
                      child: Center(
                        child: Text('NYI', style: Theme.of(ctx).textTheme.display4),
                      ),
                    );
                  },
                ),
              );
            } else if (settings.name == '/catalog/info') {
              return CupertinoPageRoute(
                builder: (ctx) => CatalogInfoPage(entry: settings.arguments),
              );
            } else if (settings.name == '/catalog/filter') {
              return CupertinoPageRoute(
                builder: (ctx) => CatalogFilterPage(bloc: settings.arguments),
                fullscreenDialog: true,
              );
            } else if (settings.name == '/catalog/filter/metro') {
              return DefCupertinoPageRoute(
                builder: (ctx) => CatalogFilterMetroPage(initial: settings.arguments),
                fullscreenDialog: true,
                result: settings.arguments,
              );
            } else if (settings.name == '/catalog/profile') {
              return CupertinoPageRoute(
                builder: (ctx) => ProfilePage(user: settings.arguments),
              );
            } else if (settings.name == '/catalog/map') {
              return CupertinoPageRoute(
                builder: (ctx) => MapPage(entry: settings.arguments),
              );
            } else if (settings.name == '/catalog/single') {
              return CupertinoPageRoute(
                builder: (ctx) => CatalogSinglePage(entry: settings.arguments),
              );
            } else if (settings.name == '/dialog') {
              Map<String, dynamic> args = Map.from(settings.arguments);
              return CupertinoPageRoute(
                builder: (ctx) => DialogPage(
                  dialogId: args['id'],
                  title: args['title'],
                ),
              );
            } else if (settings.name == '/settings') {
              return CupertinoPageRoute(builder: (ctx) => const SettingsPage());
            }
            return CupertinoPageRoute(builder: (_) => const SizedBox());
          },
        ),
      ),
    );
  }
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    debugPrint(error.toString());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(transition.toString());
  }
}

ThemeData buildTheme(Brightness brightness) {
  bool dark = brightness == Brightness.dark;
  return ThemeData(
    brightness: brightness,
    primarySwatch: Colors.red,
    platform: TargetPlatform.iOS,
    accentColor: const Color(0xFFEF5353),
    backgroundColor: dark ? const Color(0xFF181818) : const Color(0xFFE7E7E7),
    canvasColor: dark ? Colors.black : null,
    cardColor: dark ? const Color(0xff272d30) : null,
    disabledColor: const Color(0xFFEF5353),
    unselectedWidgetColor: const Color(0xFFEF5353),
    typography: Typography(platform: TargetPlatform.iOS).copyWith(
      englishLike: Typography.englishLike2014.copyWith(
        headline: Typography.englishLike2014.headline.copyWith(
          fontWeight: FontWeight.bold,
        ),
        title: Typography.englishLike2014.title.copyWith(
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
        ),
        subhead: Typography.englishLike2014.subhead.copyWith(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ),
        body1: Typography.englishLike2014.body1.copyWith(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        body2: Typography.englishLike2014.body2.copyWith(
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
        button: Typography.englishLike2014.button.copyWith(
          fontSize: 13.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textTheme: (dark ? Typography.whiteCupertino : Typography.blackCupertino).apply(
      fontFamily: '.SF UI Display',
      displayColor: dark ? Colors.white : const Color(0xff272d30),
      bodyColor: dark ? Colors.white : const Color(0xff272d30),
    ).copyWith(
      button: Typography.whiteCupertino.button,
    ),
    buttonTheme: const ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      shape: StadiumBorder(),
      height: 48.0,
    ),
    appBarTheme: AppBarTheme(
      brightness: Brightness.dark,
      color: dark ? const Color(0xff272d30) : Colors.white,
      iconTheme: IconThemeData(
        color: dark ? Colors.white : const Color(0xff272d30),
      ),
      actionsIconTheme: IconThemeData(
        color: dark ? Colors.white : const Color(0xff272d30),
      ),
    ),
  );
}

class DefCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  DefCupertinoPageRoute({
    @required WidgetBuilder builder,
    String title,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
    this.result,
  }) : super(
    builder: builder,
    title: title,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );

  @override
  T get currentResult => result;
  T result;
}
