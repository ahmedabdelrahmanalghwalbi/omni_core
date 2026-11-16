part of '../../omni_core.dart';

abstract class DateTimeUtils {
  /// Locale used only while a date picker is in manual-entry mode.
  ///
  /// Some locales have a compact date format that cannot be typed. `ar`
  /// resolves to `d<U+200F>/M<U+200F>/y`, whose separators are invisible
  /// right-to-left marks no keyboard can produce, so `parseStrict` rejects
  /// every typed value; `en` is typeable but parses as US `M/d/y`. `en_GB` is
  /// the nearest locale whose compact format is a plain, typeable `dd/MM/y`.
  static const Locale _manualDateEntryLocale = Locale('en', 'GB');

  /// [showDatePicker] whose calendar keeps the app locale - including Arabic
  /// month names and RTL layout - while its manual-entry mode switches to
  /// [_manualDateEntryLocale], so a typed date is always dd/MM/yyyy.
  ///
  /// The locale is applied through `builder` rather than [showDatePicker]'s
  /// own `locale` argument: passing that makes it install a
  /// [Localizations.override] *below* `builder`, which would shadow this one
  /// and pin the dialog to a single locale for both modes.
  ///
  /// [errorFormatText] and [errorInvalidText] must be supplied by the caller in
  /// the app locale: manual-entry mode runs under [_manualDateEntryLocale], so
  /// the messages the dialog would otherwise resolve from
  /// [MaterialLocalizations] always come out English.
  static Future<DateTime?> showLocaleAdaptiveDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required String cancelText,
    required String confirmText,
    String? errorFormatText,
    String? errorInvalidText,
    widgets_import.TextDirection? textDirection,
  }) async {
    final calendarLocale = Localizations.localeOf(context);
    final entryMode = ValueNotifier<DatePickerEntryMode>(
      DatePickerEntryMode.calendar,
    );
    try {
      return await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        cancelText: cancelText,
        confirmText: confirmText,
        errorFormatText: errorFormatText,
        errorInvalidText: errorInvalidText,
        textDirection: textDirection,
        // TextInputType.datetime (the default) only exposes
        // digits, ':' and '-' on Android, so the '/' separator
        // the localized compact date format needs is
        // unreachable in manual-entry mode.
        keyboardType: TextInputType.datetime,
        onDatePickerModeChange: (mode) => entryMode.value = mode,
        builder: (dialogContext, dialog) {
          if (dialog == null) return const SizedBox.shrink();
          return ValueListenableBuilder<DatePickerEntryMode>(
            valueListenable: entryMode,
            child: dialog,
            builder: (context, mode, child) => Localizations.override(
              context: context,
              locale: _isManualEntryMode(mode)
                  ? _manualDateEntryLocale
                  : calendarLocale,
              child: child,
            ),
          );
        },
      );
    } finally {
      entryMode.dispose();
    }
  }

  static bool _isManualEntryMode(DatePickerEntryMode mode) =>
      mode == DatePickerEntryMode.input ||
      mode == DatePickerEntryMode.inputOnly;

  /// Format: yyyy-MM-dd
  static String formatDate({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'yyyy-MM-dd',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: dd/MM/yyyy
  static String formatReadableDate({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'dd/MM/yyyy',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: hh:mm a (e.g., 03:45 PM)
  static String formatTime12Hour({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'hh:mm a',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: HH:mm (e.g., 15:45)
  static String formatTime24Hour({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'HH:mm',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: yyyy-MM-dd HH:mm:ss
  static String formatFullDateTime({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'yyyy-MM-dd HH:mm:ss',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: EEE, dd MMM yyyy (e.g., Mon, 06 Apr 2025)
  static String formatShortWeekdayDate({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'EEE, dd MMM yyyy',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: MMMM dd, yyyy (e.g., April 06, 2025)
  static String formatLongDate({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'MMMM dd, yyyy',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Format: dd MMM yyyy, hh:mm a (e.g., 06 Apr 2025, 03:45 PM)
  static String formatDateTimeWithAmPm({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Get day name (e.g., Monday, Tuesday)
  static String getDayName({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'EEEE',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Get month name (e.g., January, February)
  static String getMonthName({DateTime? dateTime, String? locale}) {
    if (dateTime == null) return '';
    try {
      return DateFormat(
        'MMMM',
        locale ?? AppRouter.navigatorKey.currentContext?.locale.languageCode,
      ).format(dateTime);
    } catch (e) {
      return '';
    }
  }

  /// Get ISO String
  static String toIsoString(DateTime? dateTime) {
    if (dateTime == null) return '';
    try {
      return dateTime.toIso8601String();
    } catch (e) {
      return '';
    }
  }

  /// Formate Datetime to utc Formate for api calls
  static String formatDateForApi(DateTime date) {
    final utcDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
    return utcDate.toIso8601String();
  }

  /// Formate Datetime to yyyy-mm-dd for api calls
  static String formatDateForApiWithFormateYYYYMMDD(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  /// Formate Duration
  static String formatDurationShort({
    required Duration duration,
    required String localizedDaySymbol,
    required String localizedHourSymbol,
    required String localizedMinuteSymbol,
    String? locale,
  }) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    final parts = <String>[];

    if (days > 0) {
      parts.add('$days$localizedDaySymbol');
    }
    if (hours > 0 || days > 0) {
      parts.add('$hours$localizedHourSymbol');
    }
    if (minutes > 0 || parts.isEmpty || hours > 0 || days > 0) {
      parts.add('$minutes$localizedMinuteSymbol');
    }

    return parts.join(' : ');
  }

  /// Format: relative time (e.g., "3 days ago", "in 2 hours")
  static String formatRelativeShort({
    DateTime? dateTime,
    String? locale,
    required String localizedJustNow,
    required String localizedDaysShort,
    required String localizedHoursShort,
    required String localizedMinutesShort,
    required String localizedMonthsShort,
    required String localizedWeeksShort,
    required String localizedYearsShort,
  }) {
    if (dateTime == null) return '';
    try {
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return localizedJustNow;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} $localizedMinutesShort';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} $localizedHoursShort';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} $localizedDaysShort';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks $localizedWeeksShort';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months $localizedMonthsShort';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years $localizedYearsShort';
      }
    } catch (e) {
      return '';
    }
  }

  static Future<void> showDateRangePickerModalSheet({
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    Duration? maxDuration,
    required void Function(DateTime start, DateTime end) onDateRangeSelected,
    required void Function(DateTime start, DateTime end)
    onDateRangeMaxDurationExceeded,
    String? title,
    bool showSheetHolder = true,
    Color? activeColor,
    Color? foregroundColor,
    String? localizedYearTitle,
    String? localizedMonthTitle,
    String? localizedDayTitle,
    String? localizedHourTitle,
    String? localizedMinuteTitle,
    String? localizedSecondTitle,
  }) async {
    final _ctx = AppRouter.navigatorKey.currentContext;
    if (_ctx == null) return;

    final controller = BoardMultiDateTimeController();
    final now = DateTime.now();

    final startDate = initialStartDate ?? now;
    final endDate = initialEndDate ?? now;

    var tempStartDate = startDate;
    var tempEndDate = endDate;

    final result = await showBoardDateTimeMultiPicker(
      context: _ctx,
      radius: 12.0,
      pickerType: DateTimePickerType.datetime,
      startDate: startDate,
      endDate: endDate,
      minimumDate: null,
      maximumDate: null,
      // Range constraints
      controller: controller,
      onChanged: (selection) {
        tempStartDate = selection.start;
        tempEndDate = selection.end;
      },
      options: BoardDateTimeOptions(
        activeColor: activeColor,
        backgroundColor: Colors.white,
        activeTextColor: Colors.white,
        boardTitleBuilder: (_, __, ___) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 12.0,
          children: [
            // Modal Sheet Holder
            if (showSheetHolder)
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xffDFE2EB),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // Modal Sheet title
            if (title?.isNotEmpty ?? false)
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        pickerSubTitles: BoardDateTimeItemTitles(
          year: localizedYearTitle,
          month: localizedMonthTitle,
          day: localizedDayTitle,
          hour: localizedHourTitle,
          minute: localizedMinuteTitle,
          second: localizedSecondTitle,
        ),
        topMargin: 12.0,
        useResetButton: true,
        inputable: true,
        foregroundColor: foregroundColor,
      ),
      customCloseButtonBuilder: (context, isModal, onClose) => IconButton(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        onPressed: () {
          if (maxDuration != null &&
              tempEndDate.difference(tempStartDate) > maxDuration) {
            onDateRangeMaxDurationExceeded(tempStartDate, tempEndDate);
            return;
          }
          onClose.call();
        },
      ),
    );
    // Handle picker result
    if (result != null) {
      final start = result.start;
      final end = result.end;
      if (maxDuration != null && end.difference(start) > maxDuration) {
        onDateRangeMaxDurationExceeded(start, end);
        return;
      }

      onDateRangeSelected(start, end);
    }
  }
}
