import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/home_banner_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/row_of_subsc_widget.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/subscription_status_widget.dart';

class ServiceHomeContent extends StatelessWidget {
  const ServiceHomeContent({
    super.key,
    required this.serviceLabel,
    required this.priceLabel,
    required this.billingDate,
    required this.planType,
    required this.actionLabel,
    required this.nearbyTitle,
    required this.items,
  });

  final String serviceLabel;
  final String priceLabel;
  final String billingDate;
  final String planType;
  final String actionLabel;
  final String nearbyTitle;
  final List<ServiceHomeItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: HomeBanner(),
        ),
        _ServiceSubscriptionCard(
          serviceLabel: serviceLabel,
          priceLabel: priceLabel,
          billingDate: billingDate,
          planType: planType,
          actionLabel: actionLabel,
        ),
        sizedBoxHeight(height: 32),
        _ServiceNearbySection(
          title: nearbyTitle,
          items: items,
        ),
      ],
    );
  }
}

class _ServiceSubscriptionCard extends StatelessWidget {
  const _ServiceSubscriptionCard({
    required this.serviceLabel,
    required this.priceLabel,
    required this.billingDate,
    required this.planType,
    required this.actionLabel,
  });

  final String serviceLabel;
  final String priceLabel;
  final String billingDate;
  final String planType;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 32),
            blurRadius: 32,
            spreadRadius: 0,
            color: primaryText1.withValues(alpha: 0.06),
          )
        ],
        border: Border.all(
          width: 1,
          color: const Color(0x1AC3C6D1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceLabel,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText2,
                    ),
              ),
              const SubscriptionStatusWidget(isActive: true),
            ],
          ),
          sizedBoxHeight(height: 24),
          Text(
            priceLabel,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: primaryText1,
                ),
          ),
          sizedBoxHeight(height: 24),
          RowOfSubscWidget(
            title: "Next Billing",
            subTitle: billingDate,
          ),
          sizedBoxHeight(height: 28),
          RowOfSubscWidget(
            title: "Plan Type",
            subTitle: planType,
          ),
          sizedBoxHeight(height: 24),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 6,
                spreadRadius: -4,
                color: primaryText1.withValues(alpha: 0.20),
              ),
              BoxShadow(
                offset: const Offset(0, 10),
                blurRadius: 15,
                spreadRadius: -3,
                color: primaryText1.withValues(alpha: 0.20),
              )
            ]),
            child: CustomButton(
              onTap: () {},
              height: 68,
              radius: 999,
              color: primaryText1,
              borderColor: primaryText1,
              child: Text(
                actionLabel,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceNearbySection extends StatelessWidget {
  const _ServiceNearbySection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<ServiceHomeItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Helper(context).textTheme.bodyLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: blackText1,
              ),
        ),
        sizedBoxHeight(height: 24),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _ServiceListingCard(
              item: items[index],
            ),
            separatorBuilder: (_, __) => sizedBoxWidth(width: 20),
            itemCount: items.length,
          ),
        )
      ],
    );
  }
}

class _ServiceListingCard extends StatelessWidget {
  const _ServiceListingCard({required this.item});

  final ServiceHomeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 20),
            blurRadius: 24,
            color: black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: primaryText1),
          ),
          sizedBoxHeight(height: 20),
          Text(
            item.title,
            style: Helper(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 10),
          Text(
            item.subtitle,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: greyText2,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: greyLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.footer,
              style: Helper(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: primaryText1,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceHomeItem {
  const ServiceHomeItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.footer,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String footer;
}
