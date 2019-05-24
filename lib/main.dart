import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/repository/user_repository.dart';

import 'pages/auth/welcome.dart';
import 'pages/auth/login.dart';
import 'pages/auth/register.dart';
import 'pages/catalog/catalog.dart';
import 'pages/catalog/catalog_info.dart';
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
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final UserRepository _userRepository = UserRepository();
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    super.initState();
    _authenticationBloc = AuthenticationBloc(userRepository: _userRepository);
    _authenticationBloc.dispatch(AppStarted());
  }

  @override
  void dispose() {
    _authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _authenticationBloc,
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
            if (state is Uninitialized) {
              return Material(child: SizedBox.expand());
            }
            if (state is Unauthenticated) {
              return WelcomePage();
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, '/main'));
              return Material(child: SizedBox.expand());
            }
          },
        ),
        routes: {
          '/login': (ctx) => LoginPage(userRepository: _userRepository),
          '/register': (ctx) => RegisterPage(userRepository: _userRepository),
          '/profile': (ctx) => ProfilePage(),
          '/catalog': (ctx) => CatalogPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/main') {
            return CupertinoPageRoute(
              builder: (ctx) => CupertinoTabScaffold(
                tabBar: CupertinoTabBar(
                  currentIndex: settings.arguments ?? 0,
                  items: [
                    BottomNavigationBarItem(icon: Icon(Icons.home)),
                    BottomNavigationBarItem(icon: Icon(Icons.star)),
                    BottomNavigationBarItem(icon: Icon(Icons.message)),
                    BottomNavigationBarItem(icon: Icon(Icons.person)),
                  ],
                ),
                tabBuilder: (ctx, i) {
                  switch (i) {
                    case 0:
                      return CatalogPage();
                    case 1:
                      return CatalogPage(favorites: true);
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
          } else if (settings.name == '/catalog/profile') {
            return CupertinoPageRoute(
              builder: (ctx) => ProfilePage(user: settings.arguments),
            );
          }
        },
      ),
    );
  }
}
