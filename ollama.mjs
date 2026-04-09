import { Pinecone } from '@pinecone-database/pinecone';
import dotenv from 'dotenv';

// Cargamos las variables del .env.local (Solo necesitamos la de Pinecone ahora)
dotenv.config({ path: '.env.local' });

const pc = new Pinecone({ apiKey: process.env.PINECONE_API_KEY });

// Como cambiamos de modelo, cambiamos de Index.
const index = pc.index('demo-rag-ollama'); 

async function seedData() {
    console.log("Iniciando inyección de datos...");

    const textoReglamento = "Políticas de Thanos Corp para el área de Automatización: El horario de oficina es de 9:00 a 18:00. El código de vestimenta es 'business casual'. Para solicitar días por estudio, el empleado debe avisar a RRHH con 48 horas de anticipación enviando un correo a licencias@thanoscorp.com. Las herramientas oficiales de desarrollo incluyen Next.js y NestJS.";

    console.log("1. Generando Vector a nivel local con Ollama...");
    
    // Le pegamos a la API de embeddings de tu Ollama local
    const responseLocal = await fetch('http://localhost:11434/api/embeddings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: 'nomic-embed-text',
            prompt: textoReglamento
        })
    });

    const data = await responseLocal.json();
    const embedding = data.embedding;

    console.log("2. Guardando en Pinecone...");
    await index.upsert({
        records: [{
            id: 'reglamento-thanos-v1',
            values: embedding,
            metadata: { texto: textoReglamento } // Guardamos el texto
        }]
    });

    console.log("✅ ¡Éxito! El documento ya vive en el espacio multidimensional (Gratis y Privado).");
}

seedData();