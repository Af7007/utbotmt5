/**
 * CORS Setup simplificado - sem dependências externas
 */

function setupCors(req, res) {
    // Headers CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Responder imediatamente para OPTIONS preflight
    if (req.method === 'OPTIONS') {
        res.statusCode = 200;
        res.end();
        return true;
    }
    return false;
}

module.exports = { setupCors };
