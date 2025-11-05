import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../../widgets/listing_image_widget.dart';

class DynamicServiceCard extends StatefulWidget {
  final String leftText;
  final String imageUrl;
  final String? location;
  final String? type;
  final String? bedrooms;
  final String? bathrooms;
  final String? size;
  final String? condition;
  final String? buildingAge;
  final String? papers;
  final String? listingFor;
  final String? currency;
  final String? status;
  final String? price;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onSold;
  final VoidCallback? onBoost;

  const DynamicServiceCard({
    super.key,
    required this.leftText,
    required this.imageUrl,
    this.location,
    this.type,
    this.bedrooms,
    this.bathrooms,
    this.size,
    this.condition,
    this.buildingAge,
    this.papers,
    this.listingFor,
    this.currency,
    this.status,
    this.price,
    this.description,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onSold,
    this.onBoost,
  });

  @override
  State<DynamicServiceCard> createState() => _DynamicServiceCardState();
}

class _DynamicServiceCardState extends State<DynamicServiceCard> {
  bool boostPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
        child: Column(
        children: [
          // First row: left text only (removed views/saves)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.leftText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: image + button columns or Boost replacement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              ListingImageWidget(
                imageUrl: widget.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                placeholderIcon: Icons.home,
                placeholderIconSize: 30,
              ),
              const SizedBox(width: 12),

              // Middle & right columns or Cancel/Promote buttons
              Expanded(
                child: boostPressed
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: AppLocalizations.of(context)?.cancelButton ?? 'Cancel',
                                onTap: () {
                                  setState(() {
                                    boostPressed = false;
                                  });
                                },
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                useGradient: false,
                                backgroundColor: const Color(0xFFF9FBFF),
                                borderColor: const Color(0xFFEA4435),
                                borderWidth: 1.0,
                                textColor: const Color(0xFFEA4435),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: AppLocalizations.of(context)?.promoteButton ?? 'Promote',
                                onTap: () {},
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: AppLocalizations.of(context)?.soldButton ?? 'Sold',
                                    onTap: widget.onSold,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFF0048FF),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: AppLocalizations.of(context)?.deleteButton ?? 'Delete',
                                    onTap: widget.onDelete,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFFEA4435),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFFEA4435),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: AppLocalizations.of(context)?.boostButton ?? 'Boost',
                                    onTap: () {
                                      setState(() {
                                        boostPressed = true;
                                      });
                                      widget.onBoost?.call();
                                    },
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: AppLocalizations.of(context)?.editButton ?? 'Edit',
                                    onTap: widget.onEdit,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

// Wrapper widget to generate multiple cards
class DynamicServiceCardList extends StatelessWidget {
  final List<Map<String, String>> items;
  final Function(String)? onItemTap;
  final Function(String)? onDelete;
  final Function(String)? onEdit;
  final Function(String)? onSold;
  final Function(String)? onBoost;

  const DynamicServiceCardList({
    super.key, 
    required this.items,
    this.onItemTap,
    this.onDelete,
    this.onEdit,
    this.onSold,
    this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => DynamicServiceCard(
                leftText: item['leftText'] ?? '',
                imageUrl: item['imageUrl'] ?? '',
                location: item['location'],
                type: item['type'],
                bedrooms: item['bedrooms'],
                bathrooms: item['bathrooms'],
                size: item['size'],
                condition: item['condition'],
                buildingAge: item['buildingAge'],
                papers: item['papers'],
                listingFor: item['listingFor'],
                currency: item['currency'],
                status: item['status'],
                price: item['price'],
                description: item['description'],
                onTap: onItemTap != null ? () => onItemTap!(item['leftText'] ?? '') : null,
                onDelete: onDelete != null ? () => onDelete!(item['leftText'] ?? '') : null,
                onEdit: onEdit != null ? () => onEdit!(item['leftText'] ?? '') : null,
                onSold: onSold != null ? () => onSold!(item['leftText'] ?? '') : null,
                onBoost: onBoost != null ? () => onBoost!(item['leftText'] ?? '') : null,
              ))
          .toList(),
    );
  }
}
