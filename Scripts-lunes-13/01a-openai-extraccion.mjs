import 'dotenv/config';
import OpenAI from 'openai'; 

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

const textoDesordenado = `
Ayer revisamos las vacas. La caravana 452 tiene 400kg, le dimos la vacuna aftosa. 
La 881 pesa 420kg, todo bien. Ah, y la 112 está rengueando, pesa 390kg.
`;

console.log("Procesando texto libre a JSON con OpenAI...\n");

const respuesta = await openai.chat.completions.create({
  model: "gpt-4o-mini",
  temperature: 0.0, 
  response_format: { type: "json_object" }, 
  messages: [
    {
      role: "system",
      content: `Actúa como un procesador de datos backend. 
      Extrae la información del texto y devuélvela ÚNICAMENTE como un objeto JSON válido con una clave "vacas" que contenga un array.
      Claves requeridas por cada vaca: "caravana" (número), "peso_kg" (número), "estado" (texto), "vacunada" (booleano).`
    },
    { role: "user", content: textoDesordenado }
  ]
});

console.log("📦 JSON Estructurado listo para el Front-End:");
console.log(respuesta.choices[0].message.content);
