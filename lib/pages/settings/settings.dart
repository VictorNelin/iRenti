import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/utils/validators.dart';
import 'package:irenti/widgets/list_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerEnd,
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
                  Align(child: Text(
                    'Закрыть',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Настройки',
              style: Theme.of(context).textTheme.headline,
            ),
          ),
          const SizedBox(height: 40.0),
          ListEntry(
            title: 'Имя',
            trailing: const Icon(Icons.edit, size: 16.0),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (ctx) => _ChangeNamePage())),
          ),
          ListEntry(
            title: 'Номер телефона',
            trailing: const Icon(Icons.edit, size: 16.0),
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (ctx) => _ChangePhonePage())),
          ),
          ListEntry(
            title: 'Политика конфиденциальности',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
            onTap: () {},
          ),
          ListEntry(
            title: 'Правила сервиса',
            trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ChangeNamePage extends StatelessWidget {
  final ValueNotifier<String> _name = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    _name.value ??= (BlocProvider.of<AuthenticationBloc>(context).currentState as Authenticated).user.displayName ?? '';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerEnd,
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
                  Align(child: Text(
                    'Закрыть',
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
      body: Form(
        autovalidate: true,
        child: Builder(
          builder: (ctx) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Редактирование имени',
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
                const SizedBox(height: 40.0),
                TextFormField(
                  initialValue: _name.value,
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    labelStyle: Theme.of(context).textTheme.subhead,
                    alignLabelWithHint: true,
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).textTheme.subhead.color, width: 2.0)),
                  ),
                  style: Theme.of(context).textTheme.subhead,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (s) => s == null || s.trim().isEmpty ? 'Введите имя' : null,
                  onSaved: (s) => _name.value = s,
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
                                'Сохранить',
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              textColor: const Color(0xFF272D30),
                              disabledTextColor: const Color(0x61272D30),
                              onPressed: Form.of(ctx).validate() ? () {
                                Form.of(ctx).save();
                                BlocProvider.of<AuthenticationBloc>(context)
                                  ..dispatch(UpdateName(_name.value))
                                  ..state.listen((_) => Navigator.pop(context));
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
    );
  }
}

class _ChangePhonePage extends StatefulWidget {
  @override
  _ChangePhonePageState createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<_ChangePhonePage> with SingleTickerProviderStateMixin {
  final StreamController<String> _state = StreamController<String>();
  AuthenticationBloc _bloc;
  TabController _tabs;
  String _phone;
  String _code;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(_ChangePhonePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bloc = BlocProvider.of<AuthenticationBloc>(context);
  }

  @override
  void dispose() {
    _state.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerEnd,
            minWidth: 0.0,
            maxWidth: double.infinity,
            minHeight: kToolbarHeight,
            maxHeight: kToolbarHeight,
            child: InkWell(
              onTap: () {
                _state.close();
                Navigator.pop(context);
              },
              child: ListBody(
                mainAxis: Axis.horizontal,
                children: <Widget>[
                  const SizedBox(width: 16.0),
                  Align(child: Text(
                    'Закрыть',
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
      body: Form(
        autovalidate: true,
        child: Builder(
          builder: (ctx) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Редактирование номера телефона',
                    style: Theme.of(context).textTheme.headline,
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
                                    decoration: InputDecoration(
                                      labelText: 'Номер телефона',
                                      labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                        color: const Color(0xFF272D30),
                                      ),
                                      hintText: '+79XXXXXXXXX',
                                      //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF272D30),
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF272D30), width: 2.0,
                                        ),
                                      ),
                                      alignLabelWithHint: true,
                                    ),
                                    style: Theme.of(context).textTheme.subhead.copyWith(
                                      color: const Color(0xFF272D30),
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
                                              onPressed: () {
                                                if (Form.of(ctx).validate()) {
                                                  Form.of(ctx).save();
                                                  _bloc.dispatch(UpdatePhone(_state.stream));
                                                  _state.add(_phone);
                                                  _tabs.animateTo(1);
                                                  _bloc.state.listen((_) => Navigator.pop(context));
                                                }
                                              },
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
                                    decoration: InputDecoration(
                                      labelText: 'Код СМС',
                                      labelStyle: Theme.of(context).textTheme.subhead.copyWith(
                                        color: const Color(0xFF272D30),
                                      ),
                                      //border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF5353))),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF272D30),
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF272D30),
                                          width: 2.0,
                                        ),
                                      ),
                                      alignLabelWithHint: true,
                                    ),
                                    style: Theme.of(context).textTheme.subhead.copyWith(
                                      color: const Color(0xFF272D30),
                                    ),
                                    keyboardType: TextInputType.number,
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
                                                'Сохранить',
                                                style: Theme.of(context).textTheme.subhead,
                                              ),
                                              textColor: const Color(0xFF272D30),
                                              disabledTextColor: const Color(0x61272D30),
                                              onPressed: () {
                                                Form.of(ctx).save();
                                                _state.add(_code);
                                              },
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
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

