import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../../utils/strings.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    _buildPunchButton(),
                    const SizedBox(height: 24),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        AppStrings.homeTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.white),
          onPressed: controller.refreshData,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.white),
          onPressed: controller.logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                '${AppStrings.welcomeBack}, ${controller.userName}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.homeState.value.userEmail,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withOpacity(0.9),
                ),
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Obx(() => Text(
                    controller.homeState.value.currentTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Obx(() => Text(
                    controller.homeState.value.currentDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                    ),
                  )),
            ],
          ),
          // Location indicator
          
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Obx(() {
      final state = controller.homeState.value;
      final color = state.isPunchedIn ? AppColors.punchIn : AppColors.punchOut;
      final icon = state.isPunchedIn ? Icons.check_circle : Icons.cancel;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.currentStatus,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            if (state.lastPunchInTime != null || state.lastPunchOutTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last action at ${state.lastActionTime}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPunchButton() {
    return Obx(() {
      final state = controller.homeState.value;
      final color = state.isPunchedIn ? AppColors.punchOut : AppColors.punchIn;
      final icon = state.isPunchedIn ? Icons.logout : Icons.login;
      final isProcessing = state.isLoading || state.isFetchingLocation;

      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isProcessing ? null : controller.togglePunch,
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.isFetchingLocation ? 'Getting location...' : 'Processing...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 60, color: AppColors.white),
                        const SizedBox(height: 16),
                        Text(
                          state.buttonText,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: AppColors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Location will be recorded',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final state = controller.homeState.value;
      
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.timer_outlined,
              title: 'Work Duration',
              value: state.formattedWorkDuration,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.event_available,
              title: 'Status',
              value: state.statusText,
              color: state.isPunchedIn ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: AppColors.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Privacy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your location is only recorded during punch in/out for attendance verification.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
