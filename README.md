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

Run the backend and frontend in two separate terminals, each starting from the repo root (`ai-home-assistant/`).

### Backend (terminal 1)

First time:

```bash
cd backend
python3.12 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
pytest
```

Every time:

```bash
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload
```

The API runs at http://localhost:8000 (docs at http://localhost:8000/docs).

### Frontend (terminal 2)

First time:

```bash
cd frontend
npm install
```

Every time:

```bash
cd frontend
npm run dev
```

Open http://localhost:5173. Vite proxies `/api` and `/ws` to the backend on port 8000, so start the backend first.

`npm install` may warn that `fsevents` has install scripts not covered by `allowScripts`. Ignore it; the package ships a prebuilt binary and works without the script.

### Troubleshooting

If `python3.12 -m venv` fails with an `ensurepip` error, `python3.12` is probably a uv-managed Python behind a symlink (e.g. in `~/.local/bin`). Delete `.venv` and create it from the real interpreter instead:

```bash
cd backend
rm -rf .venv
"$(python3.12 -c 'import os, sys; print(os.path.realpath(sys.executable))')" -m venv .venv
# or, with uv (no pip inside; use `uv pip install -r requirements-dev.txt`)
uv venv --python 3.12 .venv
source .venv/bin/activate
```
