/**
 * Vercel Serverless Function - Webhook Receiver
 * Recebe sinais do TradingView e armazena no Upstash Redis
 */

const { setupCors } = require('./cors');
const { kv } = require('@vercel/kv');

// Gera hash único do sinal para detectar duplicatas
function getSignalHash(data) {
    const action = (data.action || data.ticker || '').toLowerCase();
    const symbol = (data.symbol || data.exchange || '').toLowerCase();
    return `${action}:${symbol}`;
}

module.exports = async (req, res) => {
    // Setup CORS
    if (setupCors(req, res)) return;

    try {
        // POST /webhook - Receber sinal do TradingView
        if (req.method === 'POST') {
            const body = req.body;

            // Validar que tem dados
            if (!body || typeof body !== 'object') {
                return res.status(400).json({ error: 'Invalid JSON' });
            }

            const newHash = getSignalHash(body);

            // Verificar sinal anterior para evitar duplicatas
            const existing = await kv.get('current_signal');
            const DUPLICATE_WINDOW = 30000; // 30 segundos

            if (existing) {
                const existingHash = getSignalHash(existing.data);
                const age = Date.now() - existing.timestamp;

                // Se é o mesmo sinal e dentro da janela de duplicata, ignorar
                if (existingHash === newHash && age < DUPLICATE_WINDOW) {
                    console.log('DUPLICATE SIGNAL IGNORED:', {
                        hash: newHash,
                        age: age + 'ms',
                        time: new Date().toISOString()
                    });
                    return res.status(200).json({
                        success: true,
                        duplicate: true,
                        message: 'Duplicate signal ignored'
                    });
                }
            }

            // Armazenar no Redis
            const signalData = {
                data: body,
                timestamp: Date.now()
            };

            await kv.set('current_signal', signalData);

            console.log('SIGNAL RECEIVED:', {
                hash: newHash,
                action: body.action || body.ticker,
                symbol: body.symbol || body.exchange,
                time: new Date().toISOString()
            });

            return res.status(200).json({
                success: true,
                received: body
            });
        }

        // GET /webhook - Status do webhook
        if (req.method === 'GET') {
            const parsed = await kv.get('current_signal');

            return res.status(200).json({
                status: 'running',
                hasSignal: parsed !== null,
                signalAge: parsed ? Date.now() - parsed.timestamp : 0,
                signal: parsed ? parsed.data : null
            });
        }

        // Método não permitido
        return res.status(405).json({ error: 'Method not allowed' });

    } catch (error) {
        console.error('Webhook endpoint error:', error);
        return res.status(500).json({ error: 'Internal server error', message: error.message });
    }
};
