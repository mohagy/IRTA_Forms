import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.sidebarStart,
                    AppColors.sidebarEnd,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
              child: Column(
                children: [
                  const Text(
                    'IRTA Forms Management System',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'International Road Transport Agreement',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Between the Cooperative Republic of Guyana and the Federative Republic of Brazil',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // About Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 64),
              child: Column(
                children: [
                  const Text(
                    'About IRTA',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 800,
                    child: Text(
                      'The International Road Transport Agreement (IRTA) facilitates road transport services between '
                      'Guyana and Brazil. This digital platform streamlines the application process, making it easier '
                      'for individuals and businesses to obtain the necessary documents for international road transport operations.',
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textTertiary,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Feature Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.description,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFeff6ff),
                      title: 'Easy Application',
                      description:
                          'Submit your IRTA application online with our intuitive step-by-step process. Save drafts and complete at your convenience.',
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.check_circle,
                      iconColor: AppColors.statusCompleted,
                      iconBg: const Color(0xFFf0fdf4),
                      title: 'Track Progress',
                      description:
                          'Monitor your application status in real-time. Receive notifications at each stage of the review process.',
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _FeatureCard(
                      icon: Icons.lock,
                      iconColor: AppColors.statusSubmitted,
                      iconBg: const Color(0xFFfef3c7),
                      title: 'Secure & Safe',
                      description:
                          'Your data is protected with industry-standard security measures. All documents are encrypted and securely stored.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Call to Action Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFeff6ff),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Ready to Get Started?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create an account to begin your IRTA application process',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => context.push(AppConstants.routeRegistration),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Register as Applicant'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () => context.push(AppConstants.routeLogin),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Footer
            Container(
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2024 IRTA Administration | Ministry of Home Affairs',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lot 6 Brickdam, Stabroek, Georgetown, Guyana, South America',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textTertiary,
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
