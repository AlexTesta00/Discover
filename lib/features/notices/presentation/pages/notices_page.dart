import 'dart:io';

import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/notices/domain/use_cases/notice_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key});

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {

  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _categories = ['Avviso', 'Pericolo', 'Altro'];
  String _selectedCategory = 'Avviso';
  File? _image;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.gallery);
    if(imagePicked != null){
      setState(() {
        _image = File(imagePicked.path);
      });
    }
  }

  void sendNotice() async {
    final description = _descriptionController.text;
    if(description.isNotEmpty){
      final result = await submitNotice(_selectedCategory, description, _image);

      result.match(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore: $failure'))),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Segnalazione inviata con successo!')));
            _resetForm();
        }
      ); 
    }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: Descrizione mancante')));
    }
  }

  void _resetForm(){
    setState(() {
      _descriptionController.clear();
      _selectedCategory = 'Avviso';
      _image = null;
    });
  }

  Widget _buildCategoriaButton(String categoria) {
    final bool isSelected = _selectedCategory == categoria;
    return ChoiceChip(
      label: Text(
        categoria,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : AppTheme.primaryColor,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCategory = categoria);
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryColor), // bordo colorato :contentReference[oaicite:5]{index=5}
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: _categories.map(_buildCategoriaButton).toList(),
              ),
              SizedBox(height: 32),
              Text('Descrizione', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Descrivi brevemente il problema...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              Text('Foto (opzionale)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge, // ✅ taglia immagine dentro i bordi
                  child: _image == null
                      ? Center(child: Text('Seleziona l\'immagine dalla galleria'))
                      : Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: 180),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: sendNotice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Invia Segnalazione'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}