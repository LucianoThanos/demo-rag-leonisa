'use client';

import { useState } from 'react';

export default function ChatRAG() {
    const [input, setInput] = useState('');
    const [mensajes, setMensajes] = useState<{rol: string, contenido: string}[]>([]);
    const [cargando, setCargando] = useState(false);

    const enviarMensaje = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!input.trim()) return;

        // Agregamos el mensaje del usuario a la pantalla
        const nuevoMensaje = { rol: 'usuario', contenido: input };
        setMensajes(prev => [...prev, nuevoMensaje]);
        setInput('');
        setCargando(true);

        try {
            // Le pegamos a nuestra API Route de RAG
            const res = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: nuevoMensaje.contenido })
            });
            
            const data = await res.json();

            // Mostramos la respuesta de la IA
            setMensajes(prev => [...prev, { rol: 'ia', contenido: data.respuesta }]);
        } catch (error) {
            setMensajes(prev => [...prev, { rol: 'ia', contenido: '❌ Error de conexión con el agente.' }]);
        } finally {
            setCargando(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-900 text-gray-100 flex flex-col items-center justify-center p-4 font-sans">
            <div className="w-full max-w-2xl bg-gray-800 rounded-xl shadow-2xl overflow-hidden flex flex-col h-[80vh]">
                
                {/* Header */}
                <div className="bg-gray-950 p-5 border-b border-gray-700">
                    <h1 className="text-xl font-bold text-emerald-400 flex items-center gap-2">
                        <span>🤖</span> Agente RAG Corporativo
                    </h1>
                    <p className="text-sm text-gray-400 mt-1">Haciendo consultas sobre documentos vectorizados</p>
                </div>

                {/* Historial de Chat */}
                <div className="flex-1 overflow-y-auto p-4 space-y-4">
                    {mensajes.length === 0 ? (
                        <div className="text-center text-gray-500 mt-20 flex flex-col items-center">
                            <span className="text-4xl mb-4">📚</span>
                            <p>La base de datos vectorial está lista.</p>
                            <p className="text-sm mt-2">Hacé una pregunta.</p>
                        </div>
                    ) : (
                        mensajes.map((msg, idx) => (
                            <div key={idx} className={`flex ${msg.rol === 'usuario' ? 'justify-end' : 'justify-start'}`}>
                                <div className={`max-w-[80%] rounded-lg px-4 py-3 shadow-md ${
                                    msg.rol === 'usuario' 
                                        ? 'bg-emerald-600 text-white rounded-br-none' 
                                        : 'bg-gray-700 text-gray-100 rounded-bl-none leading-relaxed'
                                }`}>
                                    {msg.contenido}
                                </div>
                            </div>
                        ))
                    )}
                    
                    {/* Indicador de carga */}
                    {cargando && (
                        <div className="flex justify-start">
                            <div className="bg-gray-700 text-gray-300 rounded-lg rounded-bl-none px-4 py-3 flex items-center gap-3 shadow-md">
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-bounce"></div>
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                                <div className="w-2 h-2 bg-emerald-500 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                                <span className="ml-2 text-sm italic">Buscando similitud vectorial...</span>
                            </div>
                        </div>
                    )}
                </div>

                {/* Input de texto */}
                <form onSubmit={enviarMensaje} className="p-4 bg-gray-900 border-t border-gray-700 flex gap-3">
                    <input
                        type="text"
                        value={input}
                        onChange={(e) => setInput(e.target.value)}
                        placeholder="Ej: Mañana tengo un examen final en la facultad, ¿cómo aviso?"
                        className="flex-1 bg-gray-800 text-white rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-emerald-500 transition-shadow"
                        disabled={cargando}
                    />
                    <button
                        type="submit"
                        disabled={cargando}
                        className="bg-emerald-600 hover:bg-emerald-500 text-white font-bold py-2 px-6 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        Consultar
                    </button>
                </form>

            </div>
        </div>
    );
}