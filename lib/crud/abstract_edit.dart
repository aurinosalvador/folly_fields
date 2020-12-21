import 'dart:async';

import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/crud/abstract_ui_builder.dart';
import 'package:folly_fields/folly_fields.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';
import 'package:folly_fields/widgets/waiting_message.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
abstract class AbstractEdit<
    T extends AbstractModel,
    UI extends AbstractUIBuilder<T>,
    C extends AbstractConsumer<T>> extends StatefulWidget {
  final T model;
  final UI uiBuilder;
  final C consumer;
  final bool edit;

  ///
  ///
  ///
  const AbstractEdit({
    Key key,
    @required this.model,
    @required this.uiBuilder,
    this.consumer,
    @required this.edit,
  }) : super(key: key);

  ///
  ///
  ///
  @override
  _AbstractEditState<T, UI, C> createState() => _AbstractEditState<T, UI, C>();

  ///
  ///
  ///
  Future<Map<String, dynamic>> stateInjection(
    BuildContext context,
    T model,
  ) async {
    return <String, dynamic>{};
  }

  ///
  ///
  ///
  List<Widget> formContent({
    @required BuildContext context,
    @required T model,
    @required Function(bool) refresh,
    @required bool edit,
    @required Map<String, dynamic> stateInjection,
    @required String prefix,
  });

  ///
  ///
  ///
  List<Widget> getFormContent(BuildContext context) {
    return formContent(
      context: context,
      model: model,
      refresh: null,
      edit: edit,
      stateInjection: <String, dynamic>{},
      prefix: uiBuilder.prefix,
    );
  }

  ///
  ///
  ///
  void stateDispose(
    BuildContext context,
    Map<String, dynamic> stateInjection,
  ) {}
}

///
///
///
class _AbstractEditState<
    T extends AbstractModel,
    UI extends AbstractUIBuilder<T>,
    C extends AbstractConsumer<T>> extends State<AbstractEdit<T, UI, C>> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  StreamController<bool> _controller;
  Map<String, dynamic> _stateInjection;
  T _model;
  int _initialHash;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _controller = StreamController<bool>();
    _loadData();
  }

  ///
  ///
  ///
  Future<void> _loadData() async {
    try {
      bool exists = true;
      if (widget.model.id == null || widget.consumer == null) {
        Map<String, dynamic> copy = widget.model.toMap();
        _model = widget.model.fromJson(copy);
      } else {
        _model = await widget.consumer.getById(context, widget.model);
      }

      _stateInjection = await widget.stateInjection(context, _model);

      _controller.add(exists);

      _initialHash = _model.hashCode;
    } catch (error, stack) {
      _controller.addError(error, stack);
    }
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!widget.edit) return true;

        _formKey.currentState.save();
        int currentHash = _model.hashCode;

        bool go = true;
        if (_initialHash != currentHash) {
          go = await FollyDialogs.yesNoDialog(
            context: context,
            title: 'Atenção',
            message: 'Modificações foram realizadas.\n\n'
                'Deseja sair mesmo assim?',
          );
        }
        return go;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.uiBuilder.getSuperSingle()),
          actions: <Widget>[
            Visibility(
              visible: widget.edit,
              child: IconButton(
                tooltip: 'Salvar',
                icon: FaIcon(widget.consumer == null
                    ? FontAwesomeIcons.check
                    : FontAwesomeIcons.solidSave),
                onPressed: _save,
              ),
            )
          ],
        ),
        bottomNavigationBar: widget.uiBuilder.buildBottomNavigationBar(
          context: context,
        ),
        body: widget.uiBuilder.buildBackgroundContainer(
          context: context,
          child: Form(
            key: _formKey,
            child: StreamBuilder<bool>(
              stream: _controller.stream,
              builder: (
                BuildContext context,
                AsyncSnapshot<bool> snapshot,
              ) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: widget.formContent(
                        context: context,
                        model: _model,
                        refresh: (bool value) => _controller.add(value),
                        edit: widget.edit,
                        stateInjection: _stateInjection,
                        prefix: widget.uiBuilder.prefix,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  if (FollyFields().isDebug) {
                    print(snapshot.error);
                    print(snapshot.stackTrace);
                  }

                  return Center(
                    child: Text(
                      'Ocorreu um erro:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return WaitingMessage(message: 'Consultando...');
              },
            ),
          ),
        ),
      ),
    );
  }

  ///
  ///
  ///
  void _save() async {
    try {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        bool ok = true;

        if (widget.consumer != null) {
          ok = await widget.consumer.saveOrUpdate(context, _model);
        }

        if (ok) {
          _initialHash = _model.hashCode;
          Navigator.of(context).pop(_model);
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
      await FollyDialogs.dialogMessage(
        context: context,
        message: 'Ocorreu um erro ao tentar salvar:\n$e',
      );
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    widget.stateDispose(context, _stateInjection);
    _controller.close();
    super.dispose();
  }
}
