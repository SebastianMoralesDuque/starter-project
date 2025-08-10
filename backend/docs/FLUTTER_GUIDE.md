# Guía Rápida: Conectar un Frontend de Flutter a este Backend

Esta guía te mostrará los pasos básicos para conectar una aplicación de Flutter a tu backend de Firebase para crear y leer artículos.

## 1. Configura Firebase en tu Proyecto de Flutter

Si aún no lo has hecho, necesitas añadir Firebase a tu proyecto de Flutter.

-   **Usa el FlutterFire CLI**: La forma más fácil es usar `flutterfire_cli`. Si no lo tienes, instálalo:
    ```bash
    dart pub global activate flutterfire_cli
    ```
-   **Configura tu app**: Desde la raíz de tu proyecto de Flutter, ejecuta:
    ```bash
    flutterfire configure
    ```
    Selecciona tu proyecto de Firebase (el que tiene el ID `<TU_PROJECT_ID>`) y las plataformas que necesites (iOS, Android, web). Esto generará automáticamente el archivo `firebase_options.dart`.

## 2. Añade las Dependencias Necesarias

Añade los siguientes paquetes a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.0.0 # O la última versión
  cloud_firestore: ^4.0.0 # O la última versión
  firebase_auth: ^4.0.0 # O la última versión
```

Luego, ejecuta `flutter pub get` en tu terminal.

## 3. Inicializa Firebase en tu App

En tu archivo `lib/main.dart`, asegúrate de inicializar Firebase antes de correr la aplicación:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa el archivo generado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## 4. Autenticación de Usuarios

Para que las reglas de seguridad funcionen, los usuarios deben estar autenticados. Aquí tienes un ejemplo simple de cómo registrar un usuario y cómo iniciar sesión:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// Registrar un nuevo usuario
Future<UserCredential?> registerUser(String email, String password) async {
  try {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    // Maneja errores (e.g., email ya en uso)
    print(e.message);
    return null;
  }
}

// Iniciar sesión
Future<UserCredential?> signIn(String email, String password) async {
  try {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    // Maneja errores (e.g., contraseña incorrecta)
    print(e.message);
    return null;
  }
}
```

## 5. Crear un Nuevo Artículo

Para crear un nuevo artículo, necesitas obtener el UID del usuario autenticado y luego hacer una llamada a Firestore.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> createArticle({
  required String titulo,
  required String contenido,
  required List<String> tags,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("Error: El usuario no está autenticado.");
    return;
  }

  final articlesCollection = FirebaseFirestore.instance.collection('articles');

  try {
    await articlesCollection.add({
      'titulo': titulo,
      'contenido': contenido,
      'fechaDePublicacion': FieldValue.serverTimestamp(), // Usa el timestamp del servidor
      'autorId': user.uid, // El UID del usuario actual
      'tags': tags,
    });
    print("Artículo creado con éxito.");
  } catch (e) {
    print("Error al crear el artículo: $e");
  }
}
```

## 6. Leer Artículos

Para leer los artículos, puedes usar un `StreamBuilder` para obtener actualizaciones en tiempo real.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArticlesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('articles').orderBy('fechaDePublicacion', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No hay artículos.'));
        }

        final articles = snapshot.data!.docs;

        return ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return ListTile(
              title: Text(article['titulo']),
              subtitle: Text(article['contenido']),
            );
          },
        );
      },
    );
  }
}