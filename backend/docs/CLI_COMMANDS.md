# Comandos de Firebase CLI

Aquí tienes los comandos que necesitas para gestionar tu proyecto de Firebase desde la terminal.

### 1. Instalar Firebase CLI

Si no tienes las herramientas de línea de comandos de Firebase, instálalas globalmente usando npm (Node.js es un requisito previo).

```bash
npm install -g firebase-tools
```

### 2. Iniciar Sesión en Firebase

Para conectar la CLI con tu cuenta de Firebase, ejecuta este comando. Se abrirá una ventana en tu navegador para que inicies sesión.

```bash
firebase login
```

### 3. Ejecutar el Emulador Local

Para probar tu backend (Firestore, Storage, etc.) en tu máquina local sin afectar los datos en producción, usa el emulador.

Desde la raíz de este proyecto, ejecuta:

```bash
firebase emulators:start
```

Esto iniciará los emuladores de Firestore y Storage en los puertos definidos en `firebase.json` (por defecto, `8080` para Firestore y `9199` para Storage) y te dará acceso a una interfaz de usuario para ver los datos.

### 4. Desplegar los Cambios

Cuando hayas terminado de desarrollar y probar tus reglas y quieras aplicarlas a tu proyecto de Firebase en la nube, ejecuta el siguiente comando.

**¡Atención!** Este comando sobrescribirá las reglas existentes en tu proyecto en la nube con las que tienes en tus archivos locales (`firestore.rules`, `storage.rules`).

```bash
firebase deploy
```

Si solo quieres desplegar una parte específica (por ejemplo, solo las reglas de Firestore), puedes hacerlo así:

```bash
firebase deploy --only firestore
```

O solo las de Storage:

```bash
firebase deploy --only storage