import { NextResponse } from 'next/server';
import { Pinecone } from '@pinecone-database/pinecone';
import OpenAI from 'openai';

// Inicializamos los clientes con las keys de tu .env.local
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const pc = new Pinecone({ apiKey: process.env.PINECONE_API_KEY });
const index = pc.index('demo-rag-richard');

export async function POST(req: Request) {
    try {
        const { message } = await req.json();

        // PASO 1: Vectorizar la pregunta del usuario en tiempo real
        const embeddingRes = await openai.embeddings.create({
            model: "text-embedding-3-small",
            input: message,
        });
        const vectorPregunta = embeddingRes.data[0].embedding;

        // PASO 2: Buscar en Pinecone el fragmento más similar a la pregunta
        const resultadosBusqueda = await index.query({
            vector: vectorPregunta,
            topK: 3,
            includeMetadata: true
        });

        // Extraemos el texto que guardamos previamente con seed.mjs
        let contexto = "No se encontró información relevante en la base de datos.";

        if (resultadosBusqueda.matches.length > 0) {
            // Mapeamos para sacar solo los textos y luego los unimos con un salto de línea
            contexto = resultadosBusqueda.matches
                .map(match => (match.metadata as any).texto)
                .join("\n\n---\n\n"); // Separa cada documento con una línea para que GPT los lea ordenados
        }   
        //PASO 3: Agente RAG - Le pasamos a GPT el contexto y la pregunta
        const completion = await openai.chat.completions.create({
            model: "gpt-4o", // se puede usar gpt-3.5-turbo si querés que sea más rápido/barato
            messages: [
                {
                    role: "system",
                    content: `Sos un asistente virtual inteligente. Respondé la pregunta del usuario basándote ÚNICAMENTE en la siguiente información de contexto proporcionada. Si la respuesta no se encuentra en el contexto, indicá amablemente que no tenés esa información.\n\nCONTEXTO:\n${contexto}`
                },
                {   role: "user", 
                    content: message 
                }
            ]
        });

          // Devolvemos la respuesta al Front-end
        return NextResponse.json({ respuesta: completion.choices[0].message.content });

        // const responseLocal = await fetch('http://localhost:11434/api/generate', {
        //     method: 'POST',
        //     body: JSON.stringify({
        //     model: 'qwen2.5:7b',
        //         prompt: `Contexto: ${contexto}. Pregunta: ${message}`,
        //         stream: false
        //     })
        // });

        // const dataOllama = await responseLocal.json();
        // return NextResponse.json({ respuesta: dataOllama.response });


    } catch (error) {
        console.error("Error en el endpoint de RAG:", error);
        return NextResponse.json({ error: "Hubo un error procesando la consulta" }, { status: 500 });
    }
}

/*
// ==========================================
// ¿CÓMO SERÍA ESTO A NIVEL LOCAL CON OLLAMA?
// ==========================================
  //  const responseLocal = await fetch('http://localhost:11434/api/generate', {
        //     method: 'POST',
        //     body: JSON.stringify({
        //     model: 'qwen2.5:7b',
        //         prompt: `Contexto: ${contexto}. Pregunta: ${message}`,
        //         stream: false
        //     })
        // });


// Ollama no usa 'choices', devuelve la respuesta directa:
const dataOllama = await responseLocal.json();
return NextResponse.json({ respuesta: dataOllama.response });
*/