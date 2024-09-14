import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potential_plus/constants/app_routes.dart';
import 'package:potential_plus/constants/text_literals.dart';
import 'package:potential_plus/models/app_user.dart';
import 'package:potential_plus/models/institution.dart';
import 'package:potential_plus/models/institution_class.dart';
import 'package:potential_plus/providers/auth_provider.dart';
import 'package:potential_plus/providers/classes_provider.dart';
import 'package:potential_plus/providers/institution_provider.dart';
import 'package:potential_plus/providers/teachers_provider.dart';
import 'package:potential_plus/screens/admin/admin_edit_time_table_screen/admin_edit_period_dialog.dart';
import 'package:potential_plus/shared/institution/select_class_dropdown.dart';
import 'package:potential_plus/shared/app_bar_title.dart';
import 'package:potential_plus/utils.dart';

class AdminEditTimeTableScreen extends ConsumerStatefulWidget {
	const AdminEditTimeTableScreen({super.key});

	@override
  ConsumerState<AdminEditTimeTableScreen> createState() => _AdminEditTimeTableScreenState();
}

class _AdminEditTimeTableScreenState extends ConsumerState<AdminEditTimeTableScreen> {
  InstitutionClass? selectedClass;

  @override
	Widget build(BuildContext context) {

    // Listen to changes in the classesProvider and trigger a setState to refresh the UI
    ref.listen(classesProvider, (_, next) {
      setState(() {
        selectedClass = ref.read(classesProvider).value?.values.where((element) => element.id == selectedClass?.id).first;
      });
    });

    final AsyncValue<AppUser?> user = ref.watch(authProvider);
    final Institution? institution = ref.watch(institutionProvider).value;
    final Map<String, AppUser>? institutionTeachers = ref.watch(teachersProvider).value;

		return Scaffold(
			appBar: AppBar(
				title: const AppBarTitle(title: "Edit Time Table",),
			),
			body: user.when(
        data: (appUser) {
          // Not logged in, redirect to login screen
          if (appUser == null) {
            AppUtils.pushReplacementNamedAfterBuild(context, AppRoutes.login.path);
            return null;
          }

          if (institution == null || institutionTeachers == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (institutionTeachers.isEmpty) {
            return const Center(child: Text("No teachers found"));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectClassDropdown(onValueChanged: (value)  {
                    setState(() { selectedClass = value; });
                  }),

                  const SizedBox(height: 32.0),
                  
                  if(selectedClass != null) _buildTimeTableView(institution, selectedClass!, institutionTeachers),
                ],
              ),
            ),
          );
        },
        error: (error, _) => const Center(child: Text(TextLiterals.authStatusUnkown)),
        loading: () => const Center(child: CircularProgressIndicator())
      ),
		);
	}

  Widget _buildTimeTableView(Institution institution, InstitutionClass selectedClass, Map<String, AppUser>? institutionTeachers) {

    Widget buildPaddedTableCell({ required Widget child, padding = 8.0 }) {
      return TableCell(child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ));
    }

    Widget buildHeaderText(String text) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    Widget buildTimeTableEntryColumn(int periodIndex, int dayofWeekIndex, TimetableEntry? timeTableEntry) {
      return FilledButton.tonal(
        onPressed: () => showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AdminEditPeriodDialog(
              institution: institution,
              selectedClass: selectedClass,
              periodIndex: periodIndex,
              dayofWeekIndex: dayofWeekIndex,
              currentTimeTableEntry: timeTableEntry,
            );
          }
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(timeTableEntry?.subject ?? ''),
              Text(
                institutionTeachers?[timeTableEntry?.teacherId]?.name ?? '',
                style: const TextStyle(
                  fontSize: 10.0
                ),
              ),
            ],
          ),
        ),
      );
    }

   // returns a table with the time table for the selected class
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(
          color: Colors.grey,
          style: BorderStyle.solid,
          borderRadius: BorderRadius.circular(15)
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          // Header row
          TableRow(
            children: [
              buildPaddedTableCell(
                child: buildHeaderText("Period #"),
                padding: 13.0
              ),
              for (int i = 0; i < 7; i++)
                buildPaddedTableCell(
                  child: buildHeaderText(AppUtils.getDayOfWeekByIndex(i)),
                ),
            ]
          ),

          // loop for all periods
          for (int periodIndex = 0; periodIndex <= institution.periodCount - 1; periodIndex++)
            TableRow(
              children: [
                buildPaddedTableCell(child: buildHeaderText("${periodIndex+1}")),
                // loop for all days of the week
                for (int dayOfWeekIndex = 0; dayOfWeekIndex < 7 ; dayOfWeekIndex++)
                  buildPaddedTableCell(
                    child: buildTimeTableEntryColumn(
                      periodIndex,
                      dayOfWeekIndex,
                      // selectedClass.timeTable[dayOfWeekIndex.toString()]?[periodIndex] ?? const TimetableEntry(subject: '', teacherId: '')
                      // Check if dayOfWeekIndex exists and if the periodIndex is within bounds of the list
                      (selectedClass.timeTable[dayOfWeekIndex.toString()] != null &&
                      selectedClass.timeTable[dayOfWeekIndex.toString()]!.length > periodIndex)
                          ? selectedClass.timeTable[dayOfWeekIndex.toString()]![periodIndex]
                          : const TimetableEntry(subject: '', teacherId: ''),
                    )
                  ),
              ]
            ),
        ]),
    );
  }
}