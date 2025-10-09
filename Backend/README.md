# WieAct — ESP8266 IoT Dashboard# WieAct



A Node.js backend built with Express.js that serves both an API and dashboard UI for rapid ESP8266 prototyping with **real-time WebSocket updates**.A Node.js backend API built with Express, TypeScript, and modern development tools.



## Features## Features



- 📡 **IoT Data Collection** — Collect readings from ESP8266 devices (temperature, humidity, soil moisture)- 🚀 **Express.js** - Fast, minimalist web framework

- ⚡ **Real-time WebSocket Updates** — Dashboard updates instantly when ESP8266 sends data (no delays!)- 📝 **TypeScript** - Type-safe JavaScript development

- 📊 **Built-in Dashboard** — Chart.js visualization with live data updates- 🔧 **Hot Reload** - Automatic server restart with nodemon

- 🔄 **Auto-reconnecting WebSocket** — Connection status indicator and automatic reconnection- 🛡️ **Error Handling** - Global error handling middleware

- 🧠 **In-memory Storage** — Simple deployment without database requirements- 📦 **Environment Config** - Typed environment variables

- ☁️ **Heroku-ready** — Deploy with `Procfile` included- 🎯 **ESLint & Prettier** - Code linting and formatting

- 🚀 **Express.js** — Fast, minimalist web framework- 📁 **Organized Structure** - Clean project architecture

- 🔧 **Hot Reload** — Automatic server restart with nodemon during development

## Getting Started

## Getting Started

### Prerequisites

### Prerequisites

- Node.js (v14 or higher)

- Node.js 18+- npm or yarn

- npm

### Installation

### Installation & Usage

1. Navigate to the project directory:

```powershell   \\\ash

cd Backend   cd WieAct

npm install   \\\

npm start

```2. Install dependencies:

   \\\ash

The server listens on `PORT` (defaults to `3000`) and serves the dashboard at `http://localhost:3000`.   npm install

   \\\

To run with hot reload during development:

3. Start the development server:

```powershell   \\\ash

npm run dev   npm run dev

```   \\\



## API Reference# WieAct — ESP8266 IoT Dashboard



All payloads are JSON objects that include `temp`, `humidity`, and `moisture` as numbers.A single Express.js instance that serves both the API and dashboard UI for rapid ESP8266 prototyping with **real-time WebSocket updates**.



### HTTP Endpoints## Features



| Method | Path             | Description            |- 📡 Collect readings posted by an ESP8266 (temperature, humidity, soil moisture)

|--------|------------------|------------------------|- ⚡ **Real-time WebSocket updates** — dashboard updates instantly when ESP8266 sends data (no delays!)

| GET    | `/api/data`      | Returns all readings   |- 📊 Built-in Chart.js dashboard with live data visualization

| POST   | `/api/data`      | Adds a new reading     |- 🔄 Auto-reconnecting WebSocket with connection status indicator

| POST   | `/api/data/clear`| Clears stored readings |- 🧠 In-memory storage to keep deployment simple—no database required

- ☁️ Heroku-ready via `Procfile` (`web: node index.js`)

### WebSocket (Real-time Updates)

## Getting Started

Connect to `ws://your-host/` or `wss://your-host/` for real-time updates.

### Prerequisites

**Message Types:**

- `init` - Initial data load when client connects- Node.js 18+

- `newReading` - Sent immediately when ESP8266 posts new data- npm

- `clear` - Sent when data is cleared

### Installation & Usage

**Example:**

```javascript```powershell

const ws = new WebSocket('ws://localhost:3000');cd WieAct

