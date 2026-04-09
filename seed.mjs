import { Pinecone } from '@pinecone-database/pinecone';
import OpenAI from 'openai';
import dotenv from 'dotenv';

// Cargamos las variables del .env.local
dotenv.config({ path: '.env.local' });

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const pc = new Pinecone({ apiKey: process.env.PINECONE_API_KEY });
const index = pc.index('demo-rag-richard'); 

async function seedData() {
    console.log("Iniciando inyección masiva de datos...");

    // 1. Armamos un Array con nuestros diferentes documentos
    const documentos = [
        {
            id: 'reglamento-thanos-v1',
            texto: "Políticas de Thanos Corp para el área de Automatización: El horario de oficina es de 9:00 a 18:00. El código de vestimenta es 'business casual'. Para solicitar días por estudio, el empleado debe avisar a RRHH con 48 horas de anticipación enviando un correo a licencias@thanoscorp.com. Las herramientas oficiales de desarrollo incluyen Next.js y NestJS."
        },
        {
            id: 'info-perros-v1',
            texto: "El perro doméstico es un mamífero carnívoro de la familia de los cánidos. Poseen un oído y olfato muy desarrollados, y son conocidos por su lealtad hacia los humanos."
        },
        {
            id: 'info-caninos-v1',
            texto: "Los caninos (Canidae) son una familia de mamíferos del orden Carnivora. Abarca a lobos, zorros, coyotes y chacales. Se caracterizan por su hocico alargado y cuerpo adaptado para la persecución."
        },
        {
            id: 'tech-ganaderia-v1',
            texto: "El sistema Mission Control permite gestionar los datos de los sensores IoT del ganado. La arquitectura se basa en microservicios para procesar métricas de salud animal en tiempo real."
        }
    ];

    // Extraemos solo los textos para enviarlos a OpenAI
    const soloTextos = documentos.map(doc => doc.texto);

    console.log("2. Generando Vectores en OpenAI (Batch)...");
    // OpenAI acepta un array de strings en el 'input' y devuelve un array de embeddings
    const response = await openai.embeddings.create({
        model: "text-embedding-3-small",
        input: soloTextos,
    });

    console.log("3. Preparando los datos para Pinecone...");
    // Mapeamos las respuestas de OpenAI para unirlas con nuestros IDs y Metadata originales
    const recordsParaPinecone = documentos.map((doc, i) => {
        return {
            id: doc.id,
            values: response.data[i].embedding,
            metadata: { texto: doc.texto } 
        };
    });

    console.log("4. Guardando todos los registros en Pinecone...");
    await index.upsert({
        records: recordsParaPinecone
    });

    console.log("✅ ¡Éxito! Los documentos ya viven en el espacio multidimensional.");
}

seedData();