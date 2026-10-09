import 'package:barcode_widget/barcode_widget.dart';
import 'package:campus_mobile_experimental/app_constants.dart';
import 'package:campus_mobile_experimental/app_styles.dart';
import 'package:campus_mobile_experimental/core/models/student_id_name.dart';
import 'package:campus_mobile_experimental/core/models/student_id_profile.dart';
import 'package:campus_mobile_experimental/core/providers/cards.dart';
import 'package:campus_mobile_experimental/core/providers/student_id.dart';
import 'package:campus_mobile_experimental/ui/common/card_container.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentIdCard extends StatefulWidget {
  @override
  _StudentIdCardState createState() => _StudentIdCardState();
}

class _StudentIdCardState extends State<StudentIdCard> {
  static const CARD_ID = "student_id";

  /// Pop up barcode
  createAlertDialog(BuildContext context) {
    final sessionId = context.read<StudentIdDataProvider>().sessionId;
    return showDialog(
      context: context,
      builder: (context) {
        final studentId = context.watch<StudentIdDataProvider>();
        final media = MediaQuery.of(context);
        final dialogSize = Size(
          media.size.width - media.padding.horizontal - media.viewInsets.horizontal - 48,
          media.size.height - media.padding.vertical - media.viewInsets.vertical - 48,
        );
        return AlertDialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(24),
          constraints: BoxConstraints.tight(dialogSize),
          title: Text("Student ID", style: TextStyle(color: Colors.black)),
          content: studentId.hasBarcode && studentId.sessionId == sessionId
              ? SizedBox(
                  key: const ValueKey('student-id-scanning-area'),
                  width: dialogSize.width,
                  height: dialogSize.height,
                  child: _buildScanningBarcode(studentId.studentIdProfileModel.barcode, context),
                )
              : const Text('Barcode unavailable', style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanningBarcode(String barcode, BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Align(
      alignment: Alignment.topCenter,
      child: RotatedBox(
        quarterTurns: MediaQuery.orientationOf(context) == Orientation.portrait ? 1 : 0,
        child: ConstrainedBox(
          // Limit bar length before rotation; leave room for its printed number.
          constraints: const BoxConstraints(maxHeight: 120 + 12 + 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BarcodeWidget(
                  barcode: Barcode.codabar(),
                  data: barcode,
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  drawText: false,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 28,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(barcode, style: const TextStyle(color: Colors.black, fontSize: 24, letterSpacing: 6)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final studentId = context.watch<StudentIdDataProvider>();

    return CardContainer(
      cardId: CARD_ID,
      actionButtonsPadding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
      active: context.select((CardsDataProvider p) => p.cardStates[CARD_ID] ?? false),
      hide: () => Provider.of<CardsDataProvider>(context, listen: false).toggleCard(CARD_ID),
      reload: () => Provider.of<StudentIdDataProvider>(context, listen: false).fetchData(),
      isLoading: !studentId.hasUsableContent && studentId.hasPendingWork,
      titleText: CardTitleConstants.TITLE_MAP[CARD_ID]!,
      errorText: !studentId.hasUsableContent && !studentId.hasPendingWork
          ? 'An error occurred, please try again.'
          : null,
      child: () => buildCardContent(studentId, context),
    );
  }

  Widget buildCardContent(StudentIdDataProvider studentId, BuildContext context) {
    try {
      final nameModel = studentId.studentIdNameModel;
      final profileModel = studentId.studentIdProfileModel;
      final hasClassification = profileModel.classificationType.isNotEmpty;
      final hasMajor = profileModel.major.isNotEmpty;
      final hasCollege = profileModel.collegeCurrent.isNotEmpty;
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPhoto(studentId, constraints.maxWidth),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (studentId.hasName || !studentId.isNameLoading) _buildName(nameModel),
                    if (studentId.isNameLoading) _sectionLoading('Loading name'),
                    if (hasClassification) ...[const SizedBox(height: 4), _buildClassificationTitle(profileModel)],
                    if (hasMajor || hasCollege)
                      Divider(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? listTileDividerColorDark
                            : listTileDividerColorLight,
                        thickness: 1,
                        height: 16,
                      ),
                    if (hasMajor) _buildMajorName(profileModel),
                    if (hasCollege) ...[if (hasMajor) const SizedBox(height: 4), _buildCollegeName(profileModel)],
                    if (studentId.isProfileLoading) _sectionLoading('Loading profile'),
                    if (studentId.hasBarcode) ...[
                      const SizedBox(height: 8),
                      _buildBarcode(profileModel),
                    ] else if (!studentId.isProfileLoading) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Barcode unavailable',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
        e,
        StackTrace.fromString(e.toString()),
        reason: "Student ID Card: Failed to build card content.",
        fatal: false,
      );
      return Container(
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 32, bottom: 48),
            child: Container(
              child: Text(
                "Your Student ID could not be displayed.\n\nIf the problem persists contact mobilesupport@ucsd.edu",
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _sectionLoading(String label) => Semantics(
    label: label,
    child: Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.secondary),
      ),
    ),
  );

  Widget _buildPhoto(StudentIdDataProvider studentId, double availableWidth) {
    final width = (availableWidth * 0.30).clamp(0.0, 120.0);
    return SizedBox(
      key: const ValueKey('student-id-photo'),
      width: width,
      height: width * 1.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (studentId.hasPhoto)
              RawImage(image: studentId.studentPhoto, fit: BoxFit.contain, alignment: Alignment.topCenter)
            else if (!studentId.isPhotoLoading)
              Image.asset(
                'assets/images/staff_id_placeholder.png',
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            if (studentId.isPhotoLoading) Center(child: SizedBox(width: 16, child: _sectionLoading('Loading photo'))),
          ],
        ),
      ),
    );
  }

  Widget _buildName(StudentIdNameModel nameModel) => Text(
    nameModel.displayName.isNotEmpty ? nameModel.displayName : 'Name unavailable',
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontFamily: 'Brix Sans', fontWeight: FontWeight.w500, fontSize: 20, height: 1.2),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildClassificationTitle(StudentIdProfileModel profileModel) => Text(
    profileModel.classificationType,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, height: 1.3),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildMajorName(StudentIdProfileModel profileModel) => Text(
    profileModel.major,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildCollegeName(StudentIdProfileModel profileModel) => Text(
    profileModel.collegeCurrent,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14, height: 1.3),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildBarcode(StudentIdProfileModel profileModel) => TextButton(
    style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    onPressed: () => createAlertDialog(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'tap for easier scanning',
          textAlign: TextAlign.center,
          style: (Theme.of(context).brightness == Brightness.dark ? linkTextDark : linkTextLight).copyWith(
            fontSize: 14,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const ValueKey('student-id-inline-barcode'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarcodeWidget(
                  barcode: Barcode.codabar(),
                  data: profileModel.barcode,
                  height: (constraints.maxWidth / 7).clamp(40.0, 64.0),
                  color: Colors.black,
                  backgroundColor: Colors.white,
                  drawText: false,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    profileModel.barcode,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'Brix Sans',
                      fontSize: 14,
                      letterSpacing: 2,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Image Scaling
class ScalingUtility {
  late MediaQueryData _queryData;
  static late double horizontalSafeBlock;
  static late double verticalSafeBlock;

  void getCurrentMeasurements(BuildContext context) {
    /// Find screen size
    _queryData = MediaQuery.of(context);

    /// Calculate blocks accounting for notches and home bar
    horizontalSafeBlock = (_queryData.size.width - (_queryData.padding.left + _queryData.padding.right)) / 100;
    verticalSafeBlock = (_queryData.size.height - (_queryData.padding.top + _queryData.padding.bottom)) / 100;
  }
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
