import 'package:flutter/material.dart';

class ListEntry extends StatelessWidget {
  final String title;
  final double padding;
  final Widget child;
  final Widget trailing;
  final VoidCallback onTap;

  const ListEntry({
    Key key,
    this.title,
    this.padding: 20,
    this.child,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(color: Color.fromRGBO(0x27, 0x2D, 0x30, 0.08), height: 0.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.subhead,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: DefaultTextStyle(
                          style: Theme.of(context).textTheme.body1,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

