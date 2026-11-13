import 'dart:convert';

import 'package:campus_mobile_experimental/core/models/scheduled_class.dart';
import 'package:campus_mobile_experimental/core/services/classes_calendar.dart';
import 'package:campus_mobile_experimental/ui/common/app_snack_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:share_plus/share_plus.dart';

/// Share and save actions for the exported quarter `.ics` snapshot.
class ClassCalendarExportActions extends StatefulWidget {
  const ClassCalendarExportActions({super.key, required this.calendar});

  final ClassCalendarData calendar;

  @override
  State<ClassCalendarExportActions> createState() => _ClassCalendarExportActionsState();
}

class _ClassCalendarExportActionsState extends State<ClassCalendarExportActions> {
  static const _icsMimeType = 'text/calendar';

  bool _busy = false;

  bool get _hasExportableMeetings => widget.calendar.occurrences.isNotEmpty;

  List<String> get _notExportable => [
    ...widget.calendar.omissions,
    for (final meeting in widget.calendar.undated) _meetingLabel(meeting),
  ];

  @override
  Widget build(BuildContext context) {
    final notExportable = _notExportable;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_hasExportableMeetings) const Text('No meetings to export.', textAlign: TextAlign.left),
        if (notExportable.isNotEmpty) ...[
          const Text('Some meetings could not be exported.', textAlign: TextAlign.left),
          for (final entry in notExportable) Text(entry, textAlign: TextAlign.left),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _hasExportableMeetings && !_busy ? _share : null,
              child: const Text('Share .ics'),
            ),
            OutlinedButton(onPressed: _hasExportableMeetings && !_busy ? _save : null, child: const Text('Save .ics')),
            TextButton(onPressed: () => _showImportInstructions(context), child: const Text('Import instructions')),
          ],
        ),
      ],
    );
  }

  Future<void> _share() async {
    if (_busy || !_hasExportableMeetings) return;
    setState(() => _busy = true);
    try {
      final ics = createClassesCalendarIcs(widget.calendar);
      if (ics == null) {
        _showNoEligibleNotice();
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(utf8.encode(ics), mimeType: _icsMimeType)],
          fileNameOverrides: [_exportFileName(widget.calendar)],
          sharePositionOrigin: _sharePositionOrigin(),
        ),
      );
      // The OS handoff completing is not an import, so no success message.
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Unable to share the .ics file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_busy || !_hasExportableMeetings) return;
    setState(() => _busy = true);
    try {
      final ics = createClassesCalendarIcs(widget.calendar);
      if (ics == null) {
        _showNoEligibleNotice();
        return;
      }
      final fileName = _exportFileName(widget.calendar);
      final savedPath = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: Uint8List.fromList(utf8.encode(ics)),
          fileName: fileName,
          mimeTypesFilter: const [_icsMimeType],
        ),
      );
      if (savedPath != null && mounted) {
        // Confirm the requested file name; Android may return a document
        // identifier rather than a readable path.
        AppSnackBar.show(context, 'Saved $fileName');
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, 'Unable to save the .ics file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showNoEligibleNotice() {
    if (mounted) AppSnackBar.show(context, 'No meetings to export.');
  }

  Rect? _sharePositionOrigin() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.localToGlobal(Offset.zero) & renderObject.size;
    }
    return null;
  }

  void _showImportInstructions(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Import instructions'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Google Calendar on the web: open calendar.google.com, '
              'go to Settings, then Import & export.',
            ),
            SizedBox(height: 8),
            Text(
              'Apple Calendar on a Mac: open the .ics file, '
              'or use File > Import in Calendar.',
            ),
            SizedBox(height: 8),
            Text(
              'Outlook on the web: go to outlook.live.com/calendar, '
              'Add calendar, then Upload from file.',
            ),
            SizedBox(height: 8),
            Text(
              'The .ics file is a snapshot. It will not refresh when your '
              'schedule changes; re-export and import again, and importing '
              'may create duplicate events.',
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('OK'))],
    ),
  );
}

String _exportFileName(ClassCalendarData calendar) {
  final label = calendar.quarter?.label.toLowerCase();
  final slug = label?.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  if (slug == null || slug.isEmpty) return 'classes.ics';
  return 'classes-$slug.ics';
}

String _meetingLabel(ScheduledClass meeting) {
  final subject = meeting.subjectCode ?? '';
  final code = meeting.courseCode ?? '';
  final type = meeting.section.meetingType ?? '';
  return [subject, code, type].where((part) => part.isNotEmpty).join(' ');
}
