import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/application_model.dart';
import 'status_badge.dart';
import 'package:intl/intl.dart';

class ApplicationsTable extends StatelessWidget {
  final List<ApplicationModel> applications;
  final Function(ApplicationModel)? onRowTap;
  final bool isApplicantView;

  const ApplicationsTable({
    super.key,
    required this.applications,
    this.onRowTap,
    this.isApplicantView = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            decoration: const BoxDecoration(
              color: AppColors.tableHeaderBg,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 2),
              ),
            ),
            child: Table(
              columnWidths: _getColumnWidths(),
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 2),
                    ),
                  ),
                  children: _buildHeaders(),
                ),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: applications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No applications found',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Table(
                      columnWidths: _getColumnWidths(),
                      children: applications.map((app) {
                        return TableRow(
                          decoration: BoxDecoration(
                            border: const Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                            color: Colors.transparent,
                          ),
                          children: _buildRow(app, dateFormat),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    if (isApplicantView) {
      return {
        0: const FlexColumnWidth(1.5), // IRTA Ref #
        1: const FlexColumnWidth(1.2), // Form Type
        2: const FlexColumnWidth(1.5), // Purpose
        3: const FlexColumnWidth(1.5), // Submission Date
        4: const FlexColumnWidth(1.2), // Status
        5: const FlexColumnWidth(1.0), // Actions
      };
    } else {
      return {
        0: const FlexColumnWidth(1.5), // IRTA Ref #
        1: const FlexColumnWidth(1.2), // Form Type
        2: const FlexColumnWidth(1.5), // Applicant Name
        3: const FlexColumnWidth(1.2), // Nationality
        4: const FlexColumnWidth(1.5), // Submission Date
        5: const FlexColumnWidth(1.2), // Status
        6: const FlexColumnWidth(1.2), // Assigned Officer
        7: const FlexColumnWidth(1.0), // Actions
      };
    }
  }

  List<Widget> _buildHeaders() {
    if (isApplicantView) {
      return [
        _buildHeaderCell('IRTA Ref #'),
        _buildHeaderCell('Form Type'),
        _buildHeaderCell('Purpose'),
        _buildHeaderCell('Submission Date'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Actions'),
      ];
    } else {
      return [
        _buildHeaderCell('IRTA Ref #'),
        _buildHeaderCell('Form Type'),
        _buildHeaderCell('Applicant Name'),
        _buildHeaderCell('Nationality'),
        _buildHeaderCell('Submission Date'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Assigned Officer'),
        _buildHeaderCell('Actions'),
      ];
    }
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  List<Widget> _buildRow(ApplicationModel app, DateFormat dateFormat) {
    if (isApplicantView) {
      return [
        _buildCell(Text(
          app.irtaRef,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ), onTap: () => onRowTap?.call(app)),
        _buildCell(Text(app.formType)),
        _buildCell(Text(app.purpose ?? '-')),
        _buildCell(Text(dateFormat.format(app.submissionDate))),
        _buildCell(StatusBadge(status: app.status)),
        _buildCell(
          TextButton(
            onPressed: () => onRowTap?.call(app),
            child: const Text('View'),
          ),
        ),
      ];
    } else {
      return [
        _buildCell(Text(
          app.irtaRef,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ), onTap: () => onRowTap?.call(app)),
        _buildCell(Text(app.formType)),
        _buildCell(Text(app.applicantName)),
        _buildCell(Text(app.nationality ?? '-')),
        _buildCell(Text(dateFormat.format(app.submissionDate))),
        _buildCell(StatusBadge(status: app.status)),
        _buildCell(Text(app.assignedOfficer ?? '-')),
        _buildCell(
          TextButton(
            onPressed: () => onRowTap?.call(app),
            child: const Text('View'),
          ),
        ),
      ];
    }
  }

  Widget _buildCell(Widget child, {VoidCallback? onTap}) {
    final widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: widget,
        ),
      );
    }

    return widget;
  }
}

