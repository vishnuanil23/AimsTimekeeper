import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/strings.dart';
import 'punch_out_dialog.dart';
import '../viewmodels/home_viewmodel.dart';

class PunchButton extends StatefulWidget {
  final HomeViewModel controller;

  const PunchButton({Key? key, required this.controller}) : super(key: key);

  @override
  State<PunchButton> createState() => _PunchButtonState();
}

class _PunchButtonState extends State<PunchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = widget.controller.homeState.value;
      final color = state.isPunchedIn ? AppColors.punchOut : AppColors.punchIn;
      final icon = state.isPunchedIn ? Icons.logout : Icons.login;
      final isProcessing = state.isLoading || state.isFetchingLocation;

      // Adjust animation based on state?
      // User requested:
      // Not Punched (Green): Subtle glowing (scale)
      // Punched In (Red): Breathing animation (shadow spread/opacity + scale)

      // Let's use scale for both but maybe different intensity if needed.
      // Or shadow for "breathing".

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double curvedValue = Curves.easeInOut.transform(
            _controller.value,
          );

          final scale =
              state.isPunchedIn
                  ? 1.0 +
                      (curvedValue * 0.05) // Red: 1.0 -> 1.05
                  : 1.0 + (curvedValue * 0.02); // Green: 1.0 -> 1.02 (Subtle)

          final shadowSpread =
              state.isPunchedIn
                  ? 5.0 +
                      (curvedValue * 8.0) // Red: 5 -> 13
                  : 5.0 + (curvedValue * 2.0); // Green: 5 -> 7

          final shadowOpacity =
              state.isPunchedIn
                  ? 0.4 +
                      (curvedValue * 0.2) // Red: 0.4 -> 0.6
                  : 0.4 + (curvedValue * 0.1); // Green: 0.4 -> 0.5

          return Transform.scale(
            scale: isProcessing ? 1.0 : scale,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: shadowOpacity),
                    blurRadius: 30 + (_controller.value * 10),
                    offset: const Offset(0, 15),
                    spreadRadius: shadowSpread,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      isProcessing
                          ? null
                          : () {
                            if (!state.isPunchedIn) {
                              widget.controller.togglePunch();
                              return;
                            }

                            showDialog<void>(
                              context: context,
                              builder:
                                  (context) => PunchOutDialog(
                                    onConfirm: widget.controller.togglePunch,
                                    loggedDuration:
                                        widget.controller.workDuration.value,
                                  ),
                            );
                          },
                  borderRadius: BorderRadius.circular(30),
                  child: Center(
                    child:
                        isProcessing
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.isFetchingLocation
                                      ? AppStrings.gettingLocation
                                      : AppStrings.processing,
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
                                    Icon(
                                      Icons.location_on,
                                      color: AppColors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      AppStrings.locationWillBeRecorded,
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
            ),
          );
        },
      );
    });
  }
}
