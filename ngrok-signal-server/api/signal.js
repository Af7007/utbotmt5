/**
 * Vercel Serverless Function - Signal Reader
 * Clients consultam este endpoint para obter o sinal atual do Upstash Redis
 */

const { setupCors } = require('./cors');
const { kv } = require('@vercel/kv');

module.exports = async (req, res) => {
    // Setup CORS
    if (setupCors(req, res)) return;

    // Apenas GET permitido
    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        const parsed = await kv.get('current_signal');

        // Se não tem sinal, retorna 404
        if (!parsed) {
            return res.status(404).json({ action: '', symbol: '' });
        }

        // Sinal expira após 5 minutos
        const SIGNAL_EXPIRY = 5 * 60 * 1000;
        const age = Date.now() - parsed.timestamp;

        if (age > SIGNAL_EXPIRY) {
            return res.status(404).json({ action: '', symbol: '' });
        }

        // Retornar o sinal como JSON string (para compatibilidade com o client Python)
        res.setHeader('Content-Type', 'application/json');
        res.send(JSON.stringify(parsed.data));

    } catch (error) {
        console.error('Signal endpoint error:', error);
        return res.status(500).json({ error: 'Internal server error', message: error.message });
    }
};
