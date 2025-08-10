# Esquema de la Base de Datos Firestore

## Colección: `articles`

Esta colección almacena los artículos de la aplicación. Cada documento en esta colección representa un artículo individual.

### Campos del Documento de Artículo

*   **`author`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: Sí
    *   **Descripción**: El nombre del autor o la fuente del artículo.

*   **`content`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: Sí
    *   **Descripción**: El contenido completo del artículo.

*   **`description`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: Sí
    *   **Descripción**: Un breve resumen o introducción al artículo.

*   **`publishedAt`**:
    *   **Tipo**: `Timestamp`
    *   **Obligatorio**: Sí
    *   **Descripción**: La fecha y hora de publicación del artículo.

*   **`title`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: Sí
    *   **Descripción**: El título del artículo.

*   **`url`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: No (puede ser nulo)
    *   **Descripción**: El enlace URL a la fuente original del artículo, si está disponible.

*   **`urlToImage`**:
    *   **Tipo**: `String`
    *   **Obligatorio**: Sí
    *   **Descripción**: La URL de la imagen de portada del artículo, que apunta a un archivo en Firebase Storage.

### Ejemplo en formato JSON

```json
{
  "author": "SMAO",
  "content": "Contenido completo del artículo sobre criptomonedas y su impacto en el mercado actual.",
  "description": "Un análisis profundo sobre el estado actual de las criptomonedas.",
  "publishedAt": "2025-08-01T17:38:09.000Z",
  "title": "Crypto Bro: El Futuro de las Finanzas",
  "url": null,
  "urlToImage": "https://firebasestorage.googleapis.com/v0/b/starterbackend22.firebasestorage.app/o/article_images%2F1754761082459?alt=media&token=35fc4d85-e99c-4882-a016-645cb1d4eec2"
}
```

### Justificación de la Estructura

La estructura de datos para los artículos se ha diseñado para ser plana y eficiente, alineándose con las mejores prácticas de Firestore. Los campos seleccionados son los esenciales para mostrar vistas previas y el contenido completo de los artículos en la aplicación. El uso de `urlToImage` permite una carga eficiente de imágenes desde Firebase Storage, y el `Timestamp` para `publishedAt` facilita la ordenación cronológica de los artículos.

---

## Colección: `users`

Esta colección almacena la información de los usuarios registrados en la aplicación.

### Subcolección: `bookmarks`

Dentro de cada documento de usuario, existe una subcolección `bookmarks` que contiene los artículos que el usuario ha guardado.

*   **ID del Documento**: El ID del documento en la subcolección `bookmarks` es el mismo que el ID del artículo en la colección `articles`. Esto evita la duplicación de datos y simplifica la lógica para añadir o eliminar favoritos.

### Ejemplo de Estructura

```
users/{userId}/bookmarks/{articleId}
```

### Campos del Documento de Bookmark

*   **`savedAt`**:
    *   **Tipo**: `Timestamp`
    *   **Obligatorio**: Sí
    *   **Descripción**: La fecha y hora en que el usuario guardó el artículo como favorito.

### Justificación de la Estructura

Utilizar una subcolección para los `bookmarks` es una forma escalable de gestionar los favoritos de cada usuario. Al usar el ID del artículo como ID del documento del favorito, podemos comprobar de forma muy eficiente si un artículo ya ha sido guardado y evitar duplicados. Este enfoque también permite consultas rápidas para obtener todos los artículos guardados por un usuario.

---

# Reglas de Seguridad de Firebase

## Reglas de Firestore (`firestore.rules`)

Las reglas de seguridad de Firestore controlan el acceso a los datos almacenados en la base de datos.

*   **`/articles/{articleId}`**:
    *   `allow read: if true;`: Permite que **cualquier usuario** (autenticado o no) lea los artículos. Esto es ideal para contenido público como noticias o blogs.
    *   `allow create, update, delete: if request.auth != null;`: Solo permite que los **usuarios autenticados** creen, actualicen o eliminen artículos. Esto asegura que solo los usuarios registrados puedan modificar el contenido de los artículos.

*   **`/users/{userId}`**:
    *   `allow read, write: if request.auth != null && request.auth.uid == userId;`: Esta regla es crucial. Permite que un usuario **solo lea y escriba en su propio documento de usuario**. Esto es fundamental para la privacidad y seguridad de los datos del usuario, y también permite la creación de subcolecciones como `bookmarks` bajo el documento del usuario.

*   **`/users/{userId}/bookmarks/{bookmarkId}`**:
    *   `allow read, create, delete: if request.auth != null && request.auth.uid == userId;`: Permite que un usuario **solo lea, cree o elimine sus propios marcadores (favoritos)**. Esto asegura que los usuarios no puedan acceder o modificar los marcadores de otros usuarios, manteniendo la privacidad de sus colecciones personales.

## Reglas de Firebase Storage (`storage.rules`)

Las reglas de seguridad de Firebase Storage controlan el acceso a los archivos almacenados en los buckets de Storage.

*   **`/userFiles/{userId}/{allFiles=**}`:
    *   `allow read: if request.auth != null && request.auth.uid == userId;`: Permite que un usuario **solo lea sus propios archivos** dentro de la carpeta `userFiles/{userId}/`.
    *   `allow write: if request.auth != null && request.auth.uid == userId;`: Permite que un usuario **solo escriba (suba, actualice, elimine) sus propios archivos** dentro de la carpeta `userFiles/{userId}/`.
    *   Estas reglas aseguran que los archivos personales de cada usuario estén protegidos y solo sean accesibles por su propietario.

*   **`/article_images/{fileName}`**:
    *   `allow write: if request.auth != null;`: Permite que **cualquier usuario autenticado** suba imágenes a la carpeta `article_images/`. Esto es útil si los usuarios pueden contribuir con imágenes para los artículos.
    *   `allow read: if true;`: Permite que **cualquier usuario** (autenticado o no) lea las imágenes de los artículos. Esto es necesario para que las imágenes de los artículos sean visibles públicamente en la aplicación.

*   **`/{allPaths=**}`:
    *   `allow read, write: if false;`: Esta es una regla de denegación por defecto. **Deniega explícitamente el acceso de lectura y escritura a cualquier otra ruta** que no esté cubierta por las reglas anteriores. Esto es una buena práctica de seguridad para evitar accesos no autorizados a partes no definidas del Storage.
