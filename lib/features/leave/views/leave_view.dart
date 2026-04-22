import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../models/leave_history_model.dart';
import '../models/leave_type_model.dart';
import '../viewmodels/leave_viewmodel.dart';

class LeaveView extends GetView<LeaveViewModel> {
  const LeaveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              color: const Color(0xFFE8EAF0),
              child: Obx(
                () =>
                    controller.leaveState.value.isApplyTabSelected
                        ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                          child: _buildApplyPanel(context),
                        )
                        : _buildHistoryPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(18, topPadding + 14, 18, 0),
      child: Column(
        children: [
          Row(
            children: [
              _buildHeaderCircleButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: Get.back,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.leaveManagement,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      AppStrings.leaveTabSubtitle,
                      style: TextStyle(fontSize: 12, color: Color(0xD9FFFFFF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Obx(() => _buildTabs(controller.leaveState.value.isApplyTabSelected)),
        ],
      ),
    );
  }

  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildTabs(bool isApplyTabSelected) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: AppStrings.applyLeave,
            isSelected: isApplyTabSelected,
            onTap: () => controller.selectTab(true),
            isLeftTab: true,
          ),
          _buildTabButton(
            label: AppStrings.leaveHistory,
            isSelected: !isApplyTabSelected,
            onTap: () => controller.selectTab(false),
            isLeftTab: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLeftTab,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.white.withValues(alpha: 0.18)
                    : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isLeftTab ? 12 : 0),
              topRight: Radius.circular(isLeftTab ? 0 : 12),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  isSelected
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8DBE8)),
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final state = controller.leaveState.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel(AppStrings.leaveType),
            const SizedBox(height: 6),
            _buildDropdownField(
              value: state.selectedLeaveType,
              items: state.leaveTypes,
              isLoading: state.isLoadingLeaveTypes,
              onChanged: controller.selectLeaveType,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: AppStrings.fromDate,
                    value: state.fromDate,
                    onTap: () => controller.pickFromDate(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDateField(
                    label: AppStrings.toDate,
                    value: state.toDate,
                    onTap: () => controller.pickToDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildDurationPill(state.durationText),
            const SizedBox(height: 14),
            _buildFieldLabel(AppStrings.session),
            const SizedBox(height: 6),
            Row(
              children:
                  controller.sessionOptions
                      .map(
                        (session) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right:
                                  session == controller.sessionOptions.last
                                      ? 0
                                      : 7,
                            ),
                            child: _buildSessionChip(
                              label: session,
                              isSelected: state.selectedSession == session,
                              onTap: () => controller.selectSession(session),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 14),
            _buildFieldLabel(AppStrings.reason),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.reasonController,
              hintText: AppStrings.reasonHint,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
            ),
            const SizedBox(height: 18),
            _buildSubmitButton(state.isSubmitting),
          ],
        );
      }),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildDropdownField({
    required LeaveTypeItem? value,
    required List<LeaveTypeItem> items,
    required bool isLoading,
    required ValueChanged<LeaveTypeItem?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0D4E0)),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(canvasColor: AppColors.white),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<LeaveTypeItem>(
            value: value,
            isExpanded: true,
            hint: Text(
              isLoading
                  ? AppStrings.loadingLeaveTypes
                  : AppStrings.noLeaveTypesAvailable,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
            dropdownColor: AppColors.white,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            items:
                items
                    .map(
                      (item) => DropdownMenuItem<LeaveTypeItem>(
                        value: item,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
            onChanged: items.isEmpty ? null : onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    final formatter = DateFormat('dd MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 6),
        Material(
          color: const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD0D4E0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formatter.format(value),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPill(String durationText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFFE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Text(
            durationText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECEFFE) : const Color(0xFFF7F8FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFD0D4E0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D4E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D4E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : controller.submitLeaveApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.65),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child:
            isSubmitting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
                : const Text(
                  AppStrings.submitApplication,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Obx(() {
      final state = controller.leaveState.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    controller.filterOptions
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: _buildFilterChip(
                              label: filter,
                              isSelected: state.selectedFilter == filter,
                              onTap: () => controller.selectFilter(filter),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child:
                state.isLoadingHistory
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                      child: _buildLoadingHistoryState(),
                    )
                    : state.filteredHistoryItems.isEmpty
                    ? Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                      child: _buildEmptyHistoryState(),
                    )
                    : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                      itemCount: state.filteredHistoryItems.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(
                          state.filteredHistoryItems[index],
                        );
                      },
                    ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? null
                  : Border.all(color: const Color(0xFFD0D4E0), width: 0.8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(LeaveHistoryItem item) {
    final statusColors = _statusColors(item.status);
    final appliedOn = DateFormat('MMM d, yyyy').format(item.appliedOn);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.leaveType,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.dateRangeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColors.$1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColors.$2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFECEEF4)),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.reasonPrefix} ${item.reason}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.durationText} • ${AppStrings.appliedOn} $appliedOn',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9EA3B5)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DBE8)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 32, color: AppColors.textTertiary),
          SizedBox(height: 10),
          Text(
            'No leave requests found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different filter or submit a new leave request.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingHistoryState() {
    return const Column(
      children: [
        _HistoryShimmerCard(),
        SizedBox(height: 10),
        _HistoryShimmerCard(),
        SizedBox(height: 10),
        _HistoryShimmerCard(),
      ],
    );
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case AppStrings.approved:
        return (const Color(0xFFE6F5EF), const Color(0xFF1E7A50));
      case AppStrings.rejected:
        return (const Color(0xFFFDECEC), const Color(0xFFB83030));
      default:
        return (const Color(0xFFFFF3E8), const Color(0xFFC96A1A));
    }
  }
}

class _HistoryShimmerCard extends StatelessWidget {
  const _HistoryShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EBF3),
      highlightColor: const Color(0xFFF8F9FC),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8DBE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.42,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFE8EBF3),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: SizedBox(height: 14),
                        ),
                      ),
                      SizedBox(height: 8),
                      FractionallySizedBox(
                        widthFactor: 0.58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFE8EBF3),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: SizedBox(height: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFE8EBF3),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: SizedBox(width: 72, height: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFECEEF4)),
            const SizedBox(height: 10),
            const FractionallySizedBox(
              widthFactor: 0.86,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFE8EBF3),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: SizedBox(height: 12),
              ),
            ),
            const SizedBox(height: 8),
            const FractionallySizedBox(
              widthFactor: 0.54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFE8EBF3),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: SizedBox(height: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
