# WieAct

A Node.js backend API built with Express, TypeScript, and modern development tools.

## Features

- 🚀 **Express.js** - Fast, minimalist web framework
- 📝 **TypeScript** - Type-safe JavaScript development
- 🔧 **Hot Reload** - Automatic server restart with nodemon
- 🛡️ **Error Handling** - Global error handling middleware
- 📦 **Environment Config** - Typed environment variables
- 🎯 **ESLint & Prettier** - Code linting and formatting
- 📁 **Organized Structure** - Clean project architecture

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Navigate to the project directory:
   \\\ash
   cd WieAct
   \\\

2. Install dependencies:
   \\\ash
   npm install
   \\\

3. Start the development server:
   \\\ash
   npm run dev
   \\\

# WieAct — ESP8266 IoT Dashboard

A single Express.js instance that serves both the API and dashboard UI for rapid ESP8266 prototyping with **real-time WebSocket updates**.

## Features

- 📡 Collect readings posted by an ESP8266 (temperature, humidity, soil moisture)
- ⚡ **Real-time WebSocket updates** — dashboard updates instantly when ESP8266 sends data (no delays!)
- 📊 Built-in Chart.js dashboard with live data visualization
- 🔄 Auto-reconnecting WebSocket with connection status indicator
- 🧠 In-memory storage to keep deployment simple—no database required
- ☁️ Heroku-ready via `Procfile` (`web: node index.js`)

## Getting Started

### Prerequisites

- Node.js 18+
- npm

### Installation & Usage

```powershell
cd WieAct
npm install
npm start
```

The server listens on `PORT` (defaults to `3000`) and serves the dashboard at `http://localhost:3000`.

To run with hot reload during development:

```powershell
npm run dev
```

## API Reference

All payloads are JSON objects that include `temp`, `humidity`, and `moisture` as numbers.

### HTTP Endpoints

| Method | Path             | Description            |
|--------|------------------|------------------------|
| GET    | `/api/data`      | Returns all readings   |
| POST   | `/api/data`      | Adds a new reading     |
| POST   | `/api/data/clear`| Clears stored readings |

### WebSocket (Real-time Updates)

Connect to `ws://your-host/` or `wss://your-host/` for real-time updates.

**Message Types:**
- `init` - Initial data load when client connects
- `newReading` - Sent immediately when ESP8266 posts new data
- `clear` - Sent when data is cleared

**Example:**
```javascript
const ws = new WebSocket('ws://localhost:3000');
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log(message.type, message.data);
};
```

### Example Requests

```powershell
# POST a reading from an ESP8266 sketch
Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/data -Body '{"temp":24.5,"humidity":60,"moisture":350}' -ContentType 'application/json'

# Retrieve logged readings
Invoke-RestMethod -Method Get -Uri http://localhost:3000/api/data

# Clear history
Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/data/clear
```

### Test ESP8266 Simulator

To test the real-time updates locally:

```powershell
node test-esp8266.js
```

This will simulate an ESP8266 sending readings every 3 seconds. Watch your dashboard update instantly!

## Project Structure

```
WieAct/
├── index.js        # Express application & API
├── public/
│   └── index.html  # Dashboard UI (HTML, CSS, JS)
├── Procfile        # Heroku process definition
└── package.json    # Dependencies & scripts
```

## Environment Variables

| Name  | Default | Purpose                        |
|-------|---------|--------------------------------|
| PORT  | `3000`  | HTTP port to listen on         |
| HOST  | `0.0.0.0` | Host interface for the server |

Create a `.env` file in the project root if you need to override defaults.

## Deployment

Deploy directly to Heroku or any Node-compatible environment. Heroku reads the provided `Procfile` and starts the app with `node index.js`.

## License

MIT
2. Create your feature branch (\git checkout -b feature/amazing-feature\)
