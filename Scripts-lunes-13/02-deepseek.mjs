import 'dotenv/config';
import OpenAI from 'openai'; // Usamos la librería gratis como "traductor"


const clienteIA = new OpenAI({ 
    baseURL: 'https://api.deepseek.com', // La URL de la fábrica
    apiKey: process.env.DEEPSEEK_API_KEY // La llave de la fábrica
});

//openai/gpt-4o  -- deepseek-chat
const nombreModelo = "deepseek-chat";

console.log(`📡 Conectando DIRECTAMENTE a los servidores de ${nombreModelo}...\n`);

const respuesta = await clienteIA.chat.completions.create({
  model: nombreModelo,
  messages: [{ role: "user", content: "¿Cuál es el mejor lenguaje para Backend en 2026?" }]
});

console.log("🤖 Respuesta:");
console.log(respuesta.choices[0].message.content);


