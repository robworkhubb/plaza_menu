import 'package:flutter/material.dart';
import '../../../core/models/menu_item.dart';

class ProductCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    // layout mobile-first, stile bianco minimal con bordo sottile
    const borderColor = Color(0xFFE5E7EB); // grigio chiaro
    const mintBg = Color(0xFFE8FBF0);
    const mintText = Color(0xFF16A34A);
    const roseBg = Color(0xFFFCE7F3);
    const roseText = Color(0xFFDB2777);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // testo a sinistra
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '€${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Opacity(
                      opacity: item.available ? 0.9 : 0.6,
                      child: Text(
                        item.description,
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // badge disponibilità
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: item.available ? mintBg : roseBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.available ? 'Available' : 'Sold Out',
                        style: TextStyle(
                          color: item.available ? mintText : roseText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              // immagine a destra
              Opacity(
                opacity: item.available ? 1 : 0.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(color: Colors.grey[200]);
                            },
                          )
                        : Container(color: Colors.grey[200]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
