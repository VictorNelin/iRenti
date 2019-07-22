import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/login_bloc.dart';
import 'package:irenti/repository/user_repository.dart';
import 'package:irenti/utils/validators.dart';

class LoginPage extends StatefulWidget {
  final UserRepository _userRepository;

  LoginPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  StreamSubscription _loginSub;
  bool _inputAllowed = true;
  String _login;
  String _password;
  String _loginError;
  String _passwordError;

  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc(userRepository: widget._userRepository);
    _loginSub = _loginBloc.state.listen((state) {
      if (state.isSuccess) {
        BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => r == null);
        //Navigator.pushReplacementNamed(context, '/main');
        return;
      }
      setState(() {
        _inputAllowed = !state.isSubmitting;
      });
    });
  }

  @override
  void dispose() {
    _loginSub.cancel();
    _loginBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            minWidth: 0.0,
            maxWidth: double.infinity,
            minHeight: kToolbarHeight,
            maxHeight: kToolbarHeight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: ListBody(
                mainAxis: Axis.horizontal,
                children: <Widget>[
                  const SizedBox(width: 16.0),
                  const Icon(Icons.arrow_back_ios, size: 16.0),
                  const SizedBox(width: 16.0),
                  Align(child: Text(
                    'Назад',
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      fontSize: 14.0,
                    ),
                  )),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          onChanged: () {
            if (_loginError != null || _passwordError != null) {
              setState(() {
                _loginError = null;
                _passwordError = null;
              });
            }
          },
          child: Builder(builder: (ctx) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40.0),
                Text(
                  'Авторизация',
                  style: Theme.of(context).textTheme.headline,
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  enabled: _inputAllowed,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: Theme.of(context).textTheme.subhead,
                    alignLabelWithHint: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color, width: 2.0)),
                  ),
                  style: Theme.of(context).textTheme.subhead,
                  keyboardType: TextInputType.emailAddress,
                  validator: (s) => _loginError ?? (Validators.isValidEmail(s) ? null : 'Введите правильный email'),
                  onSaved: (s) => _login = s,
                ),
                TextFormField(
                  enabled: _inputAllowed,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: Theme.of(context).textTheme.subhead,
                    alignLabelWithHint: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color, width: 2.0)),
                  ),
                  style: Theme.of(context).textTheme.subhead,
                  obscureText: true,
                  validator: (s) => _passwordError ?? (Validators.isValidPassword(s) ? null : 'Введите пароль'),
                  onSaved: (s) => _password = s,
                ),
                const SizedBox(height: 32.0),
                RichText(
                  text: TextSpan(
                    text: 'Восстановление пароля',
                    style: Theme.of(context).textTheme.body1,
                    recognizer: TapGestureRecognizer()..onTap = () {

                    },
                  ),
                ),
                const Expanded(child: SizedBox()),
                FlatButton(
                  child: Text('АВТОРИЗОВАТЬСЯ'),
                  color: const Color(0xFF272D30),
                  onPressed: _inputAllowed ? () {
                    if (Form.of(ctx).validate()) {
                      Form.of(ctx).save();
                      _loginBloc.dispatch(LoginWithCredentialsPressed(email: _login, password: _password));
                    }
                  } : null,
                ),
                const SizedBox(height: 32.0),
              ],
            );
          }),
        ),
      ),
    );
  }
}
