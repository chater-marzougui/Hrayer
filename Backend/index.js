import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { WebSocketServer } from 'ws';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const publicDir = path.join(__dirname, 'public');

const app = express();
const readings = [];

app.use(express.json({ limit: '1mb' }));
app.use(express.static(publicDir));

const isNumber = (value) => typeof value === 'number' && Number.isFinite(value);

const normaliseReading = (payload = {}) => {
  const { temp, temperature, humidity, moisture, soilMoisture, createdAt, soilRaw } = payload;

  const resolvedTemp = temp ?? temperature;
  const resolvedHumidity = humidity;
  const resolvedMoisture = moisture ?? soilMoisture;
  const resolvedSoilRaw = soilRaw;

  const parsed = {
    temp: isNumber(resolvedTemp) ? resolvedTemp : Number(resolvedTemp),
    humidity: isNumber(resolvedHumidity) ? resolvedHumidity : Number(resolvedHumidity),
    moisture: isNumber(resolvedMoisture) ? resolvedMoisture : Number(resolvedMoisture),
    soilRaw: isNumber(resolvedSoilRaw) ? resolvedSoilRaw : Number(resolvedSoilRaw)
  };

  if (Number.isNaN(parsed.temp) || Number.isNaN(parsed.humidity) || Number.isNaN(parsed.moisture) || Number.isNaN(parsed.soilRaw)) {
    return null;
  }

  return {
    temp: parsed.temp,
    humidity: parsed.humidity,
    moisture: parsed.moisture,
    soilRaw: parsed.soilRaw,
    createdAt: createdAt ? new Date(createdAt).toISOString() : new Date().toISOString()
  };
};

app.get('/api/data', (_req, res) => {
  res.json(readings);
});

app.post('/api/data', (req, res) => {
  const reading = normaliseReading(req.body);

  if (!reading) {
    res.status(400).json({ error: 'Invalid payload. Expect numbers for temp, humidity, and moisture.' });
    return;
  }

  readings.push(reading);
  
  // Broadcast the new reading to all connected WebSocket clients
  broadcast({ type: 'newReading', data: reading });
  
  res.status(201).json(reading);
});

app.post('/api/data/clear', (_req, res) => {
  readings.length = 0;
  
  // Notify all clients that data was cleared
  broadcast({ type: 'clear' });
  
  res.status(204).send();
});

app.get('/', (_req, res) => {
  res.sendFile(path.join(publicDir, 'index.html'));
});

const normalisedPort = process.env.PORT !== undefined ? Number(process.env.PORT) : 3000;
const port = Number.isFinite(normalisedPort) && normalisedPort >= 0 ? normalisedPort : 3000;
const host = process.env.HOST || '0.0.0.0';

const server = app.listen(port, host, () => {
  console.log(`WieAct IoT dashboard listening on http://${host}:${port}`);
});

// WebSocket server for real-time updates
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  console.log('Client connected to WebSocket');
  
  // Send current data to newly connected client
  ws.send(JSON.stringify({ type: 'init', data: readings }));
  
  ws.on('close', () => {
    console.log('Client disconnected from WebSocket');
  });
});

// Broadcast to all connected WebSocket clients
const broadcast = (message) => {
  wss.clients.forEach((client) => {
    if (client.readyState === 1) { // WebSocket.OPEN
      client.send(JSON.stringify(message));
    }
  });
};

export { app, server, broadcast };
