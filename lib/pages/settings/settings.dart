import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:irenti/bloc/auth_bloc.dart';
import 'package:irenti/widgets/list_tile.dart';

class SettingsPage extends StatelessWidget {
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
            onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (ctx) => ChangeNamePage())),
          ),
          ListEntry(
            title: 'Номер телефона',
            trailing: const Icon(Icons.edit, size: 16.0),
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

class ChangeNamePage extends StatelessWidget {
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
                  keyboardType: TextInputType.emailAddress,
                  validator: (s) => s == null || s.trim().isEmpty ? null : 'Введите имя',
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
                                'Сохранить код и указать данные',
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

