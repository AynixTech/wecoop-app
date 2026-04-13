import 'package:flutter/material.dart';

import '../services/app_localizations.dart';

class ProjectOpportunityCategory {
  final String key;
  final String title;
  final String summary;
  final IconData icon;
  final Color color;
  final List<ProjectOpportunityItem> items;

  const ProjectOpportunityCategory({
    required this.key,
    required this.title,
    required this.summary,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class ProjectOpportunityItem {
  final String title;
  final String description;
  final String ctaLabel;
  final String contentTypeLabel;
  final List<String> tags;
  final IconData icon;
  final String actionKey;
  final String? behaviorKey;

  const ProjectOpportunityItem({
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.contentTypeLabel,
    required this.tags,
    required this.icon,
    required this.actionKey,
    this.behaviorKey,
  });
}

List<ProjectOpportunityCategory> buildProjectOpportunityCatalog(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context)!;
  final scheme = Theme.of(context).colorScheme;

  final youngTag = l10n.translate('tagYoungPeople');
  final womenTag = l10n.translate('tagWomen');
  final migrantsTag = l10n.translate('tagMigrants');
  final familiesTag = l10n.translate('tagFamilies');
  final entrepreneursTag = l10n.translate('tagEntrepreneurs');
  final studentsTag = l10n.translate('tagStudents');
  final operationalLabel = l10n.translate('contentTypeOperational');
  final opportunityLabel = l10n.translate('contentTypeOpportunity');
  final educationalLabel = l10n.translate('contentTypeEducational');

  return [
    ProjectOpportunityCategory(
      key: 'formazione',
      title: l10n.translate('projectsCategoryTrainingTitle'),
      summary: l10n.translate('projectsCategoryTrainingSummary'),
      icon: Icons.school_rounded,
      color: Color.alphaBlend(
        scheme.primary.withOpacity(0.20),
        scheme.tertiary,
      ),
      items: [
        ProjectOpportunityItem(
          title: l10n.translate('opportunityDigitalMarketingTitle'),
          description: l10n.translate('opportunityDigitalMarketingDescription'),
          ctaLabel: l10n.translate('ctaParticipate'),
          contentTypeLabel: educationalLabel,
          tags: [youngTag, womenTag],
          icon: Icons.campaign_rounded,
          actionKey: 'training',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityItalianCourseTitle'),
          description: l10n.translate('opportunityItalianCourseDescription'),
          ctaLabel: l10n.translate('ctaParticipate'),
          contentTypeLabel: operationalLabel,
          tags: [migrantsTag, familiesTag],
          icon: Icons.translate_rounded,
          actionKey: 'inclusion',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityProfessionalTrainingTitle'),
          description: l10n.translate(
            'opportunityProfessionalTrainingDescription',
          ),
          ctaLabel: l10n.translate('ctaDiscoverPath'),
          contentTypeLabel: opportunityLabel,
          tags: [youngTag, migrantsTag],
          icon: Icons.workspace_premium_rounded,
          actionKey: 'training',
        ),
      ],
    ),
    ProjectOpportunityCategory(
      key: 'lavoro',
      title: l10n.translate('projectsCategoryWorkTitle'),
      summary: l10n.translate('projectsCategoryWorkSummary'),
      icon: Icons.work_rounded,
      color: Color.alphaBlend(
        scheme.primary.withOpacity(0.18),
        scheme.secondary,
      ),
      items: [
        ProjectOpportunityItem(
          title: l10n.translate('opportunityJobPlacementTitle'),
          description: l10n.translate('opportunityJobPlacementDescription'),
          ctaLabel: l10n.translate('ctaApply'),
          contentTypeLabel: opportunityLabel,
          tags: [youngTag, migrantsTag],
          icon: Icons.badge_rounded,
          actionKey: 'work',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityAgencyCollaborationTitle'),
          description: l10n.translate(
            'opportunityAgencyCollaborationDescription',
          ),
          ctaLabel: l10n.translate('ctaDiscoverOpportunity'),
          contentTypeLabel: operationalLabel,
          tags: [youngTag, womenTag],
          icon: Icons.handshake_rounded,
          actionKey: 'work',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityInternshipsTitle'),
          description: l10n.translate('opportunityInternshipsDescription'),
          ctaLabel: l10n.translate('ctaApply'),
          contentTypeLabel: opportunityLabel,
          tags: [youngTag, studentsTag],
          icon: Icons.trending_up_rounded,
          actionKey: 'work',
        ),
      ],
    ),
    ProjectOpportunityCategory(
      key: 'imprenditorialita',
      title: l10n.translate('projectsCategoryEntrepreneurshipTitle'),
      summary: l10n.translate('projectsCategoryEntrepreneurshipSummary'),
      icon: Icons.rocket_launch_rounded,
      color: Color.alphaBlend(
        scheme.tertiary.withOpacity(0.28),
        scheme.primary,
      ),
      items: [
        ProjectOpportunityItem(
          title: l10n.translate('opportunityMicrocreditTitle'),
          description: l10n.translate('opportunityMicrocreditDescription'),
          ctaLabel: l10n.translate('ctaCheckEligibility'),
          contentTypeLabel: opportunityLabel,
          tags: [womenTag, migrantsTag, entrepreneursTag],
          icon: Icons.account_balance_wallet_rounded,
          actionKey: 'credit',
          behaviorKey: 'open_credit_service',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityBusinessStartTitle'),
          description: l10n.translate('opportunityBusinessStartDescription'),
          ctaLabel: l10n.translate('ctaRequestAssistance'),
          contentTypeLabel: operationalLabel,
          tags: [entrepreneursTag, womenTag],
          icon: Icons.storefront_rounded,
          actionKey: 'credit',
          behaviorKey: 'open_accounting_service',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityMentorshipTitle'),
          description: l10n.translate('opportunityMentorshipDescription'),
          ctaLabel: l10n.translate('ctaRequestMentorship'),
          contentTypeLabel: educationalLabel,
          tags: [youngTag, womenTag, entrepreneursTag],
          icon: Icons.groups_rounded,
          actionKey: 'credit',
          behaviorKey: 'interest_only',
        ),
      ],
    ),
    ProjectOpportunityCategory(
      key: 'inclusione-sociale',
      title: l10n.translate('projectsCategoryInclusionTitle'),
      summary: l10n.translate('projectsCategoryInclusionSummary'),
      icon: Icons.diversity_3_rounded,
      color: Color.alphaBlend(scheme.secondary.withOpacity(0.24), scheme.error),
      items: [
        ProjectOpportunityItem(
          title: l10n.translate('opportunityWomenSupportTitle'),
          description: l10n.translate('opportunityWomenSupportDescription'),
          ctaLabel: l10n.translate('ctaRequestSupport'),
          contentTypeLabel: operationalLabel,
          tags: [womenTag],
          icon: Icons.favorite_rounded,
          actionKey: 'inclusion',
          behaviorKey: 'interest_only',
        ),
        ProjectOpportunityItem(
          title: l10n.translate('opportunityMigrantIntegrationTitle'),
          description: l10n.translate(
            'opportunityMigrantIntegrationDescription',
          ),
          ctaLabel: l10n.translate('ctaRequestAssistance'),
          contentTypeLabel: opportunityLabel,
          tags: [migrantsTag, familiesTag],
          icon: Icons.public_rounded,
          actionKey: 'inclusion',
          behaviorKey: 'open_welcome_service',
        ),
      ],
    ),
  ];
}
