import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/onboarding/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

/// First-run welcome flow: what Kipack does, its main features, a quick
/// tour of how it works. Shown once (see [OnboardingNotifier]) before the real app shell.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pageCount = 3;
  bool get _isLastPage => _page == _pageCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  void _finish() {
    ref.read(onboardingSeenProvider.notifier).markSeen();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: _isLastPage
                  ? null
                  : Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(
                          l10n.onboardingSkip,
                          style: AppTextStyles.body.copyWith(color: secondary),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) => setState(() => _page = index),
                children: const [_WelcomePage(), _FeaturesPage(), _TourPage()],
              ),
            ),
            _DotsIndicator(count: _pageCount, index: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _isLastPage ? l10n.onboardingStart : l10n.onboardingNext,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent
                : AppColors.secondaryIcon.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_travel_rounded,
              size: 44,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l10n.onboardingWelcomeTitle,
            style: AppTextStyles.headline.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingWelcomeBody,
            style: AppTextStyles.body.copyWith(color: secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(color: secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesPage extends StatelessWidget {
  const _FeaturesPage();

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              l10n.onboardingFeaturesTitle,
              style: AppTextStyles.headline.copyWith(color: onSurface),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          _FeatureRow(
            icon: Icons.auto_awesome_rounded,
            title: l10n.onboardingFeatureAiListsTitle,
            description: l10n.onboardingFeatureAiListsDescription,
          ),
          _FeatureRow(
            icon: Icons.public_rounded,
            title: l10n.onboardingFeatureMapTitle,
            description: l10n.onboardingFeatureMapDescription,
          ),
          _FeatureRow(
            icon: Icons.bookmark_rounded,
            title: l10n.onboardingFeatureTemplatesTitle,
            description: l10n.onboardingFeatureTemplatesDescription,
          ),
          _FeatureRow(
            icon: Icons.notifications_active_rounded,
            title: l10n.onboardingFeatureRemindersTitle,
            description: l10n.onboardingFeatureRemindersDescription,
          ),
          _FeatureRow(
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.onboardingFeaturePdfTitle,
            description: l10n.onboardingFeaturePdfDescription,
          ),
        ],
      ),
    );
  }
}

/// A small interactive simulation of the trip → AI list → checklist →
/// share flow, so the "how it works" step is something the user actually
/// taps through instead of a static list of steps. Entirely self-contained
/// fake data — it doesn't touch any real provider or navigate anywhere.
enum _DemoPhase { form, generating, checklist, share }

class _TourPage extends StatefulWidget {
  const _TourPage();

  @override
  State<_TourPage> createState() => _TourPageState();
}

class _TourPageState extends State<_TourPage> {
  _DemoPhase _phase = _DemoPhase.form;
  final Set<int> _checked = {};

  List<String> _demoItems(AppLocalizations l10n) => [
    l10n.onboardingDemoItemPassport,
    l10n.onboardingDemoItemRaincoat,
    l10n.onboardingDemoItemCharger,
  ];

  void _generate() {
    setState(() => _phase = _DemoPhase.generating);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _phase = _DemoPhase.checklist);
    });
  }

  void _toggleItem(int index) {
    setState(() {
      if (!_checked.add(index)) _checked.remove(index);
    });
  }

  void _showShare() => setState(() => _phase = _DemoPhase.share);

  void _reset() => setState(() {
    _phase = _DemoPhase.form;
    _checked.clear();
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.onboardingTourTitle,
            style: AppTextStyles.headline.copyWith(color: onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10n.onboardingTourSubtitle,
            style: AppTextStyles.body.copyWith(color: secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(22),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: switch (_phase) {
                _DemoPhase.form => _buildFormPhase(l10n, onSurface, secondary),
                _DemoPhase.generating => _buildGeneratingPhase(l10n, onSurface),
                _DemoPhase.checklist => _buildChecklistPhase(
                  l10n,
                  onSurface,
                  secondary,
                ),
                _DemoPhase.share => _buildSharePhase(
                  l10n,
                  onSurface,
                  secondary,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPhase(
    AppLocalizations l10n,
    Color onSurface,
    Color? secondary,
  ) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingTourStep1Title,
          style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.place_outlined, size: 18, color: secondary),
            const SizedBox(width: 8),
            Text(
              l10n.onboardingDemoDestination,
              style: AppTextStyles.body.copyWith(color: onSurface),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: secondary),
            const SizedBox(width: 8),
            Text(
              l10n.onboardingDemoDates,
              style: AppTextStyles.body.copyWith(color: onSurface),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(l10n.onboardingGenerateButton),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratingPhase(AppLocalizations l10n, Color onSurface) {
    return Padding(
      key: const ValueKey('generating'),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingTourStep2Title,
            style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistPhase(
    AppLocalizations l10n,
    Color onSurface,
    Color? secondary,
  ) {
    final demoItems = _demoItems(l10n);
    final progress = _checked.length / demoItems.length;
    return Column(
      key: const ValueKey('checklist'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingTourStep3Title,
          style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.onboardingTourStep3Subtitle,
          style: AppTextStyles.caption.copyWith(color: secondary),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < demoItems.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleItem(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    _checked.contains(i)
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 20,
                    color: _checked.contains(i) ? AppColors.accent : secondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    demoItems[i],
                    style: AppTextStyles.body.copyWith(
                      color: _checked.contains(i) ? secondary : onSurface,
                      decoration: _checked.contains(i)
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _checked.length == demoItems.length ? _showShare : null,
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(l10n.onboardingSeeHowToShareButton),
          ),
        ),
      ],
    );
  }

  Widget _buildSharePhase(
    AppLocalizations l10n,
    Color onSurface,
    Color? secondary,
  ) {
    return Column(
      key: const ValueKey('share'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.onboardingTourStep4Title,
          style: AppTextStyles.bodyStrong.copyWith(color: onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.onboardingTourStep4Subtitle,
          style: AppTextStyles.caption.copyWith(color: secondary),
        ),
        const SizedBox(height: 12),
        _buildShareMenuRow(
          Icons.playlist_add_rounded,
          l10n.shareMenuApplyTemplate,
          onSurface,
        ),
        _buildShareMenuRow(
          Icons.picture_as_pdf_outlined,
          l10n.onboardingExportPdfRow,
          onSurface,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _reset,
            child: Text(
              l10n.onboardingTryAgainButton,
              style: AppTextStyles.body.copyWith(color: secondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareMenuRow(IconData icon, String label, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: onSurface),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.body.copyWith(color: onSurface)),
        ],
      ),
    );
  }
}
