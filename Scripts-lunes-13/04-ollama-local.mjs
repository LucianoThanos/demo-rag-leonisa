// No importamos nada. Usamos herramientas nativas.

// La URL por defecto donde corre Ollama en tu computadora
const OLLAMA_URL = "http://localhost:11434/api/generate";

const payload = {
  model: "qwen2.5-coder:7b", // el modelo que quieran probar
  prompt: "Escribe una función en JavaScript para invertir un string.",
  stream: false, // Pedimos que nos devuelva todo junto, no letra por letra
  options: {
    temperature: 0.1 // Seguimos controlando la temperatura por HTTP
  }
};

console.log("🔌 Haciendo petición HTTP local a Ollama (Sin Internet)...\n");

try {
  const respuesta = await fetch(OLLAMA_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  const datos = await respuesta.json();
  
  console.log("💻 Respuesta de mi computadora:");
  console.log("--------------------------------------------------");
  console.log(datos.response);
  console.log("--------------------------------------------------");

} catch (error) {
  console.error("❌ Error de conexión. ¿Te aseguraste de tener Ollama corriendo?");
}