import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folly_fields/util/date_validator.dart';
import 'package:folly_fields/util/field_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
class DateField extends FormField<DateTime> {
  final DateEditingController controller;
  final FocusNode focusNode;

  ///
  ///
  ///
  DateField({
    Key key,
    String prefix,
    @required String label,
    DateTime initialValue,
    this.controller,
    this.focusNode,
    DateTime firstDate,
    DateTime lastDate,
    FormFieldSetter<DateTime> onSaved,
    FormFieldValidator<DateTime> validator,
    bool enabled = true,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    AutovalidateMode autovalidateMode,
  }) : super(
          key: key,
          initialValue: controller != null
              ? controller.date
              : (initialValue ?? DateTime.now()),
          onSaved: onSaved,
          validator: enabled ? validator : (_) => null,
          enabled: enabled,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
          builder: (FormFieldState<DateTime> field) {
            final _DateFieldState state = field as _DateFieldState;

            Color rootColor = Theme.of(state.context).primaryColor;

            final InputDecoration effectiveDecoration = InputDecoration(
              border: OutlineInputBorder(),
              labelText: prefix == null || prefix.isEmpty
                  ? label
                  : '${prefix} - ${label}',
              suffixIcon: IconButton(
                icon: Icon(FontAwesomeIcons.calendarDay),
                onPressed: () async {
                  try {
                    DateTime selectedDate = await showDatePicker(
                      context: state.context,
                      initialDate: state.value ?? DateTime.now(),
                      firstDate: firstDate ?? DateTime(1900),
                      lastDate: lastDate ?? DateTime(2100),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: rootColor,
                            accentColor: rootColor,
                            colorScheme: ColorScheme.light(primary: rootColor),
                          ),
                          child: child,
                        );
                      },
                    );

                    if (selectedDate != null) {
                      state.didChange(selectedDate);
                    }
                  } catch (e, s) {
                    print(e);
                    print(s);
                  }
                },
              ),
            ).applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: state._effectiveController,
                focusNode: state._effectiveFocusNode,
                decoration: effectiveDecoration.copyWith(
                  errorText: enabled ? field.errorText : null,
                ),
                keyboardType: TextInputType.datetime,
                style: enabled ? null : TextStyle(color: Colors.black26),
                textAlign: TextAlign.start,
                textCapitalization: TextCapitalization.none,
                autofocus: false,
                readOnly: false,
                showCursor: true,
                obscureText: false,
                autocorrect: false,
                smartDashesType: SmartDashesType.disabled,
                smartQuotesType: SmartQuotesType.disabled,
                enableSuggestions: false,
                maxLines: 1,
                minLines: 1,
                expands: false,
                inputFormatters: <TextInputFormatter>[
                  FieldHelper.masks[FieldType.date],
                ],
                enabled: enabled,
                scrollPadding: scrollPadding,
                enableInteractiveSelection: enableInteractiveSelection,
              ),
            );
          },
        );

  ///
  ///
  ///
  @override
  _DateFieldState createState() => _DateFieldState();
}

///
///
///
class _DateFieldState extends FormFieldState<DateTime> {
  DateEditingController _controller;
  FocusNode _focusNode;

  ///
  ///
  ///
  DateEditingController get _effectiveController =>
      widget.controller ?? _controller;

  ///
  ///
  ///
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _focusNode;

  ///
  ///
  ///
  @override
  DateField get widget => super.widget as DateField;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = DateEditingController(date: widget.initialValue);
    } else {
      widget.controller.addListener(_handleControllerChanged);
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _focusNode.addListener(_handleFocusChanged);
    } else {
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  ///
  ///
  ///
  @override
  void didUpdateWidget(DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      oldWidget.focusNode?.removeListener(_handleFocusChanged);

      widget.controller?.addListener(_handleControllerChanged);
      widget.focusNode?.addListener(_handleFocusChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = DateEditingController.fromValue(
          oldWidget.controller.value,
        );
      }

      if (widget.controller != null) {
        setValue(widget.controller.date);

        if (oldWidget.controller == null) {
          _controller = null;
        }

        if (oldWidget.focusNode == null) {
          _focusNode = null;
        }
      }
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    widget.focusNode?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  ///
  ///
  ///
  @override
  void didChange(DateTime value) {
    super.didChange(value);

    if (_effectiveController.date != value) {
      _effectiveController.date = value;
    }
  }

  ///
  ///
  ///
  @override
  void reset() {
    super.reset();
    setState(() => _effectiveController.date = widget.initialValue);
  }

  ///
  ///
  ///
  void _handleControllerChanged() {
    if (_effectiveController.date != value) {
      didChange(_effectiveController.date);
    }
  }

  ///
  ///
  ///
  void _handleFocusChanged() {
    _effectiveController.selection = TextSelection(
      baseOffset: 0,
      extentOffset:
          _effectiveFocusNode.hasFocus ? _effectiveController.text.length : 0,
    );
  }
}

///
///
///
class DateEditingController extends TextEditingController {
  ///
  ///
  ///
  DateEditingController({DateTime date})
      : super(text: DateValidator.format(date ?? DateTime.now()));

  ///
  ///
  ///
  DateEditingController.fromValue(TextEditingValue value)
      : super.fromValue(value);

  ///
  ///
  ///
  DateTime get date => DateValidator.parse(text);

  ///
  ///
  ///
  set date(DateTime date) => text = DateValidator.format(date);
}