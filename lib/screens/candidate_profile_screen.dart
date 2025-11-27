import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/candidate_model.dart';
import '../services/screenx_api_service.dart';
import '../providers/token_provider.dart';
import 'skills_verification_screen.dart';
import 'offer_history_screen.dart';
import 'write_review_screen.dart';

class CandidateProfileScreen extends StatefulWidget {
  final CandidateModel candidate;

  const CandidateProfileScreen({
    super.key,
    required this.candidate,
  });

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final ScreenXApiService _apiService = ScreenXApiService();
  bool _isCallingConsentApi = false;

  Future<void> _callConsentAcceptanceApi() async {
    setState(() {
      _isCallingConsentApi = true;
    });

    try {
      // Get token from provider
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final customToken = tokenProvider.accessToken;

      debugPrint('Calling Candidate Consent Acceptance API...');
      final response = await _apiService.candidateConsentAcceptance(
        customToken: customToken,
      );
      debugPrint('API call completed successfully');
      debugPrint('Response: $response');

      // Show a success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'API called successfully! Status: ${response['statusCode']}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('API call failed: $e');

      // Show an error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API call failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCallingConsentApi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back to Home',
        ),
        title: const Text('Candidate Profile'),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Avatar with gradient background
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.candidate.firstName[0]}${widget.candidate.lastName[0]}',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Name
                        Text(
                          '${widget.candidate.firstName} ${widget.candidate.lastName}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Job Title
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.candidate.jobTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quick Info Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickInfo(
                              context,
                              Icons.work_outline,
                              '${widget.candidate.experience} yrs',
                              'Experience',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: theme.colorScheme.onSurface.withOpacity(0.1),
                            ),
                            _buildQuickInfo(
                              context,
                              Icons.code,
                              '${widget.candidate.skills.length}',
                              'Skills',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Section Title
                Text(
                  'Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Skills Verification Card
                _buildActionCard(
                  context,
                  title: 'Skills Verification',
                  description: 'Verify your technical skills with AI assessment',
                  icon: Icons.verified_user,
                  gradientColors: [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFF8E53),
                  ],
                  buttonText: 'Start Verification',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SkillsVerificationScreen(
                          candidate: widget.candidate,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Offer History Card
                _buildActionCard(
                  context,
                  title: 'Offer History',
                  description: 'View all your job offers and their status',
                  icon: Icons.history,
                  gradientColors: [
                    const Color(0xFF4E65FF),
                    const Color(0xFF92EFFD),
                  ],
                  buttonText: 'View History',
                  onTap: () {
                    // Get token from provider
                    final tokenProvider =
                        Provider.of<TokenProvider>(context, listen: false);
                    final customToken = tokenProvider.accessToken;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OfferHistoryScreen(customToken: customToken),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Write Review Card
                _buildActionCard(
                  context,
                  title: 'Write a Review',
                  description: 'Share your experience and help others',
                  icon: Icons.rate_review,
                  gradientColors: [
                    const Color(0xFF9C27B0),
                    const Color(0xFFE91E63),
                  ],
                  buttonText: 'Write Review',
                  onTap: () {
                    // Get token from provider
                    final tokenProvider =
                        Provider.of<TokenProvider>(context, listen: false);
                    final customToken = tokenProvider.accessToken;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WriteReviewScreen(customToken: customToken),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Consent API Test Card
                _buildActionCard(
                  context,
                  title: 'Consent Acceptance',
                  description: 'Test the candidate consent acceptance API',
                  icon: Icons.api,
                  gradientColors: [
                    const Color(0xFF00C853),
                    const Color(0xFF64DD17),
                  ],
                  buttonText: _isCallingConsentApi
                      ? 'Calling API...'
                      : 'Call Consent API',
                  isLoading: _isCallingConsentApi,
                  onTap: _isCallingConsentApi ? null : _callConsentAcceptanceApi,
                ),
                const SizedBox(height: 32),

                // Candidate Details Section
                Text(
                  'Candidate Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Personal Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(
                          context,
                          'Candidate ID',
                          widget.candidate.candidateId,
                        ),
                        _buildDetailRow(
                          context,
                          'Email',
                          widget.candidate.email,
                        ),
                        _buildDetailRow(
                          context,
                          'Phone',
                          widget.candidate.phone,
                        ),
                        _buildDetailRow(
                          context,
                          'Date of Birth',
                          widget.candidate.dateOfBirth,
                        ),
                        _buildDetailRow(
                          context,
                          'Gender',
                          widget.candidate.gender == 0
                              ? 'Male'
                              : widget.candidate.gender == 1
                                  ? 'Female'
                                  : 'Other',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Skills Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.code,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Skills',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: widget.candidate.skills
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        theme.colorScheme.secondary
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        skill,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Subtle attribution
                Center(
                  child: InkWell(
                    onTap: () async {
                      try {
                        final uri = Uri.parse('https://github.com/rajdeep-das');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        debugPrint('Error launching URL: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open GitHub profile'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Opacity(
                        opacity: 0.4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.code,
                              size: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.4),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '© 2025 • RD',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                letterSpacing: 0.8,
                                color: theme.colorScheme.onSurface.withOpacity(0.45),
                                decoration: TextDecoration.underline,
                                decorationStyle: TextDecorationStyle.dotted,
                                decorationColor:
                                    theme.colorScheme.onSurface.withOpacity(0.25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradientColors,
    required String buttonText,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon with gradient background
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title and Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientColors[0],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonText,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            height: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
