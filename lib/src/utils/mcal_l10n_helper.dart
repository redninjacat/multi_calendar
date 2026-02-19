import 'package:flutter/widgets.dart';

import '../../l10n/mcal_localizations.dart';
import '../../l10n/mcal_localizations_en.dart';

/// Returns [MCalLocalizations] for the given [context], falling back to
/// English when no [MCalLocalizations.delegate] has been registered by the
/// host application.
///
/// This allows the package to work out of the box without requiring apps to
/// add [MCalLocalizations.localizationsDelegates] to their [MaterialApp].
MCalLocalizations mcalL10n(BuildContext context) {
  return Localizations.of<MCalLocalizations>(context, MCalLocalizations) ??
      MCalLocalizationsEn();
}
