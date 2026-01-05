/**
 * Vercel Serverless Function - Signal History
 * Retorna o histórico de sinais recebidos
 */

const { setupCors } = require('./cors');
const { getSignal } = require('./webhook');

module.exports = async (req, res) => {
    await setupCors(req, res);

    if (req.method !== 'GET') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const signalStore = getSignal();

    // Retornar array com sinal atual ou array vazio
    const signals = signalStore.data ? [signalStore.data] : [];

    res.json({
        signals,
        count: signals.length,
        lastUpdate: signalStore.timestamp || 0
    });
};
