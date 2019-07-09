import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'pages/catalog/catalog_info.dart';
import 'pages/messages/dialogs.dart';
import 'pages/messages/single_dialog.dart';
import 'pages/profile/profile.dart';

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
    _authenticationBloc.dispatch(AppStarted());
    _messagesBloc = MessagesBloc(messagesRepository: _messagesRepository);
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(builder: (_) => _authenticationBloc),
        BlocProvider<MessagesBloc>(builder: (_) => _messagesBloc),
      ],
      child: MaterialApp(
        title: 'iRenti',
        theme: ThemeData(
          primarySwatch: Colors.red,
          platform: TargetPlatform.iOS,
          accentColor: const Color(0xFFEF5353),
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
          textTheme: Typography.blackCupertino.apply(
            fontFamily: '.SF UI Display',
          ).copyWith(
            button: Typography.whiteCupertino.button,
          ),
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
            shape: StadiumBorder(),
            height: 48.0,
          ),
        ),
        home: BlocBuilder(
          bloc: _authenticationBloc,
          builder: (context, state) {
            if (state is Unauthenticated) {
              return WelcomePage();
            }
            if (state is Authenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _messagesBloc.dispatch(MessagesInitEvent(state.user.uid));
                Navigator.pushReplacementNamed(context, '/main');
              });
            }
            return Material(child: SizedBox.expand());
          },
        ),
        routes: {
          '/login': (ctx) => LoginPage(userRepository: _userRepository),
          '/register': (ctx) => RegisterPage(userRepository: _userRepository),
          '/profile': (ctx) => ProfilePage(),
          '/catalog': (ctx) => CatalogPage(catalogRepository: _catalogRepository),
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
                              if (state is MessagesLoadedState) {
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
                      return CatalogPage(catalogRepository: _catalogRepository);
                    case 1:
                      return CatalogPage(catalogRepository: _catalogRepository, favorites: true);
                    case 2:
                      return DialogsPage();
                    case 3:
                      return ProfilePage();
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
          } else if (settings.name == '/catalog/profile') {
            return CupertinoPageRoute(
              builder: (ctx) => ProfilePage(user: settings.arguments),
            );
          } else if (settings.name == '/dialog') {
            Map<String, dynamic> args = Map.from(settings.arguments);
            return CupertinoPageRoute(
              builder: (ctx) => DialogPage(
                dialogId: args['id'],
                title: args['title'],
              ),
            );
          }
          return CupertinoPageRoute(builder: (_) => const SizedBox());
        },
      ),
    );
  }
}
