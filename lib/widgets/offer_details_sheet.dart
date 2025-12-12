import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/offer.dart';

/// Bottom sheet modal for displaying offer details.
class OfferDetailsSheet extends StatelessWidget {
  final Offer offer;
  final VoidCallback onGetDirections;

  const OfferDetailsSheet({
    super.key,
    required this.offer,
    required this.onGetDirections,
  });

  /// Shows the offer details bottom sheet.
  static void show(
    BuildContext context, {
    required Offer offer,
    required VoidCallback onGetDirections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          OfferDetailsSheet(offer: offer, onGetDirections: onGetDirections),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHandle(),
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildDiscountBadge(),
                  const SizedBox(height: 16),
                  _buildOfferTitle(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildGetDirectionsButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.network(
                offer.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      offer.brandName[0],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.brandName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                offer.category,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepOrange, Colors.orange],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        offer.discountText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildOfferTitle() {
    return Text(
      offer.offerTitle,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDescription() {
    return Text(
      offer.offerDescription,
      style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
    );
  }

  Widget _buildInfoSection() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: offer.address,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Valid Until',
            value: dateFormat.format(offer.validUntil),
            valueColor: offer.isValid ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGetDirectionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onGetDirections,
        icon: const Icon(Icons.directions, color: Colors.white),
        label: const Text(
          'Get Directions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
