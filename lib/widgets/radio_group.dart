import 'package:flutter/material.dart';
import 'package:irenti/widgets/checkbox.dart';
import 'package:irenti/widgets/list_tile.dart';

class RadioGroup extends StatefulWidget {
  final List<String> titles;
  final TextStyle titleStyle;
  final int value;
  final ValueChanged<int> onChanged;
  final bool allowNullValue;
  final double paddingBetween;
  final bool showDividers;

  const RadioGroup({
    Key key,
    @required this.titles,
    this.titleStyle,
    this.value,
    this.onChanged,
    this.allowNullValue = false,
    this.paddingBetween = 40,
    this.showDividers = false,
  }) :  assert((value == null && allowNullValue) || (value >= 0 && value < titles.length)),
        super(key: key);

  @override
  _RadioGroupState createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(RadioGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    bool inEntry = context.ancestorWidgetOfExactType(ListEntry) != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (String s in widget.titles)
          Container(
            padding: inEntry ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20),
            height: widget.paddingBetween + 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RoundCheckbox(
                  value: widget.titles.indexOf(s) == widget.value,
                  onChanged: (b) {
                    if (widget.onChanged != null) {
                      widget.onChanged(_value == widget.titles.indexOf(s) ? null : widget.titles.indexOf(s));
                    }
                  },
                ),
                const SizedBox(width: 10),
                Text(s, style: widget.titleStyle),
              ],
            ),
          ),
      ],
    );
  }
}

