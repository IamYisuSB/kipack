import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import 'privacy_policy_text.dart';

/// Displays [privacyPolicyText], splitting it into sections at each line
/// starting with `# ` so headings render distinctly from body text without
/// needing a markdown-rendering package for a single static document.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodySmall?.color;
    final blocks = privacyPolicyText.trim().split('\n\n');

    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidad')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index].trim();
            final isHeading = block.startsWith('# ');
            final text = isHeading ? block.substring(2) : block;
            return Padding(
              padding: EdgeInsets.only(
                bottom: isHeading ? 8 : 18,
                top: isHeading && index != 0 ? 10 : 0,
              ),
              child: Text(
                text,
                style: isHeading
                    ? AppTextStyles.subtitle.copyWith(color: onSurface)
                    : AppTextStyles.body.copyWith(
                        color: secondary,
                        height: 1.5,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