ws.onmessage = (event) => {npm install

  const message = JSON.parse(event.data);npm start

  console.log(message.type, message.data);```

};

```The server listens on `PORT` (defaults to `3000`) and serves the dashboard at `http://localhost:3000`.



### Example RequestsTo run with hot reload during development:



```powershell```powershell

# POST a reading from an ESP8266 sketchnpm run dev

Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/data -Body '{"temp":24.5,"humidity":60,"moisture":350}' -ContentType 'application/json'```



# Retrieve logged readings## API Reference

Invoke-RestMethod -Method Get -Uri http://localhost:3000/api/data

All payloads are JSON objects that include `temp`, `humidity`, and `moisture` as numbers.

# Clear history

Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/data/clear### HTTP Endpoints

```

| Method | Path             | Description            |

### Test ESP8266 Simulator|--------|------------------|------------------------|

| GET    | `/api/data`      | Returns all readings   |

To test the real-time updates locally:| POST   | `/api/data`      | Adds a new reading     |

| POST   | `/api/data/clear`| Clears stored readings |

```powershell

node test-esp8266.js### WebSocket (Real-time Updates)

```

Connect to `ws://your-host/` or `wss://your-host/` for real-time updates.

This will simulate an ESP8266 sending readings every 3 seconds. Watch your dashboard update instantly!

**Message Types:**

## Project Structure- `init` - Initial data load when client connects

- `newReading` - Sent immediately when ESP8266 posts new data

```- `clear` - Sent when data is cleared

Backend/

├── index.js        # Express application & API**Example:**

├── public/```javascript

│   └── index.html  # Dashboard UI (HTML, CSS, JS)const ws = new WebSocket('ws://localhost:3000');

├── Procfile        # Heroku process definitionws.onmessage = (event) => {

├── package.json    # Dependencies & scripts  const message = JSON.parse(event.data);

└── test-esp8266.js # ESP8266 simulator for testing  console.log(message.type, message.data);

```};

```

## Environment Variables

### Example Requests

| Name  | Default | Purpose                        |

|-------|---------|--------------------------------|```powershell

| PORT  | `3000`  | HTTP port to listen on         |# POST a reading from an ESP8266 sketch

| HOST  | `0.0.0.0` | Host interface for the server |Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/data -Body '{"temp":24.5,"humidity":60,"moisture":350}' -ContentType 'application/json'



Create a `.env` file in the project root if you need to override defaults.# Retrieve logged readings

Invoke-RestMethod -Method Get -Uri http://localhost:3000/api/data

## Deployment to Heroku

# Clear history

### Deploy Backend SubdirectoryInvoke-RestMethod -Method Post -Uri http://localhost:3000/api/data/clear

```

Since the Backend is in a subdirectory, use git subtree to deploy only the Backend folder:

### Test ESP8266 Simulator

```powershell

# From the root of your repositoryTo test the real-time updates locally:

git subtree push --prefix Backend heroku main

``````powershell

node test-esp8266.js

### Alternative: Create Heroku App and Deploy```



```powershellThis will simulate an ESP8266 sending readings every 3 seconds. Watch your dashboard update instantly!

# Login to Heroku

heroku login## Project Structure



# Create a new Heroku app (from repository root)```

heroku create your-app-nameWieAct/

├── index.js        # Express application & API

# Add Heroku remote if not already added├── public/

heroku git:remote -a your-app-name│   └── index.html  # Dashboard UI (HTML, CSS, JS)

├── Procfile        # Heroku process definition

# Deploy only the Backend folder└── package.json    # Dependencies & scripts

git subtree push --prefix Backend heroku main```

```

## Environment Variables

The app will automatically start using the `Procfile` configuration.

| Name  | Default | Purpose                        |

## License|-------|---------|--------------------------------|

| PORT  | `3000`  | HTTP port to listen on         |

MIT| HOST  | `0.0.0.0` | Host interface for the server |


Create a `.env` file in the project root if you need to override defaults.

## Deployment

Deploy directly to Heroku or any Node-compatible environment. Heroku reads the provided `Procfile` and starts the app with `node index.js`.

## License

MIT
2. Create your feature branch (\git checkout -b feature/amazing-feature\)
