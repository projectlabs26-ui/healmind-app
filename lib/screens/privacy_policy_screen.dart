import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection(
            icon: Icons.info_outline,
            title: '1. Introduction',
            content: '''HealMind ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application HealMind (the "App").

Please read this Privacy Policy carefully. By using the App, you agree to the collection and use of information in accordance with this policy. If you do not agree with the terms of this Privacy Policy, please do not access the App.''',
          ),
          _buildSection(
            icon: Icons.phone_android,
            title: '2. Information We Collect',
            subsections: [
              _buildSubSection(
                'a. Data You Provide Directly',
                '''• Journal entries (thoughts, feelings, gratitude notes)
• Mood check-ins (emotional states you select)
• Breathing session preferences
• CBT thought records and reflections
• App settings and preferences

IMPORTANT: All this data is stored locally on your device using Hive (local database). We do NOT have access to your journal entries, mood data, or any personal content you create in the App.''',
              ),
              _buildSubSection(
                'b. Data Collected Automatically (via Google AdMob)',
                '''When you use our App, Google AdMob may automatically collect:

• Advertising ID (Google Advertising ID / GAID)
• IP address (used for approximate location and fraud prevention)
• Device information (model, manufacturer, OS version, screen size)
• Coarse location (derived from IP address, not precise GPS)
• App usage data (session duration, ad interactions)
• Language settings
• Network type (WiFi, cellular)

This data is collected by Google and its advertising partners, not by us directly. Google's collection is governed by Google's own Privacy Policy.''',
              ),
            ],
          ),
          _buildSection(
            icon: Icons.ads_click,
            title: '3. How We Use Information',
            content: '''We use the information we collect for the following purposes:

• To provide and maintain the App's core functionality
• To display advertisements through Google AdMob (to keep the App free)
• To personalize your ad experience (Google uses your data for ad targeting)
• To analyze App usage and improve user experience
• To detect and prevent fraud or abuse
• To comply with legal obligations''',
          ),
          _buildSection(
            icon: Icons.share,
            title: '4. Information Sharing & Disclosure',
            content: '''We do NOT sell your personal data. However, we share certain data with:

• Google AdMob / Google LLC: Advertising ID, device info, IP address, and ad interaction data are shared with Google for ad serving and measurement purposes.

• Third-party Ad Networks: Google AdMob may share data with its authorized advertising partners for ad personalization. These partners are bound by Google's policies.

• We do NOT share your journal entries, mood data, or any personal content you create with any third party.

• We do NOT use servers or cloud storage — all your personal content stays on your device.''',
          ),
          _buildSection(
            icon: Icons.storage,
            title: '5. Data Storage & Security',
            content: '''• All personal data (journals, moods, CBT entries) is stored locally on your device using Hive database.
• We do NOT transmit your personal content to any server or cloud service.
• Data is stored in your device's app sandbox, which is protected by the Android operating system.
• You can delete all your data at any time from Settings > Delete All Data.
• When you uninstall the App, all locally stored data is automatically deleted.''',
          ),
          _buildSection(
            icon: Icons.public,
            title: '6. Google AdMob & Third-Party Services',
            content: '''This App uses Google AdMob, a service provided by Google LLC. Google AdMob uses cookies and similar technologies to:

• Serve personalized advertisements
• Measure ad performance and analytics
• Prevent ad fraud

Google's use of advertising ID is governed by the Google Privacy Policy:
https://policies.google.com/privacy

Google AdMob's specific policies:
https://support.google.com/admob/answer/6128543

You can opt out of personalized advertising by:
• Going to your device Settings > Google > Ads > Delete advertising ID
• Or Settings > Privacy > Ads > Opt out of Ads Personalization''',
          ),
          _buildSection(
            icon: Icons.location_on,
            title: '7. Your Rights Under GDPR (EU/EEA Users)',
            content: '''If you are located in the European Economic Area (EEA), United Kingdom, or Switzerland, you have the following rights under the General Data Protection Regulation (GDPR):

• Right to Access: You can request a copy of the data we hold about you.
• Right to Rectification: You can request correction of inaccurate data.
• Right to Erasure ("Right to Be Forgotten"): You can request deletion of your data.
• Right to Restrict Processing: You can request limitation of data processing.
• Right to Data Portability: You can request your data in a portable format.
• Right to Object: You can object to processing based on legitimate interests.
• Right to Withdraw Consent: You can withdraw consent for data processing at any time.

Since all your personal content is stored locally on your device and we do not have access to it, exercising these rights primarily involves:

1. Deleting your data via Settings > Delete All Data in the App
2. Uninstalling the App to remove all local data
3. Opting out of personalized ads via your device settings or the consent dialog shown when you first open the App

For GDPR-related inquiries, contact us at: projectlabs26@gmail.com''',
          ),
          _buildSection(
            icon: Icons.gavel,
            title: '8. Your Rights Under CCPA (California Users)',
            content: '''If you are a California resident, the California Consumer Privacy Act (CCPA) provides you with the following rights:

• Right to Know: You have the right to know what personal information is collected, used, shared, or sold.
• Right to Delete: You have the right to request deletion of personal information.
• Right to Opt-Out of Sale: You have the right to opt out of the "sale" of personal information.
• Right to Non-Discrimination: You will not be discriminated against for exercising your CCPA rights.

Under CCPA, the sharing of Advertising ID and device information with Google for ad personalization may be considered a "sale" or "sharing" of personal information.

TO OPT OUT OF THE SALE/SHARING OF YOUR PERSONAL INFORMATION:
• Toggle OFF the "Personalized Ads" option in Settings > Privacy
• Or use the "Do Not Sell My Personal Information" link in Settings

When you opt out, we will request that Google AdMob serves only non-personalized ads (contextual ads based on the app content, not your personal data).''',
          ),
          _buildSection(
            icon: Icons.child_care,
            title: '9. Children\'s Privacy (COPPA)',
            content: '''HealMind is not directed at children under the age of 13 (or the applicable age of consent in your jurisdiction). We do not knowingly collect personal information from children.

If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately. We will take steps to delete such information.

Google AdMob does not serve personalized ads to users under 13 in accordance with the Children\'s Online Privacy Protection Act (COPPA).''',
          ),
          _buildSection(
            icon: Icons.update,
            title: '10. Changes to This Privacy Policy',
            content: '''We may update this Privacy Policy from time to time. We will notify you of any changes by:

• Posting the new Privacy Policy within the App
• Updating the "Last Updated" date at the top of this policy

We encourage you to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.''',
          ),
          _buildSection(
            icon: Icons.mail,
            title: '11. Contact Us',
            content: '''If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:

Email: projectlabs26@gmail.com
Developer: ProjectLabs

We will respond to your inquiry within 30 days.''',
          ),
          const SizedBox(height: 24),
          _buildLastUpdated(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'HealMind Privacy Policy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy matters to us',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    String? content,
    List<Widget>? subsections,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: Colors.grey.shade700,
              ),
            ),
          if (subsections != null) ...subsections,
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Last Updated: August 19, 2026',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
