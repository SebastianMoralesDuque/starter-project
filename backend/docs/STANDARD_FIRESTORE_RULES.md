# Reglas de Seguridad Estándar para Firestore (Datos de Usuario)

Estas reglas son un patrón común para colecciones donde cada documento pertenece a un usuario específico y solo ese usuario debe tener acceso completo a sus propios datos.

## Escenario 1: Colección anidada bajo el UID del usuario

Si tu estructura de datos es, por ejemplo, `/users/{userId}/messages/{messageId}`, donde `userId` es el UID del usuario autenticado:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Colección de perfiles de usuario (ej: /users/{userId})
    match /users/{userId} {
      // Solo el usuario autenticado puede leer y escribir su propio perfil
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Subcolección de mensajes de usuario (ej: /users/{userId}/messages/{messageId})
    match /users/{userId}/messages/{messageId} {
      // Solo el usuario autenticado puede leer, crear, actualizar y borrar sus propios mensajes
      allow read, create, update, delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Explicación:**
*   `request.auth != null`: Asegura que solo los usuarios autenticados puedan realizar operaciones.
*   `request.auth.uid == userId`: Compara el UID del usuario autenticado con el `userId` en la ruta del documento, garantizando que solo el propietario pueda acceder a sus datos.

## Escenario 2: Colección plana con campo `autorId`

Si tu estructura de datos es una colección plana como `/messages/{messageId}`, y cada documento tiene un campo `autorId` que almacena el UID del usuario que lo creó:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Colección de mensajes (ej: /messages/{messageId})
    match /messages/{messageId} {
      // Permitir lectura si el usuario está autenticado y es el autor del mensaje
      allow read: if request.auth != null && resource.data.autorId == request.auth.uid;

      // Permitir creación si el usuario está autenticado y el autorId del nuevo documento coincide con su UID
      allow create: if request.auth != null && request.resource.data.autorId == request.auth.uid;

      // Permitir actualización y borrado solo si el usuario está autenticado y es el autor del mensaje
      allow update, delete: if request.auth != null && resource.data.autorId == request.auth.uid;

      // Opcional: Si quieres que todos los usuarios autenticados puedan leer todos los mensajes,
      // pero solo el autor pueda modificarlos, usarías:
      // allow read: if request.auth != null;
      // allow create: if request.auth != null && request.resource.data.autorId == request.auth.uid;
      // allow update, delete: if request.auth != null && resource.data.autorId == request.auth.uid;
    }
  }
}
```

**Explicación:**
*   `request.auth != null`: El usuario debe estar autenticado.
*   `resource.data.autorId == request.auth.uid`: Para operaciones de lectura, actualización y borrado, el UID del usuario autenticado debe coincidir con el `autorId` del documento *existente* (`resource.data`).
*   `request.resource.data.autorId == request.auth.uid`: Para operaciones de creación, el UID del usuario autenticado debe coincidir con el `autorId` que se está *intentando escribir* en el nuevo documento (`request.resource.data`). Esto evita que un usuario cree un documento y se atribuya a otro.

**Consideraciones Adicionales:**

*   **Validación de Datos**: Siempre es una buena práctica añadir validación de tipos y campos obligatorios en tus reglas de `create` y `update` para asegurar la integridad de tus datos.
*   **Índices**: Para consultas complejas (ej. `orderBy` en un campo y `where` en otro), necesitarás crear índices compuestos en la Firebase Console.
*   **Modo de Prueba vs. Producción**: Siempre desarrolla y prueba tus reglas en el emulador local antes de desplegarlas a producción.