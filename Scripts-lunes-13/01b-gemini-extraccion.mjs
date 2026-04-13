import 'dotenv/config';
import { GoogleGenerativeAI } from '@google/generative-ai';


const ai = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// 1. Definimos el texto desordenado (Tema: Paseo por Tandil)
const textoDesordenado = `
Ayer hicimos un recorrido hermoso por Tandil. Primero fuimos al Cerro El Centinela, 
había muchísima gente y nos subimos a la aerosilla. Después pasamos por el Parque Independencia; 
el castillo morisco estaba increíble, aunque nos llovió un poquito. Terminamos la tarde tomando mates 
en el Lago del Fuerte, por suerte ahí el clima ya estaba 10 puntos y re despejado.
`;

console.log("Procesando texto libre a JSON con Gemini...\n");

// 2. Configuramos el modelo (Acá Gemini agrupa la configuración y el System Prompt)
const modelo = ai.getGenerativeModel({ 
  model: "gemini-2.5-flash",
  
  // EL EQUIVALENTE A 'role: "system"' DE OPENAI
  systemInstruction: `Actúa como un procesador de datos turístico. 
  Extrae la información del texto y devuélvela ÚNICAMENTE como un objeto JSON válido con una clave "lugares" que contenga un array.
  Claves requeridas por cada lugar: "nombre" (texto), "clima_o_estado" (texto), "habia_mucha_gente" (booleano).`,
  
  generationConfig: { 
    temperature: 0.0, // Mantenemos la precisión absoluta
    
    // Obligamos a que la respuesta sea un JSON válido
    responseMimeType: "application/json" 
  } 
});

// 3. La llamada al modelo (A diferencia de OpenAI, solo le pasamos el texto del "user")
const respuesta = await modelo.generateContent(textoDesordenado);

console.log("📦 JSON Estructurado listo para el Front-End:");
console.log("--------------------------------------------------");
console.log(respuesta.response.text());
console.log("--------------------------------------------------");