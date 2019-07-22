import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/bloc/register_bloc.dart';
import 'package:irenti/repository/user_repository.dart';
import 'package:irenti/widgets/checkbox.dart';
import 'package:irenti/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  final UserRepository _userRepository;

  RegisterPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  RegisterBloc _registerBloc;
  StreamSubscription _stateSub;
  TabController _tabs;
  bool _inputAllowed = true;
  String _phone;
  String _code;
  String _name;
  String _email;
  String _password;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _registerBloc = RegisterBloc(
      userRepository: widget._userRepository,
    );
    _stateSub = _registerBloc.state.listen((state) {
      if (state.isAwaitingCode) {
        LocalHistoryEntry entry = LocalHistoryEntry(onRemove: () => _tabs.animateTo(0));
        ModalRoute.of(context).addLocalHistoryEntry(entry);
        _tabs.animateTo(1);
      } else if (state.isAwaitingData) {
        LocalHistoryEntry entry = LocalHistoryEntry(onRemove: () => _tabs.animateTo(0));
        ModalRoute.of(context).addLocalHistoryEntry(entry);
        _tabs.animateTo(2);
      } else if (state.isSuccess) {
        BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
        Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => r == null, arguments: 3);
        return;
      }
      setState(() {
        _inputAllowed = !state.isSubmitting;
      });
    });
  }

  @override
  void dispose() {
    _stateSub.cancel();
    _tabs.dispose();
    _registerBloc.dispose();
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
                  const Icon(Icons.arrow_back_ios, size: 16.0, color: Color(0xFFEF5353)),
                  const SizedBox(width: 16.0),
                  Align(child: Text(
                    'Назад',
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      fontSize: 14.0,
                      color: const Color(0xFFEF5353),
                    ),
                  )),
                  const SizedBox(width: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Регистрация',
              style: Theme.of(context).textTheme.headline.copyWith(
                color: const Color(0xFFEF5353),
              ),
            ),
          ),
          const SizedBox(height: 40.0),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Form(
                  child: Builder(
                    builder: (ctx) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              initialValue: '+7',
                              enabled: _inputAllowed,
                              decoration: InputDecoration(
                                labelText: 'Номер телефона',
                                labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                  color: const Color(0xFFEF5353),
                                ),
                                hintText: '+79XXXXXXXXX',
                                //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFEF5353),
                                  ),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFEF5353), width: 2.0,
                                  ),
                                ),
                                alignLabelWithHint: true,
                              ),
                              style: Theme.of(context).textTheme.subhead.copyWith(
                                color: const Color(0xFFEF5353),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (s) => Validators.isValidPhone(s) ? null : 'Неверный номер',
                              onSaved: (s) => _phone = s,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: Divider.createBorderSide(context, width: 1.0),
                              ),
                            ),
                            child: SafeArea(
                              child: ButtonTheme.bar(
                                child: SafeArea(
                                  top: false,
                                  child: ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          'Получить СМС-код',
                                          style: Theme.of(context).textTheme.subhead,
                                        ),
                                        textColor: const Color(0xFF272D30),
                                        disabledTextColor: const Color(0x61272D30),
                                        onPressed: _inputAllowed ? () {
                                          if (Form.of(ctx).validate()) {
                                            Form.of(ctx).save();
                                            _registerBloc.dispatch(SubmittedPhone(phone: _phone));
                                          }
                                        } : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Form(
                  child: Builder(
                    builder: (ctx) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              enabled: _inputAllowed,
                              decoration: InputDecoration(
                                labelText: 'Код СМС',
                                labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                  color: const Color(0xFFEF5353),
                                ),
                                //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFEF5353),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFEF5353),
                                    width: 2.0,
                                  ),
                                ),
                                alignLabelWithHint: true,
                              ),
                              style: Theme.of(context).textTheme.subhead.copyWith(
                                color: const Color(0xFFEF5353),
                              ),
                              keyboardType: TextInputType.phone,
                              onSaved: (s) => _code = s,
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: Divider.createBorderSide(context, width: 1.0),
                              ),
                            ),
                            child: SafeArea(
                              child: ButtonTheme.bar(
                                child: SafeArea(
                                  top: false,
                                  child: ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          'Сохранить код и указать данные',
                                          style: Theme.of(context).textTheme.subhead,
                                        ),
                                        textColor: const Color(0xFF272D30),
                                        disabledTextColor: const Color(0x61272D30),
                                        onPressed: _inputAllowed ? () {
                                          Form.of(ctx).save();
                                          _registerBloc.dispatch(SubmittedCode(code: _code));
                                        } : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Form(
                  child: Builder(
                    builder: (ctx) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            child: ListView(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: TextFormField(
                                    enabled: _inputAllowed,
                                    decoration: InputDecoration(
                                      labelText: 'Имя',
                                      labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                        color: const Color(0xFFEF5353),
                                      ),
                                      //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353), width: 2.0)),
                                      alignLabelWithHint: true,
                                    ),
                                    style: Theme.of(context).textTheme.subhead.copyWith(
                                      color: const Color(0xFFEF5353),
                                    ),
                                    textCapitalization: TextCapitalization.sentences,
                                    validator: (s) => s.isEmpty ? 'Пожалуйста, введите имя' : null,
                                    onSaved: (s) => _name = s,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: TextFormField(
                                    enabled: _inputAllowed,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                        color: const Color(0xFFEF5353),
                                      ),
                                      //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353), width: 2.0)),
                                      alignLabelWithHint: true,
                                    ),
                                    style: Theme.of(context).textTheme.subhead.copyWith(
                                      color: const Color(0xFFEF5353),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (s) => s.isEmpty || !Validators.isValidEmail(s) ? 'Пожалуйста, введите email' : null,
                                    onSaved: (s) => _email = s,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: TextFormField(
                                    enabled: _inputAllowed,
                                    decoration: InputDecoration(
                                      labelText: 'Пароль',
                                      labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                        color: const Color(0xFFEF5353),
                                      ),
                                      //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353), width: 2.0)),
                                      alignLabelWithHint: true,
                                    ),
                                    style: Theme.of(context).textTheme.subhead.copyWith(
                                      color: const Color(0xFFEF5353),
                                    ),
                                    obscureText: true,
                                    validator: (s) => s.isEmpty ? 'Пожалуйста, введите пароль' : Validators.isValidPassword(s) ? null : 'Пароль слишком слабый',
                                    onSaved: (s) => _password = s,
                                  ),
                                ),
                                ListTile(
                                  enabled: _inputAllowed,
                                  leading: SizedBox(
                                    width: 40,
                                    height: 56,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: RoundCheckbox(
                                        value: _agreed,
                                        size: 24.0,
                                        onChanged: (b) {
                                          setState(() => _agreed = b);
                                        },
                                      ),
                                    ),
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Регистрируясь, я подтверждаю, что ознакомился:\n',
                                        style: Theme.of(context).textTheme.body1.copyWith(
                                          fontSize: 14.0,
                                          color: const Color(0xFFEF5353),
                                          height: 1.25,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'с политикой конфиденциальности',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = () {

                                            },
                                          ),
                                          TextSpan(text: '\n'),
                                          TextSpan(
                                            text: 'с правилами сервиса',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            recognizer: TapGestureRecognizer()..onTap = () {

                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
                            child: FlatButton(
                              child: Text('ЗАРЕГИСТРИРОВАТЬСЯ'),
                              color: const Color(0xFFEF5353),
                              onPressed: _inputAllowed && _agreed ? () {
                                if (Form.of(ctx).validate()) {
                                  Form.of(ctx).save();
                                  _registerBloc.dispatch(SubmittedData(
                                    name: _name,
                                    email: _email,
                                    password: _password,
                                  ));
                                }
                              } : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

