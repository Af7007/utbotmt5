const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware para JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Log de todas as requisições
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

// Rota para receber webhook do TradingView
app.post('/webhook', (req, res) => {
    console.log('=== SINAL RECEBIDO ===');
    console.log('Body:', req.body);

    // Salvar no arquivo de sinal
    const signalPath = path.join(__dirname, 'signal_XAUUSD.json');

    try {
        fs.writeFileSync(signalPath, JSON.stringify(req.body, null, 2));
        console.log('Sinal salvo em:', signalPath);

        // Ler e mostrar o arquivo salvo
        const saved = JSON.parse(fs.readFileSync(signalPath, 'utf8'));
        console.log('Conteudo salvo:', saved);

        res.sendStatus(200);
    } catch (error) {
        console.error('Erro ao salvar sinal:', error);
        res.status(500).json({ error: 'Erro ao salvar sinal' });
    }
});

// Rota para os clients consultarem o sinal atual
app.get('/signal', (req, res) => {
    const signalPath = path.join(__dirname, 'signal_XAUUSD.json');

    if (fs.existsSync(signalPath)) {
        console.log('>>> Client consultou sinal');
        res.sendFile(signalPath);
    } else {
        console.log('>>> Client consultou - SEM SINAL');
        res.status(404).json({ action: '', symbol: '' });
    }
});

// Rota de health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Rota principal
app.get('/', (req, res) => {
    res.send(`
    <h1>TradingView Signal Server</h1>
    <h2>Endpoints:</h2>
    <ul>
        <li>POST /webhook - Recebe sinal do TradingView</li>
        <li>GET /signal - Consulta sinal atual (para clients)</li>
        <li>GET /health - Health check</li>
    </ul>
    <h2>Configuração TradingView:</h2>
    <p>Webhook URL: <code>https://seu-ngrok-url.ngrok-free.app/webhook</code></p>
    `);
});

app.listen(PORT, () => {
    console.log('========================================');
    console.log(`TRADINGVIEW SIGNAL SERVER`);
    console.log(`Port: ${PORT}`);
    console.log(`Time: ${new Date().toLocaleString()}`);
    console.log('========================================');
    console.log('\nPara usar com ngrok:');
    console.log('1. Instale ngrok: https://ngrok.com/download');
    console.log('2. Execute: ngrok http 3000');
    console.log('3. Copie a URL gerada e configure no TradingView webhook\n');
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\nServidor encerrado.');
    process.exit(0);
});
