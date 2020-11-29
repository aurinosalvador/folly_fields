import 'package:flutter/widgets.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///
///
///
abstract class AbstractUIBuilder<T extends AbstractModel> {
  final String prefix;

  ///
  ///
  ///
  const AbstractUIBuilder(this.prefix);

  ///
  ///
  /// Retorna o nome no singular que é utilizado nas views.
  String getSuperSingle() => prefix == null || prefix.isEmpty
      ? getInternalSingle()
      : '$prefix - ${getInternalSingle()}';

  ///
  ///
  ///
  String getInternalSingle();

  ///
  ///
  /// Retorna o nome no plural que é utilizado nas views.
  String getSuperPlural() => prefix == null || prefix.isEmpty
      ? getInternalPlural()
      : '$prefix - ${getInternalPlural()}';

  ///
  ///
  ///
  String getInternalPlural();

  ///
  ///
  /// Widget do leading do ListTile da lista e da pesquisa.
  Widget getLeading(T model) => FaIcon(FontAwesomeIcons.solidCircle);

  ///
  ///
  /// Widget do title do ListTile da lista e da pesquisa.
  Widget getTitle(T model);

  ///
  ///
  /// Widget do subtitle do ListTile da lista e da pesquisa.
  Widget getSubtitle(T model) => null;

  ///
  ///
  /// Widget do title do ListTile das sugestões.
  Widget getSuggestionTitle(T model) => getTitle(model);

  ///
  ///
  /// Widget do subtitle do ListTile das sugestões.
  Widget getSuggestionSubtitle(T model) => getSubtitle(model);

  ///
  ///
  ///
  Widget buildBackgroundContainer({
    @required BuildContext context,
    @required Widget child,
  }) =>
      Container(
        child: child,
      );

  ///
  ///
  ///
  Widget buildBottomNavigationBar({
    @required BuildContext context,
  }) =>
      null;
}