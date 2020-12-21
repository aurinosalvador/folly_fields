import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_consumer.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields_example/example_model.dart';

///
///
///
abstract class BaseConsumerMock<T extends AbstractModel>
    extends AbstractConsumer<T> {
  ///
  ///
  ///
  @override
  Future<ConsumerPermission> checkPermission(
    BuildContext context, {
    List<String> paths,
    bool returnLog = false,
  }) =>
      Future<ConsumerPermission>.value(
        ConsumerPermission(
          name: 'mock',
          iconName: 'question',
          view: true,
          insert: true,
          update: true,
          delete: true,
          menu: true,
        ),
      );

  ///
  ///
  ///
  @override
  Future<List<T>> list(
    BuildContext context, {
    bool forceOffline = false,
    Map<String, String> qsParam,
    bool returnLog = false,
  }) async {
    print('mock list: $qsParam');

    int first = int.tryParse(qsParam['f'] ?? '0');
    int qtd = int.tryParse(qsParam['q'] ?? '50');

    return Future<List<T>>.value(
      List<T>.generate(
        qtd,
        (int index) => (ExampleModel.generate(seed: first + index) as T),
      ),
    );
  }

  ///
  ///
  ///
  @override
  Future<Map<T, String>> dropdownMap(
    BuildContext context, {
    Map<String, String> qsParam,
  }) async =>
      null;

  ///
  ///
  ///
  @override
  Future<T> getById(
    BuildContext context,
    T model, {
    bool returnLog = false,
  }) async =>
      Future<T>.value(model);

  ///
  ///
  ///
  @override
  Future<bool> saveOrUpdate(
    BuildContext context,
    T model, {
    bool returnLog = false,
  }) =>
      Future<bool>.value(true);

  ///
  ///
  ///
  @override
  Future<T> delete(
    BuildContext context,
    T model, {
    bool returnLog = false,
  }) async =>
      Future<T>.value(model);
}
