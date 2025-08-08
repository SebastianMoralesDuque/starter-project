const admin = require('firebase-admin');
const serviceAccount = require('./starterbackend22-firebase-adminsdk.json'); // <-- RUTA ACTUALIZADA

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const articlesData = require('./firestore_data/articles.json').articles;

async function insertArticles() {
  for (const articleId in articlesData) {
    if (articlesData.hasOwnProperty(articleId)) {
      const article = articlesData[articleId];
      // Convertir publishedAt a un objeto Timestamp de Firestore
      article.publishedAt = admin.firestore.Timestamp.fromDate(new Date(article.publishedAt));
      try {
        await db.collection('articles').doc(articleId).set(article);
        console.log(`Artículo "${article.title}" insertado con ID: ${articleId}`);
      } catch (error) {
        console.error(`Error al insertar el artículo "${article.title}":`, error);
      }
    }
  }
  console.log('Proceso de inserción de artículos completado.');
}

insertArticles();