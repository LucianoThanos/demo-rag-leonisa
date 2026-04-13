import 'dotenv/config';
import OpenAI from 'openai'; 

// Conectamos a OpenRouter (El intermediario universal)
const clienteIA = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1", // La URL del supermercado
  apiKey: process.env.OPENROUTER_API_KEY,  // la unica apikey que necesitamos
});


// Solo cambiando este texto, pasamos de usar un modelo de Meta a uno de Google o Mistral.
// usamos la variante ":free" para que no cueste un centavo.
const modeloElegido = "meta-llama/llama-3.3-70b-instruct:free";
//meta-llama/llama-3.3-70b-instruct:free
//nvidia/nemotron-3-super-120b-a12b:free

console.log(`🛒 Usando OpenRouter para pedirle respuestas a: ${modeloElegido}...\n`);

const respuesta = await clienteIA.chat.completions.create({
  model: modeloElegido,
  messages: [
    { role: "user", content: "Dime una ventaja de usar Docker." }
  ]
});

console.log("🤖 Respuesta:");
console.log(respuesta.choices[0].message.content);
