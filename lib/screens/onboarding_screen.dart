import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              const SizedBox(height: AppSpacing.xl3),
              _buildTitle(),
              const SizedBox(height: AppSpacing.md),
              _buildSubtitle(),
              const Spacer(flex: 2),
              _buildGetStartedButton(),
              const SizedBox(height: AppSpacing.md),
              _buildTagline(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlack, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.medication, size: 64, color: AppColors.primaryBlack),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'MediRemind',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryBlack,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Never miss a dose. Stay on track\nwith your medication schedule.',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.gray500,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGetStartedButton() {
    return AppButton(
      text: 'Get Started',
      variant: ButtonVariant.primary,
      size: ButtonSize.large,
      fullWidth: true,
      onPressed: onGetStarted,
    );
  }

  Widget _buildTagline() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 14, color: AppColors.gray400, height: 1.5),
        children: [
          TextSpan(text: 'Your health, '),
          TextSpan(
            text: 'simplified',
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
