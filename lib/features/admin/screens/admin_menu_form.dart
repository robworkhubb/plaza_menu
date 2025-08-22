import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:plaza_menu/core/models/menu_item.dart';
import 'package:uuid/uuid.dart';
import 'package:plaza_menu/core/providers/core_providers.dart';

class AdminMenuForm extends ConsumerStatefulWidget {
  final MenuItem? menuItem;
  const AdminMenuForm({super.key, this.menuItem});

  @override
  ConsumerState<AdminMenuForm> createState() => _AdminMenuFormState();
}

class _AdminMenuFormState extends ConsumerState<AdminMenuForm> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  Uint8List? pickedBytes;
  String? pickedFilename;
  bool loading = false;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    final m = widget.menuItem;
    if (m != null) {
      nameCtrl.text = m.name;
      descCtrl.text = m.description;
      priceCtrl.text = m.price.toString();
      categoryCtrl.text = m.categoryId;
      imageUrlCtrl.text = m.imageUrl;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    categoryCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (res == null) return;
    setState(() {
      pickedBytes = res.files.first.bytes;
      pickedFilename = res.files.first.name;
      imageUrlCtrl.text = '';
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    try {
      final repo = ref.read(menuRepositoryProvider);
      final storage = ref.read(storageServiceProvider);

      String imageUrl = imageUrlCtrl.text.trim();
      String? imagePath = widget.menuItem?.imagePath;

      if (pickedBytes != null && pickedFilename != null) {
        final path = 'menu_images/${const Uuid().v4()}_$pickedFilename';
        final result = await storage.uploadMenuImage(
          pickedBytes!,
          path,
          onProgress: (p) {
            setState(() => progress = p);
          },
        );
        imageUrl = result['url']!;
        imagePath = path;
      }

      final id = widget.menuItem?.id ?? const Uuid().v4();
      final item = MenuItem(
        id: id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text.trim()) ?? 0.0,
        categoryId: categoryCtrl.text.trim().isEmpty
            ? 'default'
            : categoryCtrl.text.trim(),
        imageUrl: imageUrl,
        imagePath: imagePath,
        available: widget.menuItem?.available ?? true,
      );

      if (widget.menuItem == null) {
        await repo.addMenuItem(item);
      } else {
        await repo.updateMenuItem(item);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Errore: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          progress = 0;
          pickedBytes = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.menuItem == null ? 'Aggiungi prodotto' : 'Modifica prodotto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Obbligatorio' : null,
              ),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrizione'),
              ),
              TextFormField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: 'Prezzo'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextFormField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Carica immagine'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: imageUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Oppure incolla URL immagine',
                      ),
                    ),
                  ),
                ],
              ),
              if (pickedBytes != null)
                SizedBox(
                  height: 120,
                  child: Image.memory(pickedBytes!, fit: BoxFit.contain),
                ),
              if (imageUrlCtrl.text.isNotEmpty && pickedBytes == null)
                SizedBox(
                  height: 120,
                  child: Image.network(imageUrlCtrl.text, fit: BoxFit.cover),
                ),
              if (progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(value: progress),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: loading ? null : _save,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }
}
