import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart'; // Importar ArticleModel
import 'package:image_picker/image_picker.dart'; // Importar image_picker
import 'package:firebase_storage/firebase_storage.dart'; // Importar firebase_storage
import 'dart:io'; // Importar File
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';


class AddArticlePage extends StatefulWidget {
  const AddArticlePage({Key? key}) : super(key: key);

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _errorMessage;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = _storage.ref().child('article_images/$fileName.jpg');
      final UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Error al subir la imagen: ${e.message}';
      });
      return null;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado al subir la imagen: ${e.toString()}';
      });
      return null;
    }
  }

  Future<void> _addArticle() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Debes iniciar sesión para añadir un artículo.';
      });
      return;
    }

    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'El título y la descripción no pueden estar vacíos.';
      });
      return;
    }

    setState(() {
      _errorMessage = null; // Limpiar errores previos
    });

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImage();
      if (imageUrl == null) {
        return; // Si la subida de imagen falla, detener el proceso
      }
    }

    try {
      final newArticle = ArticleModel(
        author: user.displayName ?? 'Anónimo',
        title: _titleController.text,
        description: _descriptionController.text,
        url: '', // No es relevante para este ejemplo
        urlToImage: imageUrl,
        publishedAt: DateTime.now().toIso8601String(),
        content: _descriptionController.text,
      );

      await _firestore.collection('articles').add(newArticle.toJson()); // Usar toJson para guardar en Firestore
      
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null; // Limpiar la imagen seleccionada
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo añadido con éxito!')),
      );
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = 'Error de Firebase: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nueva Noticia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Artículo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Artículo',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Container(), // Mostrar un contenedor vacío si no hay imagen seleccionada
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar Imagen'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _addArticle();
                if (mounted) {
                  // Despachar el evento para recargar los artículos en el bloc principal
                  BlocProvider.of<RemoteArticlesBloc>(context).add(const GetArticles());
                  // Redirigir al usuario a la página principal
                  Navigator.pop(context);
                }
              },
              child: const Text('Añadir Noticia'),
            ),
          ],
        ),
      ),
    );
  }
}