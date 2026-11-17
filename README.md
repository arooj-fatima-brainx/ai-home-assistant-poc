# AI Home Assistant

## Structure

```
backend/      FastAPI app (Python 3.12)
simulator/    MQTT device simulator (Python 3.12)
frontend/     React + Vite + TypeScript
mosquitto/    MQTT broker config
ha-config/    Home Assistant config volume
scripts/      helper scripts
data/         local data (git-ignored)
models/       speech models (git-ignored)
```

## Setup

```bash
cp .env.example .env            # fill in the values
./scripts/mosquitto_passwd.sh   # creates the MQTT password file
docker compose up --build
```

| Service | URL |
|---|---|
| Frontend | http://localhost:5173 |
| Backend API docs | http://localhost:8000/docs |
| Home Assistant | http://localhost:8123 |

## Development

```bash
# Backend
cd backend
python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
pytest
uvicorn app.main:app --reload

# Frontend
cd frontend
npm install
npm run dev
```
