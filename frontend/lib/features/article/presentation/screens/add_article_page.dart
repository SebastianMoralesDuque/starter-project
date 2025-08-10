import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/core/dependencies/injection_container.dart';
import 'package:news_app_clean_architecture/features/article/data/data_sources/remote/firestore_api_service.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_state.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _errorMessage;
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _addArticle() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null) {
      setState(() {
        _errorMessage =
            'El título, la descripción y la imagen no pueden estar vacíos.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final firestoreApiService = sl<FirestoreApiService>();
      final imageUrl = await firestoreApiService.uploadImage(_selectedImage!);
      final user = FirebaseAuth.instance.currentUser;

      final article = ArticleEntity(
        title: _titleController.text,
        description: _descriptionController.text,
        author: user?.displayName ?? 'Anónimo',
        urlToImage: imageUrl,
        publishedAt: DateTime.now(),
        content: _contentController.text,
      );

      if (mounted) {
        context.read<RemoteArticlesBloc>().add(SaveArticle(article));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al añadir artículo: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nueva Noticia'),
      ),
      body: BlocListener<RemoteArticlesBloc, RemoteArticlesState>(
        listener: (context, state) {
          if (state is RemoteArticleCreated) {
            _handleArticleAdded();
          } else if (state is RemoteArticlesError) {
            setState(() {
              _errorMessage = state.error;
            });
          }
        },
        child: SingleChildScrollView(
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
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenido (Soporta Markdown)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150)
                    : Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 40,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toca para seleccionar una imagen',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _addArticle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Añadir Noticia'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleArticleAdded() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo añadido con éxito!')),
      );
      context.read<RemoteArticlesBloc>().add(const GetArticles());
      Navigator.pop(context);
    }
  }
}