// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';

/// Iconos predeterminados de Morph Expressive, basados en Fluent Icons Kit.
///
/// Los glifos usan los codigos de fluent_icons_kit 0.1.1 para que los
/// widgets heredados puedan conservar iconos y parametros const.
/// Las propiedades publicas de iconos siguen aceptando widgets e IconData.
abstract final class MorphIcons {
  const MorphIcons._();

  // ---------- iconos fluent integrados ----------
  /// FluentIcons.line.person_circle
  static const IconData account_circle = IconData(
    0xe732,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.add
  static const IconData add = IconData(
    0xe006,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.archive
  static const IconData archive = IconData(
    0xe048,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.arrow_left
  static const IconData arrow_back = IconData(
    0xe090,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.arrow_left
  static const IconData arrow_back_rounded = IconData(
    0xe090,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_down
  static const IconData arrow_drop_down = IconData(
    0xe256,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_up
  static const IconData arrow_drop_up = IconData(
    0xe25a,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.arrow_right
  static const IconData arrow_forward = IconData(
    0xe0a6,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.arrow_right
  static const IconData arrow_right_rounded = IconData(
    0xe0a6,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.calendar_today
  static const IconData calendar_today = IconData(
    0xe1d4,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.dismiss_circle
  static const IconData cancel = IconData(
    0xe399,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.checkmark
  static const IconData check = IconData(
    0xe242,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.checkbox_checked
  static const IconData check_box = IconData(
    0xe23c,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.checkbox_unchecked
  static const IconData check_box_outline_blank = IconData(
    0xe240,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.checkbox_unchecked
  static const IconData check_box_outline_blank_rounded = IconData(
    0xe240,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.checkbox_checked
  static const IconData check_box_rounded = IconData(
    0xe23c,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.checkmark_circle
  static const IconData check_circle = IconData(
    0xe243,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.checkmark
  static const IconData check_rounded = IconData(
    0xe242,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_left
  static const IconData chevron_left = IconData(
    0xe258,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_right
  static const IconData chevron_right = IconData(
    0xe259,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.dismiss
  static const IconData close = IconData(
    0xe39b,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.delete
  static const IconData delete = IconData(
    0xe368,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.drag
  static const IconData drag_handle = IconData(
    0xe42d,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.edit
  static const IconData edit = IconData(
    0xe459,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.edit
  static const IconData edit_outlined = IconData(
    0xe459,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.error_circle
  static const IconData error = IconData(
    0xe476,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_down
  static const IconData expand_more = IconData(
    0xe256,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_down
  static const IconData expand_more_rounded = IconData(
    0xe256,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.heart
  static const IconData favorite = IconData(
    0xe54e,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.heart
  static const IconData favorite_border = IconData(
    0xe54d,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.folder
  static const IconData folder = IconData(
    0xe4b5,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.home
  static const IconData home = IconData(
    0xe55e,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.image
  static const IconData image = IconData(
    0xe571,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.mail_inbox
  static const IconData inbox = IconData(
    0xe631,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.chevron_down
  static const IconData keyboard_arrow_down = IconData(
    0xe256,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.keyboard
  static const IconData keyboard_outlined = IconData(
    0xe5a2,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.mail
  static const IconData mail = IconData(
    0xe61d,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.line_horizontal_3
  static const IconData menu = IconData(
    0xe5ea,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.panel_left_expand
  static const IconData menu_open = IconData(
    0xe6dc,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.mic
  static const IconData mic = IconData(
    0xe661,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.more_horizontal
  static const IconData more_horiz = IconData(
    0xe67a,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.more_vertical
  static const IconData more_vert = IconData(
    0xe67b,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.radio_button
  static const IconData radio = IconData(
    0xe7dd,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.radio_button
  static const IconData radio_button_checked = IconData(
    0xe800,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.radio_button_off
  static const IconData radio_button_unchecked = IconData(
    0xe7de,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.clock
  static const IconData schedule = IconData(
    0xe29b,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.search
  static const IconData search = IconData(
    0xe841,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.send
  static const IconData send = IconData(
    0xe851,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.share
  static const IconData share = IconData(
    0xe869,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.filled.star
  static const IconData star = IconData(
    0xe92b,
    fontFamily: 'FluentKitFilled',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.star
  static const IconData star_outline = IconData(
    0xe908,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.options
  static const IconData tune = IconData(
    0xe6bf,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.eye
  static const IconData visibility = IconData(
    0xe47f,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.eye_off
  static const IconData visibility_off = IconData(
    0xe482,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

  /// FluentIcons.line.speaker_2
  static const IconData volume_up = IconData(
    0xe8dd,
    fontFamily: 'FluentKitLine',
    fontPackage: 'fluent_icons_kit',
  );

}
