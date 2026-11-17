# AI Home Assistant POC: Use Cases

| | |
|---|---|
| **Status** | Approved (2026-11-17) |
| **Date** | 2026-11-17 |
| **Author** | Arooj Fatima |
| **Based on** | `docs/brainstorm.md`, `docs/plan.md`, `../PRD.md`, `../ARCHITECTURE.md` |

These use cases are the Definition of Done. If a behaviour is not written here, it is not tested. Every use case has a "How to test by hand" section so each one can be checked alone, in order.

## Summary

| UC ID | Name | Milestone | Criteria | Edge cases |
|---|---|---|---|---|
| UC-01 | Start the whole stack with one command | M1 | 4 | 4 |
| UC-02 | First-time Home Assistant setup | M1 | 4 | 2 |
| UC-03 | Virtual devices appear in Home Assistant | M1 | 5 | 3 |
| UC-04 | Control a virtual device from Home Assistant | M1 | 4 | 4 |
| UC-05 | Room temperature drift | M1 | 3 | 2 |
| UC-06 | Inject a device fault | M1 | 4 | 2 |
| UC-07 | Add or remove a device in `devices.yaml` | M1 | 3 | 4 |
| UC-08 | Sign up (and log in) | M1 | 3 | 9 |
| UC-09 | Log in | M1 | 3 | 5 |
| UC-10 | See who is logged in, and log out | M1 | 3 | 3 |
| UC-11 | Create a home and list my homes | M1 | 4 | 5 |
| UC-12 | Connect a home to Home Assistant | M1 | 5 | 7 |
| UC-13 | Test the Home Assistant connection | M1 | 3 | 3 |
| UC-14 | Only members can reach a home | M1 | 3 | 3 |
| UC-15 | See rooms and devices from the app | M1 | 5 | 5 |
| UC-16 | Switch a device on or off from the app | M1 | 4 | 9 |
| UC-17 | Tool-calling spike | M1 | 3 | 3 |
| UC-18 | Start, list and read conversations | M2 | 4 | 4 |
| UC-19 | Control one device by text | M2 | 5 | 5 |
| UC-20 | Follow-ups and corrections | M2 | 5 | 4 |
| UC-21 | Several actions in one message | M2 | 3 | 2 |
| UC-22 | Status questions | M2 | 4 | 3 |
| UC-23 | Clarify an ambiguous request | M2 | 3 | 2 |
| UC-24 | Implicit requests | M2 | 2 | 2 |
| UC-25 | Out-of-range values | M2 | 3 | 3 |
| UC-26 | Unknown device | M2 | 2 | 2 |
| UC-27 | Confirm big actions first | M2 | 3 | 4 |
| UC-28 | Offline devices, timeouts and partial failures | M2 | 3 | 2 |
| UC-29 | OpenAI or Home Assistant unavailable | M2 | 3 | 2 |
| UC-30 | Add and remove members (Should) | M2 | 3 | 5 |
| UC-31 | Delete a home (Should) | M2 | 3 | 2 |
| UC-32 | Only members can use the assistant and tools | M2 | 3 | 2 |
| UC-33 | Tool, token and latency logs | M2 | 4 | 2 |
| UC-34 | A new device works with no app change | M2 | 2 | 1 |
| UC-35 | Evaluation script | M2 | 4 | 3 |
| UC-36 | Sign-up, login and logout pages | M3 | 4 | 6 |
| UC-37 | Home switcher (Should) | M3 | 3 | 2 |
| UC-38 | Home settings page | M3 | 4 | 5 |
| UC-39 | Chat panel | M3 | 4 | 5 |
| UC-40 | Live dashboard | M3 | 4 | 4 |
| UC-41 | WebSocket access control | M3 | 3 | 1 |
| UC-42 | Push-to-talk voice input | M3 | 4 | 5 |
| UC-43 | Spoken replies and mute | M3 | 3 | 2 |
| UC-44 | Latency per stage for voice | M3 | 2 | 1 |
| UC-45 | Works on phone, tablet and desktop | M3 | 3 | 1 |
| UC-46 | Full device controls on the dashboard (Should) | M3 | 5 | 5 |
| UC-47 | Test server and phone test (Should) | M4 | 4 | 1 |
| UC-48 | Final evaluation and statistics | M4 | 3 | 1 |
| UC-49 | Setup from the README | M4 | 2 | 1 |
| UC-50 | Code, security and dependency review | M4 | 4 | 1 |
| UC-51 | Manage rooms in the app (Could) | M4 | 3 | 2 |
| UC-52 | Matter virtual light (Could) | M4 | 1 | 1 |
| | **M1 total (17 use cases)** | | **63** | **73** |
| | **M2 total (18 use cases)** | | **59** | **50** |
| | **M3 total (11 use cases)** | | **39** | **37** |
| | **M4 total (6 use cases)** | | **17** | **7** |
| | **All (52 use cases)** | | **178** | **167** |

Not a use case, but part of M1: task 1.10, the email to IT asking for test server access (done when the email is sent).

---

## Conventions for manual tests

- Run commands from the repo root `ai-home-assistant/`, with the stack running (`docker compose up --build`).
- API base: `BASE=http://localhost:8000/api`. Swagger UI at http://localhost:8000/docs works too.
- `curl` keeps each user's login cookie in its own file: `-c a.txt -b a.txt` for user A, `-c b.txt -b b.txt` for user B.
- Errors come back as JSON: `{"detail": "<message>"}`. Status codes are shown as `401`, `404` and so on.
- MQTT commands need the simulator credentials from `.env`:
  ```bash
  source .env
  docker compose exec mosquitto mosquitto_pub -u "$MQTT_USERNAME" -P "$MQTT_PASSWORD" -t <topic> -m '<payload>'
  docker compose exec mosquitto mosquitto_sub -u "$MQTT_USERNAME" -P "$MQTT_PASSWORD" -t 'sim/#' -v
  ```
- Inside Docker the backend reaches Home Assistant at `http://homeassistant:8123`. If the backend runs outside Docker (`uvicorn`), use `http://localhost:8123`.
- Entity IDs below (for example `light.kitchen_light`) are what HA is expected to create from the device names. If HA names one differently, use the ID shown in HA under Settings > Devices & services > Entities.

---

## M1: Home connected (2026-11-20)

### UC-01: Start the whole stack with one command
- Actor: Developer
- Milestone: M1
- Preconditions: Docker is running; `.env` is filled in; `./scripts/mosquitto_passwd.sh` has created `mosquitto/config/passwd`.
- Main flow:
  1. Developer runs `docker compose up --build`.
  2. Home Assistant, Mosquitto, simulator, backend and frontend start.
  3. Developer opens the backend health URL and Home Assistant.
- Acceptance criteria (Definition of Done):
  - [ ] AC-01.1 Given a clean checkout with `.env` filled in, when the developer runs `docker compose up --build`, then `docker compose ps` shows `homeassistant`, `mosquitto`, `simulator`, `backend` and `frontend` as running.
  - [ ] AC-01.2 Given the stack is running, when the developer opens http://localhost:8000/api/health, then it returns `200` with `{"status": "ok"}`.
  - [ ] AC-01.3 Given the stack is running, when the developer opens http://localhost:8123, then the Home Assistant page loads.
  - [ ] AC-01.4 Given the stack is running, when `docker compose ps` is checked, then every published port is bound to `127.0.0.1`, not `0.0.0.0`.
- Edge cases:
  - UC-01-E1: Given the stack is running, when a client connects to Mosquitto without a username and password, then the connection is refused with "not authorised".
  - UC-01-E2: Given `mosquitto/config/passwd` is missing, when the stack starts, then the Mosquitto log says the password file is missing and the README setup step says to run `./scripts/mosquitto_passwd.sh`.
  - UC-01-E3: Given a required backend key (for example `JWT_SECRET` or `HA_TOKEN_KEY`) is empty in `.env`, when the backend starts, then it stops with an error naming the missing key (it does not start with a weak default).
  - UC-01-E4: Given the stack was stopped with `docker compose down`, when it is started again, then users, homes and HA setup are still there (data lives in `./data` and `./ha-config`).
- How to test by hand:
  1. `docker compose up --build -d`, then `docker compose ps`. Expect 5 services running; ports show `127.0.0.1:...`.
  2. `curl -i http://localhost:8000/api/health`. Expect `200` and `{"status":"ok"}`.
  3. Open http://localhost:8123 in the browser. Expect the HA login or onboarding page.
  4. E1: `docker compose exec mosquitto mosquitto_sub -t '#'`. Expect "Connection error: Connection Refused: not authorised."
  5. E3: empty `JWT_SECRET` in `.env`, `docker compose up -d backend`, `docker compose logs backend`. Expect an error naming `JWT_SECRET`. Put the value back.
  6. E4: `docker compose down && docker compose up -d`, then repeat a login from UC-09. Expect it to work.
- Not included: test server deployment (M4); HTTPS.

### UC-02: First-time Home Assistant setup
- Actor: Developer
- Milestone: M1
- Preconditions: UC-01 done; HA is on its onboarding page.
- Main flow:
  1. Developer creates the HA admin account in the onboarding wizard.
  2. Developer adds the MQTT integration in the HA UI (broker `mosquitto`, port 1883, `HA_MQTT_USERNAME` and `HA_MQTT_PASSWORD`).
  3. Developer adds the alias "lounge" to the Living room area.
  4. Developer creates a long-lived access token in the HA user profile and keeps it for UC-12.
- Acceptance criteria (Definition of Done):
  - [ ] AC-02.1 Given the README setup checklist, when the developer follows it step by step, then HA ends with an admin user, the MQTT integration and a long-lived token, with no step missing from the checklist.
  - [ ] AC-02.2 Given the MQTT integration is added with the HA credentials, when the developer opens Settings > Devices & services > MQTT, then it shows as connected (no error badge).
  - [ ] AC-02.3 Given the alias "lounge" is added, when the developer opens Settings > Areas > Living room, then "lounge" is listed as an alias.
  - [ ] AC-02.4 Given HA is restarted (`docker compose restart homeassistant`), when the developer logs in again, then the admin user, MQTT integration, areas and aliases are still there.
- Edge cases:
  - UC-02-E1: Given the developer types a wrong MQTT password in the integration form, when they submit, then HA shows a connection error and the integration is not added.
  - UC-02-E2: Given the developer deletes the long-lived token in HA, when the app later uses it, then the app reports "Home Assistant rejected the token" (see UC-12-E1, UC-13-E2).
- How to test by hand:
  1. Follow the README checklist in a fresh `ha-config` (or on first start). Tick each step.
  2. Check the MQTT integration page and the Living room area page as in AC-02.2 and AC-02.3.
  3. `docker compose restart homeassistant`, log in, check again.
  4. E1: add the MQTT integration with a wrong password first. Expect an error; then use the right one.
- Not included: automating HA onboarding (manual by design); room management from our app (Could, M4).

### UC-03: Virtual devices appear in Home Assistant
- Actor: Developer
- Milestone: M1
- Preconditions: UC-02 done (MQTT integration connected); the simulator runs with the default `simulator/devices.yaml`.
- Main flow:
  1. The simulator reads `devices.yaml`.
  2. It publishes an MQTT discovery message, a retained state and `online` availability for each device.
  3. Home Assistant creates the devices and places them in their rooms.
- Acceptance criteria (Definition of Done):
  - [ ] AC-03.1 Given the default `devices.yaml`, when the developer opens Settings > Devices & services > MQTT, then exactly the 11 test devices from PRD section 5.7 are listed (13 entities, because each sensor has temperature and humidity).
  - [ ] AC-03.2 Given the devices are discovered, when the developer opens Settings > Areas, then Living room has 5 devices, Bedroom has 4 and Kitchen has 2, with no manual room assignment.
  - [ ] AC-03.3 Given the devices are discovered, when the developer opens each AC, then Living room AC allows 16 to 30 °C with modes cool, dry, fan only, auto, and Bedroom AC allows 18 to 28 °C with modes cool, auto.
  - [ ] AC-03.4 Given the devices are discovered, when the developer checks the lights and fans, then the kitchen light has no brightness slider, the other lights do, the two ceiling fans have 5 speeds and the kitchen exhaust fan is on/off only.
  - [ ] AC-03.5 Given the devices are discovered, when the developer runs `mosquitto_sub -t 'sim/#' -v`, then a retained `state` and an `online` `availability` message arrive at once for every device.
- Edge cases:
  - UC-03-E1: Given HA is restarted, when it comes back, then all 11 devices come back with the same states (retained messages), without restarting the simulator.
  - UC-03-E2: Given the simulator is stopped (`docker compose stop simulator`), when the developer looks at HA, then all 11 devices show "Unavailable" within 5 seconds.
  - UC-03-E3: Given the simulator is started again, when it reconnects, then the devices are available again with the same states they had before it stopped (state file).
- How to test by hand:
  1. Open HA > Settings > Devices & services > MQTT. Count 11 devices.
  2. Open Settings > Areas and count devices per room.
  3. Open Living room AC and Bedroom AC; try to set each temperature dial past its limits. Expect the dial to stop at the limit.
  4. Open the kitchen light and the bedroom light; compare controls. Open a ceiling fan and the exhaust fan.
  5. Run the `mosquitto_sub` command from Conventions. Expect state and availability lines for every device.
  6. E1: `docker compose restart homeassistant`; check states are unchanged.
  7. E2 and E3: turn on the bedroom light, `docker compose stop simulator`, watch HA; then `docker compose start simulator`. Expect "Unavailable", then the light back and still on.
- Not included: Matter devices (Could); real hardware (out of scope).

### UC-04: Control a virtual device from Home Assistant
- Actor: Developer
- Milestone: M1
- Preconditions: UC-03 done.
- Main flow:
  1. Developer changes a device in the HA UI (switch, brightness, temperature, mode, fan speed).
  2. HA sends the command on `sim/<device_id>/set`.
  3. The simulator updates the device and publishes the new state.
  4. HA shows the new state.
- Acceptance criteria (Definition of Done):
  - [ ] AC-04.1 Given the kitchen light is off, when the developer switches it on in HA, then HA shows it on within 1 second and `sim/kitchen_light/state` shows it on.
  - [ ] AC-04.2 Given the living room main light is on, when the developer sets brightness to 40% in HA, then HA shows 40% after the change.
  - [ ] AC-04.3 Given the bedroom AC is off, when the developer sets mode cool and temperature 22 in HA, then HA shows cool and 22 °C.
  - [ ] AC-04.4 Given the bedroom ceiling fan is off, when the developer sets speed 3 of 5 (60%) in HA, then HA shows the fan on at 60%.
- Edge cases:
  - UC-04-E1: Given the bedroom AC range is 18 to 28 °C, when `{"temperature": 35}` is published straight to `sim/bedroom_ac/set`, then the simulator ignores it, logs a warning, and the AC stays at its old temperature.
  - UC-04-E2: Given the simulator is running, when invalid JSON (`hello`) is published to a `set` topic, then the simulator logs a warning, keeps running, and no state changes.
  - UC-04-E3: Given a command for a device ID that is not in `devices.yaml` (`sim/garage_light/set`), when it is published, then the simulator ignores it and logs a warning.
  - UC-04-E4: Given the bedroom AC is at 22 °C, when the simulator is restarted, then the AC is still at 22 °C (state file).
- How to test by hand:
  1. In HA, do each change from AC-04.1 to AC-04.4. Keep `mosquitto_sub -t 'sim/#' -v` open in another terminal and watch the state messages.
  2. E1: `mosquitto_pub -t sim/bedroom_ac/set -m '{"temperature": 35}'`; check HA and `docker compose logs simulator`.
  3. E2: `mosquitto_pub -t sim/bedroom_light/set -m 'hello'`; check the simulator log and that it is still running.
  4. E3: `mosquitto_pub -t sim/garage_light/set -m '{"state": "on"}'`; check the log.
  5. E4: `docker compose restart simulator`; check the AC in HA.
- Not included: control from our app (UC-16); control by AI (M2).

### UC-05: Room temperature drift
- Actor: Developer
- Milestone: M1
- Preconditions: UC-03 done. Default drift: 1 °C every 30 seconds towards the target, ambient 32 °C (both configurable in `devices.yaml`).
- Main flow:
  1. An AC is switched on with a set point.
  2. The room sensor's temperature moves towards the set point.
  3. When the AC is off, it moves back towards ambient.
- Acceptance criteria (Definition of Done):
  - [ ] AC-05.1 Given the bedroom sensor reads above 22 °C, when the bedroom AC is turned on at 22 °C (cool), then the bedroom sensor temperature goes down by at least 1 °C within 1 minute, and keeps going down until it reaches 22 °C.
  - [ ] AC-05.2 Given the bedroom AC is turned off, when time passes, then the bedroom sensor temperature rises towards 32 °C and stops at 32 °C.
  - [ ] AC-05.3 Given the bedroom AC is cooling, when the developer looks at the living room sensor, then it does not change because of the bedroom AC (each sensor follows only its own room's AC).
- Edge cases:
  - UC-05-E1: Given the sensor already reads exactly the set point, when time passes, then it stays there (no jumping up and down).
  - UC-05-E2: Given the bedroom AC shows its current temperature in HA, when the bedroom sensor changes, then the AC's current temperature in HA shows the same value.
- How to test by hand:
  1. In HA, note the bedroom sensor temperature. Turn the bedroom AC on, cool, 22 °C.
  2. Watch the sensor history (or `mosquitto_sub -t sim/bedroom_sensor/state -v`) for 1 to 2 minutes. Expect it to fall in 1 °C steps (32 °C to 22 °C takes about 5 minutes).
  3. Turn the AC off; watch it rise. Check the living room sensor stayed the same.
- Not included: humidity changes (humidity stays at its configured value).

### UC-06: Inject a device fault
- Actor: Developer
- Milestone: M1
- Preconditions: UC-03 done.
- Main flow:
  1. Developer publishes `offline`, `ignore_commands` or `normal` to `sim/<device_id>/fault`.
  2. The simulator changes how that device behaves.
- Acceptance criteria (Definition of Done):
  - [ ] AC-06.1 Given the bedroom light is online, when `offline` is published to `sim/bedroom_light/fault`, then HA shows the bedroom light as "Unavailable" within 2 seconds and the other devices stay available.
  - [ ] AC-06.2 Given the kitchen light has the `ignore_commands` fault, when the developer switches it on in HA, then its state in HA does not change (it stays or returns to off) and the simulator log says the command was ignored.
  - [ ] AC-06.3 Given a device has any fault, when `normal` is published to its fault topic, then it is available and answers commands again.
  - [ ] AC-06.4 Given the bedroom light is offline by fault, when the developer turns it on in HA, then nothing changes and HA still shows "Unavailable".
- Edge cases:
  - UC-06-E1: Given an unknown fault value (`explode`) is published, when the simulator reads it, then it logs a warning and the device keeps its current behaviour.
  - UC-06-E2: Given a device has a fault, when the simulator restarts, then the device starts `normal` (faults are not saved).
- How to test by hand:
  1. `mosquitto_pub -t sim/bedroom_light/fault -m offline`. Check HA.
  2. Try to turn the bedroom light on in HA. Expect no change.
  3. `mosquitto_pub -t sim/kitchen_light/fault -m ignore_commands`, toggle it in HA, check `docker compose logs simulator`.
  4. Publish `normal` to both; toggle again. Expect it to work.
  5. E1 and E2: publish `explode`, check the log; set `offline`, `docker compose restart simulator`, check the device is available.
- Not included: slow responses (a delay fault); the app-side handling of faults (M2: T15, T16).

### UC-07: Add or remove a device in `devices.yaml`
- Actor: Developer
- Milestone: M1
- Preconditions: UC-03 done; the simulator watches `simulator/devices.yaml`.
- Main flow:
  1. Developer adds an entry to `devices.yaml` (for example a "Bedroom lamp", dimmable light, room Bedroom) and saves.
  2. The simulator publishes discovery for it; HA adds it in the right room.
  3. Developer removes the entry and saves; the device disappears.
- Acceptance criteria (Definition of Done):
  - [ ] AC-07.1 Given the stack is running, when a new light entry is saved in `devices.yaml`, then within 10 seconds it appears in HA in its room, with no restart and no code change.
  - [ ] AC-07.2 Given that new device exists, when its entry is removed and the file saved, then within 10 seconds it is gone from HA.
  - [ ] AC-07.3 Given a device's `max_temp` is changed in `devices.yaml`, when the file is saved, then HA shows the new limit within 10 seconds.
- Edge cases:
  - UC-07-E1: Given the file is saved with invalid YAML, when the simulator reloads, then it logs an error with the line number and keeps the previous device list running.
  - UC-07-E2: Given two entries have the same `id`, when the file is saved, then the simulator logs an error naming the duplicate `id` and keeps the previous device list.
  - UC-07-E3: Given an entry has an unknown `type` (for example `toaster`), when the file is saved, then that entry is skipped with a logged error and the other devices load.
  - UC-07-E4: Given the file is saved with an empty device list, when the simulator reloads, then all devices are removed from HA (allowed, but logged as a warning).
- How to test by hand:
  1. Add the "Bedroom lamp" entry, save, watch HA > Areas > Bedroom.
  2. Change Bedroom AC `max_temp` to 26, save, check the AC dial; change it back.
  3. Remove the lamp, save, check HA.
  4. E1 to E3: save each broken version, check `docker compose logs simulator`, then fix the file.
- Not included: adding devices from our app (out of scope).

### UC-08: Sign up (and log in)
- Actor: New user
- Milestone: M1
- Preconditions: Backend running. No frontend yet (the web form is M3); tested through the API.
- Main flow:
  1. User sends name, email and password to `POST /api/auth/signup`.
  2. Backend checks the fields, stores an Argon2 hash of the password and creates the user.
  3. Backend logs the user in: it sets the same login cookie as UC-09 and returns the new user (no password, no hash).
- Acceptance criteria (Definition of Done):
  - [ ] AC-08.1 Given valid name, email and an 8+ character password, when the user signs up, then the response is `201` with `id`, `name` and `email` only, plus a `Set-Cookie` header (`HttpOnly`, `SameSite=Lax`, 24-hour expiry), and `GET /api/auth/me` with that cookie returns `200`.
  - [ ] AC-08.2 Given a user signed up, when the developer looks at the `users` table, then `password_hash` starts with `$argon2` and the plain password is not stored anywhere.
  - [ ] AC-08.3 Given a user signed up, when the developer reads the backend logs, then the password and hash do not appear.
- Edge cases:
  - UC-08-E1: Given the email is already registered, when someone signs up with it, then the response is `409` "Email already registered".
  - UC-08-E2: Given the email differs only in case or spaces (`  Ali@Example.com `), when signing up, then it is treated as `ali@example.com` (so E1 applies if that exists).
  - UC-08-E3: Given name, email or password is missing or empty (only spaces), when signing up, then the response is `422` naming the field.
  - UC-08-E4: Given the email has no valid format (`ali@`), when signing up, then the response is `422` "Invalid email".
  - UC-08-E5: Given the password has fewer than 8 characters, when signing up, then the response is `422` "Password must be at least 8 characters".
  - UC-08-E6: Given a name longer than 100 characters or a password longer than 128, when signing up, then the response is `422` with the limit.
  - UC-08-E7: Given two sign-ups with the same email arrive at the same time, when both are processed, then exactly one gets `201` and the other `409`.
  - UC-08-E8: Given sign-up fails (any `409` or `422` above), when the response is checked, then no `Set-Cookie` header is sent.
  - UC-08-E9: Given the user is already logged in as someone else, when they sign up a new account, then the cookie is replaced and `GET /api/auth/me` shows the new account.
- How to test by hand:
  1. ```bash
     curl -i -c a.txt -b a.txt -X POST $BASE/auth/signup -H 'Content-Type: application/json' \
       -d '{"name":"Ali","email":"ali@example.com","password":"secret123"}'
     ```
     Expect `201` with no password field, and a `Set-Cookie` header. Then `curl -i -b a.txt $BASE/auth/me`: expect `200`.
  2. `sqlite3 data/app.db "select email, password_hash from users;"`. Expect `$argon2...`.
  3. `docker compose logs backend | grep -i secret123`. Expect nothing.
  4. E1, E2: repeat step 1, then with `"  Ali@Example.com "`. Expect `409` both times.
  5. E3 to E6: send an empty name, `"email":"ali@"`, `"password":"short"`, a 101-character name. Check each `422` message.
  6. E7: run the same sign-up twice in parallel with a new email: `for i in 1 2; do curl -s -o /dev/null -w '%{http_code}\n' -X POST ... & done; wait`. Expect one `201` and one `409`.
  7. E8: repeat a failing sign-up with `-i` and check there is no `Set-Cookie`.
  8. E9: with `a.txt` (Ali), sign up `temp@example.com` using `-c a.txt -b a.txt`, call `/auth/me`. Expect the new account. Log in as Ali again.
- Not included: email verification, password reset, social login (out of scope); the sign-up page (M3).

### UC-09: Log in
- Actor: Registered user
- Milestone: M1
- Preconditions: UC-08 done (user `ali@example.com` exists).
- Main flow:
  1. User sends email and password to `POST /api/auth/login`.
  2. Backend checks the password against the hash.
  3. Backend sets a signed JWT in an `httpOnly` cookie and returns the user.
- Acceptance criteria (Definition of Done):
  - [ ] AC-09.1 Given the right email and password, when the user logs in, then the response is `200` with the user, and a `Set-Cookie` header with `HttpOnly`, `SameSite=Lax` and a 24-hour expiry.
  - [ ] AC-09.2 Given the user logged in, when they call a protected route with the cookie (`GET /api/auth/me`), then it returns `200`.
  - [ ] AC-09.3 Given the user logged in, when the response body is checked, then it does not contain the token (the browser only keeps it in the cookie).
- Edge cases:
  - UC-09-E1: Given a wrong password, when logging in, then the response is `401` "Wrong email or password".
  - UC-09-E2: Given an email that is not registered, when logging in, then the response is the same `401` "Wrong email or password" (no hint whether the email exists).
  - UC-09-E3 (T22): Given 5 failed logins for one email from one IP within 15 minutes, when a 6th attempt is made (even with the right password), then the response is `429` "Too many login attempts. Try again later." until 15 minutes have passed.
  - UC-09-E4: Given the cookie value is changed by hand, when a protected route is called, then the response is `401` "Not logged in".
  - UC-09-E5: Given the token has expired, when a protected route is called, then the response is `401` "Not logged in".
- How to test by hand:
  1. ```bash
     curl -i -c a.txt -X POST $BASE/auth/login -H 'Content-Type: application/json' \
       -d '{"email":"ali@example.com","password":"secret123"}'
     ```
     Check the `Set-Cookie` flags.
  2. `curl -i -b a.txt $BASE/auth/me`. Expect `200`.
  3. E1, E2: log in with a wrong password, then with `nobody@example.com`. Compare messages.
  4. E3: log in 5 times with a wrong password, then once with the right one. Expect `429`.
  5. E4: edit one character of the token in `a.txt`, call `/auth/me`. Expect `401`. Log in again.
  6. E5: set `JWT_EXPIRE_MINUTES=1` in `.env`, restart the backend, log in, wait 70 seconds, call `/auth/me`. Expect `401`. Put the value back.
- Not included: 2FA, "remember me" (out of scope); the login page (M3). Sign-up already logs the user in (UC-08); this use case is for later visits. The rate-limit counter is kept in memory, so it resets when the backend restarts (fine for a POC).

### UC-10: See who is logged in, and log out
- Actor: Logged-in user
- Milestone: M1
- Preconditions: UC-09 done.
- Main flow:
  1. User calls `GET /api/auth/me` and sees their name, email and homes.
  2. User calls `POST /api/auth/logout`; the cookie is cleared.
- Acceptance criteria (Definition of Done):
  - [ ] AC-10.1 Given a logged-in user, when they call `GET /api/auth/me`, then it returns `200` with `id`, `name`, `email` and `homes` (an empty list before UC-11).
  - [ ] AC-10.2 Given a logged-in user, when they call `POST /api/auth/logout`, then the response is `204` and the cookie is cleared (`Max-Age=0`).
  - [ ] AC-10.3 Given the user logged out, when they call `GET /api/auth/me`, then the response is `401` "Not logged in".
- Edge cases:
  - UC-10-E1 (T22): Given no cookie, when `GET /api/auth/me` is called, then the response is `401` "Not logged in".
  - UC-10-E2: Given no cookie, when `POST /api/auth/logout` is called, then the response is still `204` (logging out twice is not an error).
  - UC-10-E3: Given the user is a member of two homes, when they call `/auth/me`, then both homes are listed with `id` and `name`.
- How to test by hand:
  1. `curl -b a.txt $BASE/auth/me`. Check the fields.
  2. `curl -i -b a.txt -c a.txt -X POST $BASE/auth/logout`. Expect `204` and `Max-Age=0`.
  3. `curl -i -b a.txt $BASE/auth/me`. Expect `401`.
  4. E2: repeat step 2. Expect `204`.
  5. E3: after UC-11, create a second home and call `/auth/me`.
- Not included: logging out other devices; a list of active sessions.

### UC-11: Create a home and list my homes
- Actor: Logged-in user
- Milestone: M1
- Preconditions: User A (`ali@example.com`) is logged in (`a.txt`).
- Main flow:
  1. User sends name, city, country and timezone to `POST /api/homes`.
  2. Backend creates the home and makes the user its first member.
  3. User lists their homes with `GET /api/homes` and reads one with `GET /api/homes/{home_id}`.
- Acceptance criteria (Definition of Done):
  - [ ] AC-11.1 Given valid fields (`"Ali's Home"`, `Lahore`, `Pakistan`, `Asia/Karachi`), when the user creates a home, then the response is `201` with the home `id`, the fields, and `ha_connected: false`.
  - [ ] AC-11.2 Given the home was created, when the user calls `GET /api/homes`, then it is in the list; and `home_members` has a row for this user and home.
  - [ ] AC-11.3 Given the home was created, when the user calls `GET /api/homes/{home_id}`, then it returns the same fields.
  - [ ] AC-11.4 Given the user edits the home with `PATCH /api/homes/{home_id}` (for example a new name), when they read it again, then the new name is shown and other fields are unchanged.
- Edge cases:
  - UC-11-E1: Given name, city, country or timezone is missing or only spaces, when creating a home, then the response is `422` naming the field.
  - UC-11-E2: Given an unknown timezone (`Mars/Base`), when creating a home, then the response is `422` "Unknown timezone".
  - UC-11-E3: Given a name longer than 100 characters, when creating a home, then the response is `422` with the limit.
  - UC-11-E4: Given the user already has a home called "Ali's Home", when they create another with the same name, then it is created with a different `id` (names do not need to be unique).
  - UC-11-E5: Given no cookie, when `POST /api/homes` is called, then the response is `401` and no home is created.
- How to test by hand:
  1. ```bash
     curl -i -b a.txt -X POST $BASE/homes -H 'Content-Type: application/json' \
       -d '{"name":"Ali'\''s Home","city":"Lahore","country":"Pakistan","timezone":"Asia/Karachi"}'
     ```
     Note the `id` (call it `$HOME_A`).
  2. `curl -b a.txt $BASE/homes` and `curl -b a.txt $BASE/homes/$HOME_A`.
  3. `sqlite3 data/app.db "select * from home_members;"`.
  4. `curl -b a.txt -X PATCH $BASE/homes/$HOME_A -H 'Content-Type: application/json' -d '{"name":"Ali Home"}'`, then read it.
  5. E1 to E5: send each bad body; send a request without `-b a.txt`.
- Not included: members API, delete home, home switcher (M2 and M3).

### UC-12: Connect a home to Home Assistant
- Actor: Home member
- Milestone: M1
- Preconditions: UC-02 done (long-lived token ready); UC-11 done (`$HOME_A`).
- Main flow:
  1. Member sends `ha_url` and `ha_token` with `PATCH /api/homes/{home_id}`.
  2. Backend connects to HA with them. If HA accepts, it encrypts the token, saves both and loads rooms and devices.
  3. Backend returns the home with `ha_connected: true` and a short summary (rooms and devices found).
- Acceptance criteria (Definition of Done):
  - [ ] AC-12.1 Given the right URL (`http://homeassistant:8123`) and token, when the member saves them, then the response is `200` with `ha_connected: true`, `ha_url`, `rooms: 3` and `devices: 11`.
  - [ ] AC-12.2 Given the home is connected, when any home route returns the home, then the response has no `ha_token` field and does not contain the token anywhere.
  - [ ] AC-12.3 Given the home is connected, when the developer reads `homes.ha_token_encrypted` in SQLite, then the value is not the token (it is Fernet-encrypted).
  - [ ] AC-12.4 Given the home is connected, when the developer searches the backend logs for the token, then it is not found.
  - [ ] AC-12.5 Given the backend restarts, when the member reads the devices (UC-15), then they load without entering the token again.
- Edge cases:
  - UC-12-E1: Given a wrong or deleted token, when the member saves it, then the response is `400` "Home Assistant rejected the token" and nothing is saved.
  - UC-12-E2: Given a URL where nothing answers (`http://homeassistant:9999`), when the member saves it, then within 10 seconds the response is `400` "Can't reach Home Assistant at http://homeassistant:9999" and nothing is saved.
  - UC-12-E3: Given a value that is not an `http` or `https` URL (`homeassistant`), when saving, then the response is `422` "Invalid URL".
  - UC-12-E4: Given a URL with a trailing slash (`http://homeassistant:8123/`), when saving, then it is accepted and stored without the slash.
  - UC-12-E5: Given only `ha_url` is sent without `ha_token` on a home that has no token yet, when saving, then the response is `422` "ha_url and ha_token are needed together".
  - UC-12-E6: Given the home is already connected, when the member saves a new valid token, then the new one replaces the old one and the connection keeps working.
  - UC-12-E7: Given `HA_TOKEN_KEY` in `.env` was changed after the token was saved, when the backend tries to use the token, then the member gets `409` "Saved Home Assistant token can't be read. Please enter it again." (no crash).
- How to test by hand:
  1. ```bash
     curl -i -b a.txt -X PATCH $BASE/homes/$HOME_A -H 'Content-Type: application/json' \
       -d '{"ha_url":"http://homeassistant:8123","ha_token":"<token from UC-02>"}'
     ```
     Expect `ha_connected: true`, 3 rooms, 11 devices, and no token in the body.
  2. `sqlite3 data/app.db "select ha_token_encrypted from homes;"`. Expect a long value starting with `gAAAA` that is not your token.
  3. `docker compose logs backend | grep -F "<first 20 characters of token>"`. Expect nothing.
  4. `docker compose restart backend`, then do UC-15 step 1.
  5. E1: send `"ha_token":"wrong"`. E2: send port 9999. E3: send `"ha_url":"homeassistant"`. E4: add a trailing slash. Check each response, and that `ha_connected` stays as it was.
  6. E7: change `HA_TOKEN_KEY`, restart the backend, call UC-13. Expect the `409` message. Restore the key.
- Not included: the home setup page (M3); OAuth login to HA (we use long-lived tokens).

### UC-13: Test the Home Assistant connection
- Actor: Home member
- Milestone: M1
- Preconditions: UC-12 done.
- Main flow:
  1. Member calls `POST /api/homes/{home_id}/test-connection`.
  2. Backend checks the saved URL and token against HA.
  3. Backend returns whether it worked and what it found.
- Acceptance criteria (Definition of Done):
  - [ ] AC-13.1 Given the home is connected and HA is running, when the member tests the connection, then the response is `200` with `ok: true`, `rooms: 3`, `devices: 11` and the HA version.
  - [ ] AC-13.2 Given HA is stopped, when the member tests the connection, then the response is `200` with `ok: false` and `error: "Can't reach Home Assistant"` within 10 seconds.
  - [ ] AC-13.3 Given HA is started again, when the member tests the connection, then it returns `ok: true` again without changing anything in the app.
- Edge cases:
  - UC-13-E1: Given the home has no HA connection yet, when the member tests it, then the response is `409` "Home is not connected to Home Assistant".
  - UC-13-E2: Given the token was deleted in HA, when the member tests the connection, then the response is `ok: false` with `error: "Home Assistant rejected the token"`.
  - UC-13-E3: Given a device is added in `devices.yaml` (UC-07), when the member tests the connection again, then `devices` is 12.
- How to test by hand:
  1. `curl -b a.txt -X POST $BASE/homes/$HOME_A/test-connection`.
  2. `docker compose stop homeassistant`; repeat. `docker compose start homeassistant`, wait for HA to load, repeat.
  3. E1: create a second home and test it.
  4. E2: delete the token in HA (profile > Security), test, then create a new token and connect again (UC-12).
- Not included: automatic health checks in the background (the HA client reconnects on its own; see UC-15-E3).

### UC-14: Only members can reach a home
- Actor: Logged-in user who is not a member (user B)
- Milestone: M1
- Preconditions: User A has `$HOME_A` (connected). User B (`sara@example.com`) has signed up and logged in (`b.txt`).
- Main flow:
  1. User B calls routes for `$HOME_A`.
  2. Backend checks membership and treats the home as not existing for B.
- Acceptance criteria (Definition of Done):
  - [ ] AC-14.1 Given B is not a member of `$HOME_A`, when B calls `GET`, `PATCH`, `test-connection` or `devices` for `$HOME_A`, then every response is `404` "Home not found" and nothing changes.
  - [ ] AC-14.2 Given B is not a member, when B calls `GET /api/homes`, then `$HOME_A` is not listed.
  - [ ] AC-14.3 Given a home ID that does not exist, when A calls it, then the response is the same `404` "Home not found" (B can't tell whether a home exists).
- Edge cases:
  - UC-14-E1: Given no cookie, when any home route is called, then the response is `401` "Not logged in" (not `404`).
  - UC-14-E2: Given A and B each have a home, when each lists homes, then each sees only their own.
  - UC-14-E3: Given B tries to change `$HOME_A`'s HA URL with `PATCH`, when the request fails with `404`, then `$HOME_A`'s URL and token are unchanged.
- How to test by hand:
  1. Sign up and log in as B (UC-08, UC-09 with `b.txt`).
  2. Run each of these with `-b b.txt`: `GET $BASE/homes/$HOME_A`, `PATCH` with a new name, `POST .../test-connection`, `GET .../devices`. Expect `404` each time.
  3. `curl -b b.txt $BASE/homes`. Expect `$HOME_A` missing.
  4. As A, `curl -b a.txt $BASE/homes/999999`. Expect `404`.
  5. E3: as A, read `$HOME_A` and check the name and URL did not change.
- Not included: adding B as a member (M2 members API); the WebSocket membership check (M3).

### UC-15: See rooms and devices from the app
- Actor: Home member
- Milestone: M1
- Preconditions: UC-12 done.
- Main flow:
  1. Member calls `GET /api/homes/{home_id}/devices`.
  2. Backend returns rooms from HA, each with its supported devices, current state and limits, from the HA client's cache.
  3. The cache stays current through HA's live `state_changed` and registry events.
- Acceptance criteria (Definition of Done):
  - [ ] AC-15.1 Given the home is connected, when the member reads devices, then the response lists 3 rooms (Living room, Bedroom, Kitchen) with 11 devices, each with `entity_id`, `name`, `type`, `state` and the room's aliases (Living room shows "lounge").
  - [ ] AC-15.2 Given the devices are listed, when the member checks the limits, then Living room AC shows 16 to 30 °C, Bedroom AC 18 to 28 °C, the kitchen light shows not dimmable, the ceiling fans show 5 speeds, and each sensor shows temperature and humidity.
  - [ ] AC-15.3 Given HA has entities that are not supported (for example `sun.sun`) or devices without a room, when the member reads devices, then those are not in the list.
  - [ ] AC-15.4 Given the member switches the kitchen light on in the HA UI, when they read devices again right after, then the kitchen light shows `on` (no backend restart).
  - [ ] AC-15.5 Given a device's room is changed in HA (for example the lamp moved to Bedroom), when the member reads devices again, then the device is listed under the new room within 10 seconds.
- Edge cases:
  - UC-15-E1: Given the home has no HA connection, when the member reads devices, then the response is `409` "Home is not connected to Home Assistant".
  - UC-15-E2: Given HA is stopped, when the member reads devices, then the response is `503` "Can't reach your home right now".
  - UC-15-E3: Given HA is started again, when the member reads devices after HA has loaded, then the list comes back without restarting the backend (automatic reconnect).
  - UC-15-E4: Given a device is offline (UC-06 fault), when the member reads devices, then that device is listed with `state: "unavailable"`.
  - UC-15-E5: Given a device is added or removed in `devices.yaml` (UC-07), when the member reads devices again, then it is added or removed within 10 seconds.
- How to test by hand:
  1. `curl -s -b a.txt $BASE/homes/$HOME_A/devices | python3 -m json.tool`. Check rooms, devices, limits and the "lounge" alias.
  2. Check that `sun.sun` and other non-device entities are missing.
  3. Toggle the kitchen light in HA; read devices again.
  4. In HA, move the living room lamp to Bedroom; read devices; move it back.
  5. E2, E3: `docker compose stop homeassistant`, read devices (`503`); `docker compose start homeassistant`, wait, read again.
  6. E4: set `offline` on the bedroom light (UC-06), read devices, set `normal`.
- Not included: live updates pushed to the browser (WebSocket `/ws`, M3); the dashboard page (M3).

### UC-16: Switch a device on or off from the app
- Actor: Home member
- Milestone: M1
- Preconditions: UC-12 done. No frontend yet, so the endpoint is tested with `curl` or Swagger (http://localhost:8000/docs). In M3 the dashboard uses the same endpoint for on/off buttons.
  - `POST /api/homes/{home_id}/devices/{entity_id}/turn_on`
  - `POST /api/homes/{home_id}/devices/{entity_id}/turn_off`
- Main flow:
  1. Member calls `turn_on` or `turn_off` for a device of their home.
  2. The backend checks membership and that the device belongs to this home and can be switched.
  3. The HA client calls the HA service over REST and waits up to `DEVICE_CONFIRM_TIMEOUT` (3 s) for a `state_changed` event with the new state.
  4. The response is `200` with one result: `device_id`, `status` (`ok`, `timeout` or `failed`), `new_state` (for example `{"state": "on"}`), `duration_ms`, and `error` when not `ok`. This is the same result format the M2 tools use.
- Acceptance criteria (Definition of Done):
  - [ ] AC-16.1 Given the kitchen light is off, when the member calls `turn_on` for `light.kitchen_light`, then the response has `status: "ok"` and `new_state.state: "on"`, and HA shows the light on.
  - [ ] AC-16.2 Given the bedroom AC is off, when the member calls `turn_on` and then `turn_off` for `climate.bedroom_ac`, then each response has `status: "ok"` and HA shows the AC on, then off.
  - [ ] AC-16.3 Given any `ok` result, when the member checks the timing, then the response arrives only after HA's state changed (never before), and `duration_ms` is under 3000.
  - [ ] AC-16.4 Given a command ran, when the developer reads the backend logs, then there is one log line with the user, home, entity, service, status and duration, and no token.
- Edge cases:
  - UC-16-E1: Given the kitchen light has the `ignore_commands` fault, when `turn_on` is called, then after about 3 seconds the response has `status: "timeout"` and the light stays off.
  - UC-16-E2: Given the bedroom light is offline by fault, when `turn_on` is called, then the response has `status: "failed"` and `error: "device offline"` at once (under 0.5 s) and no command is sent to HA.
  - UC-16-E3: Given the kitchen light is already on, when `turn_on` is called, then the response has `status: "ok"` at once (it does not wait 3 seconds for a change that will not happen).
  - UC-16-E4: Given an entity that does not exist in this home (`light.garage`), when it is called, then the response is `404` "Device not found" and nothing is sent to HA.
  - UC-16-E5: Given a sensor (`sensor.bedroom_sensor_temperature`), when `turn_on` is called, then the response is `422` "This device can't be switched" and nothing is sent to HA.
  - UC-16-E6: Given user B is not a member of `$HOME_A`, when B calls `turn_on` for a device of `$HOME_A`, then the response is `404` "Home not found" and the device does not change.
  - UC-16-E7: Given no cookie, when the endpoint is called, then the response is `401` "Not logged in".
  - UC-16-E8: Given HA is stopped, when the endpoint is called, then the response is `503` "Can't reach your home right now".
  - UC-16-E9: Given the home has no HA connection, when the endpoint is called, then the response is `409` "Home is not connected to Home Assistant".
- How to test by hand:
  1. `curl -s -b a.txt -X POST $BASE/homes/$HOME_A/devices/light.kitchen_light/turn_on`. Watch the light in HA.
  2. Same for `climate.bedroom_ac`, `turn_on` then `turn_off`.
  3. `docker compose logs backend | tail`. Check the log line.
  4. E1: set `ignore_commands` on the kitchen light (UC-06), call `turn_on` with `time curl ...`. Expect about 3 s and `timeout`. Set `normal`.
  5. E2: set `offline` on the bedroom light, call `turn_on`. Set `normal`.
  6. E3: call `turn_on` twice for the same light; the second one returns at once.
  7. E4, E5: call with `light.garage`, then with a sensor.
  8. E6, E7: call with `-b b.txt`, then with no cookie.
  9. E8: `docker compose stop homeassistant`, call, then `docker compose start homeassistant`.
  10. E9: call for the second, unconnected home from UC-13-E1.
  11. Swagger: open http://localhost:8000/docs after logging in through `/auth/login` there, and try `turn_on`.
- Not included: brightness, temperature, mode and speed (M2 tools); several devices at once (M2); dashboard buttons (M3, using this endpoint); control by text or voice (M2, M3).

### UC-17: Tool-calling spike
- Actor: Developer
- Milestone: M1
- Preconditions: `OPENAI_API_KEY` is set in `.env`. This is a throwaway learning script, not the agent.
- Main flow:
  1. Developer runs `docker compose exec backend python scripts/spike_tool_call.py "turn on the kitchen light"`.
  2. The script sends the text and one tool definition (`control_light` with a fixed list of two lights) to gpt-4o-mini.
  3. It prints the tool name and arguments the model chose, plus token counts. It changes no device.
- Acceptance criteria (Definition of Done):
  - [ ] AC-17.1 Given the text "turn on the kitchen light", when the script runs, then it prints tool `control_light` with arguments `{"entity_id": "light.kitchen_light", "action": "turn_on"}`.
  - [ ] AC-17.2 Given any run, when it finishes, then it prints input and output token counts and the time taken.
  - [ ] AC-17.3 Given any run, when the developer checks HA, then no device changed.
- Edge cases:
  - UC-17-E1: Given `OPENAI_API_KEY` is empty, when the script runs, then it stops with "OPENAI_API_KEY is not set" (no stack trace).
  - UC-17-E2: Given the text "hello", when the script runs, then it prints "No tool call" and the model's text reply.
  - UC-17-E3: Given the text "turn on the garage light" (not in the list), when the script runs, then it prints what the model did (a text reply or a call with one of the two listed lights). This is recorded as a finding for the M2 prompt, not a failure.
- How to test by hand:
  1. Run the script with the three texts above; compare output.
  2. Empty the key in `.env`, restart the backend, run again; restore the key.
- Not included: the real agent loop, generated tools and validation (M2).

---

## M2: AI assistant, text (2026-11-27)

M2 is still API only (the web app is M3). Extra conventions for M2 tests:

- Log in as user A (`a.txt`), with `$HOME_A` connected to HA (M1).
- Start a conversation and keep its ID in `$CONV` (UC-18). A helper to send one message:
  ```bash
  say() { curl -s -b a.txt -X POST $BASE/homes/$HOME_A/conversations/$CONV/messages \
    -H 'Content-Type: application/json' -d "{\"text\": \"$1\"}" | python3 -m json.tool; }
  say "turn on the kitchen light"
  ```
- The reply comes back as `{"turn_no", "reply", "results"}`. `results` lists one entry per device the assistant touched (`device_id`, `status`, `new_state`, `duration_ms`, `error`; the same format as the on/off endpoint in UC-16), so you can see what really happened.
- The LLM's wording changes from run to run. Check the **meaning** of the reply and the **device state in HA**, not the exact words.
- Before a scenario, reset devices to a known state with the on/off endpoint (UC-16) or the HA UI. A test scenario passes when its expected result from PRD section 9 is met.

### UC-18: Start, list and read conversations
- Actor: Home member
- Milestone: M2
- Preconditions: User A is logged in; `$HOME_A` is connected.
- Main flow:
  1. Member starts a conversation with `POST /api/homes/{home_id}/conversations`.
  2. Member lists their conversations with `GET /api/homes/{home_id}/conversations`.
  3. Member reads one with `GET /api/homes/{home_id}/conversations/{id}/messages`.
- Acceptance criteria (Definition of Done):
  - [ ] AC-18.1 Given a connected home, when the member starts a conversation, then the response is `201` with a conversation `id`, an empty `title` and `created_at`.
  - [ ] AC-18.2 Given the member sent a first message "turn on the kitchen light", when they list conversations, then this conversation has the title "turn on the kitchen light" (the first message, cut to 50 characters).
  - [ ] AC-18.3 Given the member has 3 conversations, when they list them, then they are shown newest first.
  - [ ] AC-18.4 Given a conversation with messages, when the member reads it, then it returns the user and assistant messages in order, with `turn_no`, `role`, `content` and `created_at` (tool messages are not shown to the user).
- Edge cases:
  - UC-18-E1: Given two members A and B of the same home, when each lists conversations, then each sees only their own conversations.
  - UC-18-E2: Given a conversation that is not the member's newest one in this home, when they send a message to it, then the response is `409` "This conversation is read-only. Start a new conversation." (past conversations are read-only).
  - UC-18-E3: Given a conversation ID from another home or another user, when the member reads it, then the response is `404` "Conversation not found".
  - UC-18-E4: Given a home with no conversations, when the member lists them, then the response is `200` with an empty list.
- How to test by hand:
  1. `curl -s -b a.txt -X POST $BASE/homes/$HOME_A/conversations`. Set `CONV=<id>`.
  2. `say "turn on the kitchen light"`; then `curl -s -b a.txt $BASE/homes/$HOME_A/conversations`. Check the title.
  3. Start two more conversations; list again. Check the order.
  4. `curl -s -b a.txt $BASE/homes/$HOME_A/conversations/$CONV/messages`.
  5. E2: send `say` to the first (old) conversation. Expect `409`.
  6. E1, E3: as B (after UC-30 makes B a member), list conversations; read A's conversation ID.
- Not included: renaming or deleting conversations; search; the conversation list page (M3).

### UC-19: Control one device by text
- Actor: Home member
- Milestone: M2
- Preconditions: UC-18 done (`$CONV`). Devices reset: everything off.
- Main flow:
  1. Member sends a command, for example "Turn on the living room main light".
  2. The backend builds the home snapshot and tool schemas from HA, and calls gpt-4o-mini.
  3. The model calls a tool (for example `control_light`); the tool layer validates it, calls HA and waits for HA to confirm the new state.
  4. The model writes a short reply based on the confirmed result.
- Acceptance criteria (Definition of Done):
  - [ ] AC-19.1 (T1) Given the living room main light is off, when the member says "Turn on the living room main light", then the light is on in HA and the reply says so.
  - [ ] AC-19.2 (T5) Given the living room AC is off, when the member says "Set the living room AC to 22", then the AC is on at 22 °C in HA.
  - [ ] AC-19.3 Given the bedroom ceiling fan is off, when the member says "Set the bedroom fan to speed 3", then HA shows the fan on at 60% (speed 3 of 5).
  - [ ] AC-19.4 Given the living room lamp is on, when the member says "Dim the lounge lamp to 40%", then HA shows the lamp at 40% (the "lounge" alias works).
  - [ ] AC-19.5 (real control) Given any successful command, when the `results` list is checked, then each `ok` entry has a `new_state` that matches HA, and the reply never says "done" for a device whose status is not `ok`.
- Edge cases:
  - UC-19-E1: Given an empty message or only spaces, when it is sent, then the response is `422` "Message can't be empty" and the LLM is not called.
  - UC-19-E2: Given a message longer than 1000 characters, when it is sent, then the response is `422` "Message is too long (max 1000 characters)".
  - UC-19-E3: Given the kitchen light (on/off only), when the member says "Dim the kitchen light to 50%", then nothing changes and the reply says this light can't be dimmed.
  - UC-19-E4: Given the living room AC, when the member says "Set the living room AC to dry mode with high fan", then HA shows mode dry and fan high, and the temperature is unchanged.
  - UC-19-E5: Given an off-topic message ("tell me a joke"), when it is sent, then no tool is called, no device changes, and the reply says it can help with the home's devices.
- How to test by hand:
  1. `say "Turn on the living room main light"`. Check HA and `results`.
  2. `say "Set the living room AC to 22"`; `say "Set the bedroom fan to speed 3"`; `say "Dim the lounge lamp to 40%"` (turn the lamp on first). Check HA after each.
  3. E1, E2: `say ""`; send a 1001-character text.
  4. E3 to E5: send each message; check HA did or did not change.
- Not included: voice (M3); several devices (UC-21).

### UC-20: Follow-ups and corrections
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works. Each numbered scenario starts in a new conversation.
- Main flow:
  1. Member gives a command naming a device.
  2. Member follows up without naming it again ("dim it", "make it warmer", "actually make it 20").
  3. The assistant uses the conversation history and the recently used devices to act on the same device.
- Acceptance criteria (Definition of Done):
  - [ ] AC-20.1 (T2) Given T1 was just done, when the member says "dim it to 30%", then the same light is at 30%.
  - [ ] AC-20.2 (T3) Given T2 was just done, when the member says "actually turn it off", then the same light is off.
  - [ ] AC-20.3 (T6) Given T5 was just done, when the member says "make it a bit warmer", then the living room AC is at 23 or 24 °C.
  - [ ] AC-20.4 (T23) Given "Set the living room AC to 22" was just done, when the member says "Actually, make it 20", then the same AC is at 20 °C and the assistant does not ask which AC.
  - [ ] AC-20.5 (T13) Given a new conversation, when the member asks "Is the lounge AC on?" and then "and the bedroom one?", then each reply gives the correct state of that AC.
- Edge cases:
  - UC-20-E1: Given a new conversation with no history, when the first message is "turn it off", then the assistant asks which device and nothing changes.
  - UC-20-E2: Given T1 was done in conversation 1, when the member starts conversation 2 and says "dim it", then the assistant asks which device (old context does not leak).
  - UC-20-E3: Given `HISTORY_TURNS=2` in `.env` and T1 was done 3 turns ago, when the member says "dim it", then the assistant asks which device (only whole recent turns are sent).
  - UC-20-E4: Given the member said "turn on the kitchen light and the bedroom light", when they then say "turn them off", then both lights are off.
- How to test by hand:
  1. New conversation: `say "Turn on the living room main light"`, `say "dim it to 30%"`, `say "actually turn it off"`. Check HA after each.
  2. New conversation: `say "Set the living room AC to 22"`, `say "make it a bit warmer"`. New conversation: T23.
  3. New conversation: T13.
  4. E1, E2, E4: as written.
  5. E3: set `HISTORY_TURNS=2`, restart the backend, do T1, two unrelated questions, then "dim it". Put the value back.
- Not included: memory across conversations (each conversation starts empty by design).

### UC-21: Several actions in one message
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works; kitchen light on, bedroom fan off.
- Main flow:
  1. Member gives two or more commands in one message.
  2. The model calls several tools in one response; the tools run at the same time.
  3. The reply reports each device's result.
- Acceptance criteria (Definition of Done):
  - [ ] AC-21.1 (T8) Given the kitchen light is on and the bedroom fan is off, when the member says "Turn off the kitchen light and set the bedroom fan to 3", then the kitchen light is off and the bedroom fan is on at speed 3.
  - [ ] AC-21.2 Given T8, when the `results` list is checked, then it has one entry per device, both `ok`.
  - [ ] AC-21.3 Given T8, when `tool_logs` is checked, then both calls belong to the same turn, and the turn's `device_ms` in `request_metrics` is close to the slower device, not the sum of both (they ran at the same time).
- Edge cases:
  - UC-21-E1: Given 3 devices in one message (the bulk limit is more than 3), when the member asks for them, then all 3 run without a confirmation question.
  - UC-21-E2: Given one valid and one out-of-range request ("turn on the kitchen light and set the bedroom AC to 35"), when it is sent, then the kitchen light turns on and the reply says the bedroom AC allows 18 to 28 °C (the valid part is not blocked).
- How to test by hand:
  1. Set the start states, `say "Turn off the kitchen light and set the bedroom fan to 3"`. Check HA and `results`.
  2. `sqlite3 data/app.db "select turn_no, tool_name, duration_ms from tool_logs order by id desc limit 5;"`.
  3. E1, E2: send each message; check HA.
- Not included: actions that depend on each other ("if the bedroom is hot, turn on the AC" is UC-24).

### UC-22: Status questions
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works.
- Main flow:
  1. Member asks about device states or room readings.
  2. The model calls `get_device_state`, `get_sensor_reading` or `list_devices`, which read the HA client's current data.
  3. The reply gives the real values. Nothing changes.
- Acceptance criteria (Definition of Done):
  - [ ] AC-22.1 (T12) Given the kitchen light and the bedroom AC are on and everything else is off, when the member asks "What's on right now?", then the reply names exactly those two devices.
  - [ ] AC-22.2 (T24) Given the bedroom AC is at 24 °C and the bedroom light is on, when the member asks "What is the bedroom AC temperature?" and then "Is the bedroom light on?", then the replies say 24 °C, then yes.
  - [ ] AC-22.3 Given the member asks "How hot is the bedroom?", when the reply comes, then it gives the bedroom sensor's current temperature (same value as in HA).
  - [ ] AC-22.4 Given any status question, when HA is checked afterwards, then no device changed and `tool_logs` shows only read tools for that turn.
- Edge cases:
  - UC-22-E1: Given the bedroom light is offline (fault), when the member asks "Is the bedroom light on?", then the reply says it is not responding (not "on" or "off").
  - UC-22-E2: Given everything is off, when the member asks "What's on right now?", then the reply says nothing is on.
  - UC-22-E3: Given the member asks about the kitchen temperature (the kitchen has no sensor), when the reply comes, then it says there is no temperature sensor in the kitchen (no made-up value).
- How to test by hand:
  1. Set the states in HA, then `say "What's on right now?"`.
  2. Set the bedroom AC to 24 °C and the light on; T24 in a new conversation.
  3. `say "How hot is the bedroom?"`; compare with HA.
  4. E1 to E3: set the fault or states, ask each question.
- Not included: history of past values ("what was the temperature this morning?").

### UC-23: Clarify an ambiguous request
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works.
- Main flow:
  1. Member asks for something that matches more than one device.
  2. The assistant asks which one, listing the options, and does nothing yet.
  3. Member answers; the assistant acts on the chosen device.
- Acceptance criteria (Definition of Done):
  - [ ] AC-23.1 (T4) Given the home has 4 lights, when the member says "Turn on the light", then the reply asks which light and lists them, and no light changes.
  - [ ] AC-23.2 Given AC-23.1, when the member answers "the kitchen one", then only the kitchen light turns on.
  - [ ] AC-23.3 Given the home has 2 ACs, when the member says "Set the AC to 22", then the reply asks which AC (living room or bedroom), and no AC changes.
- Edge cases:
  - UC-23-E1: Given the bedroom has one light, when the member says "turn on the light in the bedroom", then it acts directly without asking.
  - UC-23-E2: Given the assistant asked "which light?", when the member answers something unrelated ("what time is it?"), then no light changes.
- How to test by hand:
  1. New conversation: `say "Turn on the light"`. Check that nothing changed in HA. `say "the kitchen one"`.
  2. New conversation: `say "Set the AC to 22"`.
  3. E1, E2: as written.
- Not included: guessing the user's usual choice.

### UC-24: Implicit requests
- Actor: Home member
- Milestone: M2
- Preconditions: UC-22 works; bedroom AC off; bedroom sensor above 28 °C.
- Main flow:
  1. Member describes a feeling, not a command ("It's really hot in the bedroom").
  2. The assistant reads the bedroom sensor, then suggests or takes a sensible action.
- Acceptance criteria (Definition of Done):
  - [ ] AC-24.1 (T14) Given the bedroom is above 28 °C and the AC is off, when the member says "It's really hot in the bedroom", then `tool_logs` shows a bedroom sensor read, and the reply either offers to turn on the bedroom AC or turns it on (cool, within 18 to 28 °C) and says so.
  - [ ] AC-24.2 Given the assistant offered to cool the room, when the member says "yes", then the bedroom AC turns on in cool mode.
- Edge cases:
  - UC-24-E1: Given the bedroom is already 22 °C with the AC on, when the member says "It's hot in the bedroom", then the reply gives the current temperature and suggests a lower set point or the fan, without changing anything.
  - UC-24-E2: Given the member says "It's dark in the kitchen", when the reply comes, then it turns on or offers to turn on the kitchen light.
- How to test by hand:
  1. Let the bedroom warm up (AC off, UC-05) or check it is above 28 °C. `say "It's really hot in the bedroom"`. Check `tool_logs` and HA.
  2. If it offered, `say "yes"`.
  3. E1, E2: as written.
- Not included: automatic actions without a user message (automations are out of scope).

### UC-25: Out-of-range values
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works.
- Main flow:
  1. Member asks for a value outside a device's limits.
  2. The tool layer returns `invalid` with the allowed range (even if the model tried).
  3. The reply states the range and offers the nearest valid value. Nothing changes.
- Acceptance criteria (Definition of Done):
  - [ ] AC-25.1 (T7) Given the bedroom AC allows 18 to 28 °C, when the member says "Set the bedroom AC to 16", then nothing changes and the reply says the range is 18 to 28 °C and offers 18.
  - [ ] AC-25.2 Given the living room AC allows 16 to 30 °C, when the member says "Set the living room AC to 16", then it is set to 16 °C (the limits come from each device).
  - [ ] AC-25.3 Given T7, when the member answers "ok, 18 then", then the bedroom AC is at 18 °C.
- Edge cases:
  - UC-25-E1: Given a fan with 5 speeds, when the member says "Set the bedroom fan to speed 7", then nothing changes and the reply says speeds are 1 to 5.
  - UC-25-E2: Given the bedroom AC has modes cool and auto only, when the member says "Put the bedroom AC in dry mode", then nothing changes and the reply lists cool and auto.
  - UC-25-E3: Given a brightness of 0% or 150% is asked, when it is sent, then nothing changes and the reply says brightness is 1 to 100% (0% means "turn off" only if the user says off).
- How to test by hand:
  1. `say "Set the bedroom AC to 16"`; check HA did not change; `say "ok, 18 then"`.
  2. `say "Set the living room AC to 16"`.
  3. E1 to E3: send each; check HA and the `results` entry `status: "invalid"`.
- Not included: changing a device's limits from the app (they come from HA and `devices.yaml`).

### UC-26: Unknown device
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works.
- Main flow:
  1. Member asks for a device that does not exist in this home.
  2. The assistant says it does not exist and lists what can be controlled. It never invents a device.
- Acceptance criteria (Definition of Done):
  - [ ] AC-26.1 (T11) Given no garage heater exists, when the member says "Turn on the garage heater", then nothing changes and the reply says there is no such device and lists the controllable device types or rooms.
  - [ ] AC-26.2 Given a tool call with an entity ID not in this home reaches the tool layer, when it is validated, then the result is `invalid` "unknown device" and HA receives no command (checked by a unit test, because the strict schema stops the model from sending it).
- Edge cases:
  - UC-26-E1: Given a room that does not exist ("Turn on the garage light"), when it is sent, then the reply says there is no garage and lists the rooms.
  - UC-26-E2: Given a device that was removed from `devices.yaml` a minute ago, when the member asks for it, then the reply says it does not exist (the snapshot is fresh).
- How to test by hand:
  1. `say "Turn on the garage heater"`; check HA.
  2. E1: `say "Turn on the garage light"`.
  3. E2: remove the living room lamp from `devices.yaml`, wait 10 seconds, `say "turn on the living room lamp"`. Put it back.
  4. AC-26.2: `cd backend && pytest -k unknown_device`.
- Not included: suggesting devices to buy.

### UC-27: Confirm big actions first
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works; several devices on.
- Main flow:
  1. Member asks for an action on more than 3 devices ("Turn off everything").
  2. The tool layer returns `needs_confirmation` with the device count; nothing runs.
  3. The assistant asks for confirmation, stating the number of devices.
  4. Member says "yes"; the action runs.
- Acceptance criteria (Definition of Done):
  - [ ] AC-27.1 (T9) Given several devices are on, when the member says "Turn off everything", then nothing changes and the reply asks to confirm, with the number of devices.
  - [ ] AC-27.2 (T10) Given T9, when the member says "yes", then all lights, ACs and fans are off in HA.
  - [ ] AC-27.3 Given T9, when `results` is checked, then the entries have `status: "needs_confirmation"` and `tool_logs` shows no HA command for that turn.
- Edge cases:
  - UC-27-E1: Given T9, when the member says "no" (or anything that is not a yes), then nothing changes and the next big action asks again.
  - UC-27-E2: Given T9, when the member says "yes" 2 turns later (not in the next turn), then the action asks for confirmation again (confirmation is valid only in the next turn).
  - UC-27-E3: Given exactly 3 devices are asked for, when it is sent, then they run without confirmation (`BULK_CONFIRM_THRESHOLD` = 3 means "more than 3").
  - UC-27-E4: Given "Turn off all the lights" (4 lights), when it is sent, then confirmation is asked for 4 devices.
- How to test by hand:
  1. Turn on 5 devices. `say "Turn off everything"`; check HA. `say "yes"`; check HA.
  2. Repeat with "no"; repeat with an unrelated message before "yes".
  3. E3, E4: as written.
- Not included: undo ("turn everything back on" is a new request).

### UC-28: Offline devices, timeouts and partial failures
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works; faults from UC-06.
- Main flow:
  1. A device is offline or does not answer.
  2. The tool returns `failed` (offline, at once) or `timeout` (after 3 s) for that device; other devices are not affected.
  3. The reply says clearly which devices worked and which did not.
- Acceptance criteria (Definition of Done):
  - [ ] AC-28.1 (T15) Given the bedroom fan is offline, when the member says "Turn on the bedroom fan", then the reply says the fan isn't responding, and the result is `failed` "device offline" in under 0.5 s of device time.
  - [ ] AC-28.2 (T16) Given the bedroom fan is offline and the kitchen light is off, when the member says "Turn on the kitchen light and the bedroom fan", then the kitchen light is on and the reply says the bedroom fan failed.
  - [ ] AC-28.3 Given the kitchen light has `ignore_commands`, when the member says "Turn on the kitchen light", then after about 3 seconds the result is `timeout` and the reply says the light did not confirm (never "done").
- Edge cases:
  - UC-28-E1: Given the fan comes back online (`normal`), when the member asks again, then it works.
  - UC-28-E2: Given the bedroom fan is offline, when the member asks "What's on?", then the fan is reported as not responding.
- How to test by hand:
  1. Set `offline` on `bedroom_ceiling_fan`. T15, then T16. Check HA and `results`.
  2. Set `ignore_commands` on `kitchen_light`, `say "Turn on the kitchen light"`.
  3. Set both back to `normal`; repeat E1, E2.
- Not included: automatic retries of a failed device.

### UC-29: OpenAI or Home Assistant unavailable
- Actor: Home member
- Milestone: M2
- Preconditions: UC-19 works.
- Main flow:
  1. OpenAI or HA can't be reached, or the agent needs too many rounds.
  2. The backend stops safely and returns a clear message. No device is changed by a half-finished turn.
- Acceptance criteria (Definition of Done):
  - [ ] AC-29.1 Given HA is stopped, when the member sends a command, then the response is `503` "Can't reach your home right now", OpenAI is not called, and nothing changes.
  - [ ] AC-29.2 Given an invalid `OPENAI_API_KEY`, when the member sends a command, then after 2 retries the reply is "The assistant is not available right now. Please try again." and no device changes.
  - [ ] AC-29.3 Given `MAX_TOOL_ROUNDS=1` in `.env`, when the member sends a request that needs a read and then an action ("It's really hot in the bedroom, do something"), then the reply is "Sorry, I couldn't complete that. Please try again." and the event is logged.
- Edge cases:
  - UC-29-E1: Given OpenAI failed on a turn, when the member reads the conversation, then the user message and the error reply are both stored, and the next message works normally.
  - UC-29-E2: Given the network to OpenAI is slow, when no answer comes within `OPENAI_TIMEOUT` (default 20 s), then it counts as a failure (retry, then the error reply).
- How to test by hand:
  1. `docker compose stop homeassistant`; send a command. Start HA again.
  2. Put a wrong key in `.env`, restart the backend, send a command. Restore the key.
  3. Set `MAX_TOOL_ROUNDS=1`, restart, send the request. Restore the value.
  4. E1: read the conversation after step 2.
- Not included: switching to another LLM provider when OpenAI is down.

### UC-30: Add and remove members (Should)
- Actor: Home member
- Milestone: M2
- Preconditions: User A is a member of `$HOME_A`; user B has an account (not a member).
- Main flow:
  1. A adds B by email: `POST /api/homes/{home_id}/members`.
  2. B now sees and controls the home.
  3. A member removes a member: `DELETE /api/homes/{home_id}/members/{user_id}`.
- Acceptance criteria (Definition of Done):
  - [ ] AC-30.1 Given A is a member, when A adds `sara@example.com`, then the response is `201` and `GET .../members` lists A and B with `name`, `email` and `joined_at`.
  - [ ] AC-30.2 (T20) Given B was added, when B logs in and calls `GET /api/auth/me`, then `$HOME_A` is in B's homes and B can read devices and control them by text.
  - [ ] AC-30.3 Given B is a member, when A removes B, then the response is `204` and B gets `404` "Home not found" on the home's routes right away.
- Edge cases:
  - UC-30-E1: Given an email with no account, when A adds it, then the response is `404` "No account with this email".
  - UC-30-E2: Given B is already a member, when A adds B again, then the response is `409` "Already a member".
  - UC-30-E3: Given B is a member, when B removes themself, then B leaves the home (allowed).
  - UC-30-E4: Given A is the only member, when A tries to remove themself, then the response is `409` "A home needs at least one member. Delete the home instead."
  - UC-30-E5: Given B is not a member, when B tries to add a member to `$HOME_A`, then the response is `404` "Home not found".
- How to test by hand:
  1. ```bash
     curl -s -b a.txt -X POST $BASE/homes/$HOME_A/members -H 'Content-Type: application/json' -d '{"email":"sara@example.com"}'
     curl -s -b a.txt $BASE/homes/$HOME_A/members
     ```
  2. As B: `curl -s -b b.txt $BASE/auth/me`; read devices; start a conversation and send "turn on the kitchen light".
  3. As A: `curl -i -b a.txt -X DELETE $BASE/homes/$HOME_A/members/<B id>`; as B, read the home.
  4. E1 to E5: as written.
- Not included: invitations by email link; roles (all members are equal).

### UC-31: Delete a home (Should)
- Actor: Home member
- Milestone: M2
- Preconditions: User A is a member of a home with conversations.
- Main flow:
  1. A member calls `DELETE /api/homes/{home_id}`.
  2. The home, its members and its conversations are deleted; the backend closes that home's HA connection.
- Acceptance criteria (Definition of Done):
  - [ ] AC-31.1 Given a home with members and conversations, when a member deletes it, then the response is `204` and the home is gone from every member's `GET /api/homes`.
  - [ ] AC-31.2 Given the home was deleted, when the developer checks SQLite, then its `home_members`, `conversations`, `messages`, `tool_logs` and `request_metrics` rows are gone.
  - [ ] AC-31.3 Given the home was deleted, when the developer checks HA, then the devices are unchanged (deleting a home in our app never touches HA).
- Edge cases:
  - UC-31-E1: Given a non-member, when they try to delete the home, then the response is `404` "Home not found" and nothing is deleted.
  - UC-31-E2: Given the home was deleted, when a member calls any route for it, then the response is `404` "Home not found".
- How to test by hand:
  1. Create a test home, connect it, send one message. `curl -i -b a.txt -X DELETE $BASE/homes/<id>`.
  2. `sqlite3 data/app.db "select count(*) from conversations where home_id=<id>;"`. Expect 0.
  3. E1: try as B first.
- Not included: undo or a recycle bin.

### UC-32: Only members can use the assistant and tools
- Actor: Logged-in user who is not a member (user B)
- Milestone: M2
- Preconditions: B is not a member of `$HOME_A`.
- Main flow:
  1. B tries to use `$HOME_A` through any route.
  2. Every route and the tool layer reject it.
- Acceptance criteria (Definition of Done):
  - [ ] AC-32.1 (T19) Given B is not a member, when B tries to start a conversation, send a message, read members or read conversations of `$HOME_A`, then every response is `404` and no device changes.
  - [ ] AC-32.2 (T19) Given B has their own home, when a tool call for B's home names a device of `$HOME_A`, then the result is `invalid` "unknown device" and nothing changes (unit test).
  - [ ] AC-32.3 Given B was a member and is removed in the middle of a conversation, when B sends the next message, then the response is `404` and no tool runs.
- Edge cases:
  - UC-32-E1: Given no cookie, when any M2 route is called, then the response is `401` "Not logged in".
  - UC-32-E2: Given B has their own home connected to the same HA, when B asks "turn on the kitchen light" in B's home, then it works only through B's home (each home has its own connection).
- How to test by hand:
  1. As B, call each `$HOME_A` route from AC-32.1.
  2. AC-32.2: `cd backend && pytest -k other_home`.
  3. AC-32.3: add B, start a conversation as B, remove B, send a message as B.
- Not included: the WebSocket check (M3).

### UC-33: Tool, token and latency logs
- Actor: Developer
- Milestone: M2
- Preconditions: Some messages were sent.
- Main flow:
  1. Every tool call is stored in `tool_logs`.
  2. Every turn stores tokens and timings in `request_metrics`.
  3. JSON log lines go to stdout.
- Acceptance criteria (Definition of Done):
  - [ ] AC-33.1 Given T8 was sent, when the developer reads `tool_logs`, then there are 2 rows with `tool_name`, `arguments_json`, `result_json` and `duration_ms`, linked to the conversation and `turn_no`.
  - [ ] AC-33.2 Given any text turn, when the developer reads `request_metrics`, then it has `input_mode: "text"`, `llm_ms`, `device_ms`, `total_ms`, `input_tokens`, `output_tokens` and `model: "gpt-4o-mini"`.
  - [ ] AC-33.3 Given any turn, when the developer reads `docker compose logs backend`, then each line is JSON with request ID, user ID, home ID, event and duration.
  - [ ] AC-33.4 Given all logs and tables, when the developer searches them, then no password, hash, JWT, API key or HA token appears.
- Edge cases:
  - UC-33-E1: Given a status question (no device command), when `request_metrics` is read, then `device_ms` is 0 or empty.
  - UC-33-E2: Given OpenAI failed (UC-29), when the logs are read, then the failure and retries are logged, with no API key.
- How to test by hand:
  1. `sqlite3 data/app.db "select * from tool_logs order by id desc limit 5;"`.
  2. `sqlite3 data/app.db "select * from request_metrics order by id desc limit 5;"`.
  3. `docker compose logs backend | tail -20`.
  4. `docker compose logs backend | grep -iE "sk-|argon2|eyJ"`. Expect nothing (no key, hash or JWT).
- Not included: a log viewer page; statistics (M4, UC-48).

### UC-34: A new device works with no app change
- Actor: Developer, then home member
- Milestone: M2
- Preconditions: UC-07 works; UC-19 works.
- Main flow:
  1. Developer adds a "Bedroom lamp" (dimmable light) to `devices.yaml`.
  2. The device appears in HA, then in the snapshot and tool schemas on the next request.
  3. Member controls it by text.
- Acceptance criteria (Definition of Done):
  - [ ] AC-34.1 (T18) Given the lamp entry was saved 10 seconds ago, when the member says "Turn on the bedroom lamp", then it turns on in HA, with no restart and no code change.
  - [ ] AC-34.2 Given the lamp exists, when the member says "Turn on the light in the bedroom", then the assistant now asks which one (bedroom light or bedroom lamp).
- Edge cases:
  - UC-34-E1: Given the lamp is removed again, when the member asks for it, then the reply says it does not exist.
- How to test by hand:
  1. Add the entry, wait 10 seconds, `say "Turn on the bedroom lamp"`.
  2. `say "Turn on the light in the bedroom"` in a new conversation.
  3. Remove the entry, wait, ask again.
- Not included: devices added through HA integrations other than MQTT (they work the same way but are not tested).

### UC-35: Evaluation script
- Actor: Developer
- Milestone: M2
- Preconditions: Demo data loaded with `scripts/load_demo_data.py`; stack running; `OPENAI_API_KEY` set.
- Main flow:
  1. Developer runs `docker compose exec backend python tests/run_eval.py`.
  2. For each scenario, the script resets the device states, sends the conversation through the text API, and checks the final states in HA and the reply.
  3. It prints a pass or fail table and saves the results.
- Acceptance criteria (Definition of Done):
  - [ ] AC-35.1 Given the stack is ready, when the script runs, then it runs T1 to T16 and T18 to T24 and prints one line per scenario (ID, pass or fail, reason if failed), then the pass rate.
  - [ ] AC-35.2 Given a run finished, when the developer opens `data/eval/<date-time>.json`, then it has each scenario's messages, replies, tool calls, final states, tokens and timings.
  - [ ] AC-35.3 Given `--only T7`, when the script runs, then only T7 runs.
  - [ ] AC-35.4 Given the script finished, when the developer checks HA and `devices.yaml`, then devices are back to their start states, faults are `normal`, and any device added for T18 is removed.
- Edge cases:
  - UC-35-E1: Given HA is not running, when the script starts, then it stops at once with "Home Assistant is not reachable" (no scenario counted as failed).
  - UC-35-E2: Given `--repeat 3`, when the script runs, then each scenario runs 3 times and the pass rate counts every run (shows how stable the model is).
  - UC-35-E3: Given the demo user does not exist, when the script starts, then it says to run `scripts/load_demo_data.py` first.
- How to test by hand:
  1. `docker compose exec backend python scripts/load_demo_data.py`, then the eval command.
  2. Open the JSON file.
  3. `... run_eval.py --only T7`; then `--repeat 3 --only T4`.
  4. E1: stop HA and run it.
- Not included: T17 voice (added in M3, UC-42); running in CI.

---

## M3: Full demo, text and voice (2026-12-04)

From M3 the user works in the web app at http://localhost:5173. Manual tests use Chrome on desktop, Chrome device mode for phone and tablet sizes, and Safari on macOS once per use case.

### UC-36: Sign-up, login and logout pages
- Actor: New or registered user
- Milestone: M3
- Preconditions: Backend auth from M1 works.
- Main flow:
  1. A visitor opens the app and sees the login page, with a link to sign up.
  2. After sign-up or login, the user goes to their home (or the home switcher).
  3. The user logs out from the menu and returns to the login page.
- Acceptance criteria (Definition of Done):
  - [ ] AC-36.1 Given a visitor who is not logged in, when they open any app page, then they are sent to the login page.
  - [ ] AC-36.2 Given the sign-up form is filled in correctly, when the visitor submits it, then they are logged in and see the "Create your first home" page.
  - [ ] AC-36.3 Given a registered user, when they log in, then they go to their home (one home) or the home switcher (several homes).
  - [ ] AC-36.4 Given a logged-in user, when they click "Log out", then they see the login page and the back button does not show app pages.
- Edge cases:
  - UC-36-E1: Given an empty email or password, when the form is submitted, then the message "Email is required" or "Password is required" shows under that field and no request is sent.
  - UC-36-E2: Given a wrong password, when the user logs in, then "Wrong email or password" shows above the form and the password field is cleared.
  - UC-36-E3: Given the API returns `429`, when the user logs in, then "Too many login attempts. Try again later." shows and the button is disabled for 1 minute.
  - UC-36-E4: Given the email is already registered, when signing up, then "Email already registered" shows under the email field with a link to log in.
  - UC-36-E5: Given the backend is down, when the form is submitted, then "Can't reach the server. Check your connection." shows and the form keeps its values.
  - UC-36-E6: Given the form is being sent, when the user clicks the button again, then no second request is sent (the button shows a spinner and is disabled).
- How to test by hand:
  1. Open http://localhost:5173/ in a private window. Expect the login page.
  2. Sign up a new user; check the next page.
  3. Log out; log in; check where you land. Press the browser back button after logout.
  4. E1 to E6: as written (E5: `docker compose stop backend`).
- Not included: password reset, "remember me" (out of scope).

### UC-37: Home switcher (Should)
- Actor: Logged-in user
- Milestone: M3
- Preconditions: User is a member of one or more homes.
- Main flow:
  1. A user with one home goes straight into it.
  2. A user with several homes sees the switcher and picks one.
  3. From inside a home, the user can switch home from the header.
- Acceptance criteria (Definition of Done):
  - [ ] AC-37.1 Given the user has exactly one home, when they log in, then that home's assistant page opens directly.
  - [ ] AC-37.2 Given the user has 2 homes, when they log in, then the switcher lists both by name and city, and only their own homes.
  - [ ] AC-37.3 Given the user is in home 1 with a conversation, when they switch to home 2, then home 2's dashboard loads and a new, empty conversation starts.
- Edge cases:
  - UC-37-E1: Given the user has no homes, when they log in, then they see "Create your first home".
  - UC-37-E2: Given the user was removed from a home in another tab, when they open that home, then they see "You no longer have access to this home" and go back to the switcher.
- How to test by hand:
  1. Log in as a user with one home, then as one with two.
  2. Switch home from the header; check the conversation is new.
  3. E2: remove the user with `curl` as another member, then click the home.
- Not included: home pictures or ordering.

### UC-38: Home settings page
- Actor: Home member
- Milestone: M3
- Preconditions: UC-36 done.
- Main flow:
  1. Member creates a home or opens its settings: name, city, country, timezone.
  2. Member enters the HA URL and token, clicks "Test connection", then saves.
  3. Member adds or removes members, or deletes the home.
- Acceptance criteria (Definition of Done):
  - [ ] AC-38.1 Given the create-home form is filled in, when the member saves, then the home is created and the HA connection step opens.
  - [ ] AC-38.2 Given a valid HA URL and token, when the member clicks "Test connection", then "Connected: 3 rooms, 11 devices" shows; after saving, the token field shows "Token saved" and never the token.
  - [ ] AC-38.3 Given the members section, when the member adds an existing account's email, then it appears in the list; when they click "Remove" and confirm, it disappears.
  - [ ] AC-38.4 Given the member clicks "Delete home", when they confirm in the dialog, then the home is deleted and they go to the switcher (or "Create your first home").
- Edge cases:
  - UC-38-E1: Given a wrong token, when the member clicks "Test connection", then "Home Assistant rejected the token" shows next to the field and nothing is saved.
  - UC-38-E2: Given an unknown timezone is typed, when saving, then "Choose a timezone from the list" shows (the field is a searchable list).
  - UC-38-E3: Given an unknown email is added as member, when it is submitted, then "No account with this email" shows under the field.
  - UC-38-E4: Given the member clicks "Delete home" and then "Cancel", when the dialog closes, then nothing is deleted.
  - UC-38-E5: Given the settings page was opened from the switcher or from the assistant page, when the member clicks back, then they return to the page they came from.
- How to test by hand:
  1. Create a home in the UI; connect HA with your token; test and save.
  2. Reload; check the token is not shown.
  3. Add and remove B; delete a test home (cancel first, then confirm).
  4. E1 to E5: as written.
- Not included: room management (Could, M4).

### UC-39: Chat panel
- Actor: Home member
- Milestone: M3
- Preconditions: M2 works; member is on the assistant page.
- Main flow:
  1. Member types a message and presses Enter or Send.
  2. The message shows at once; a "Thinking..." status shows until the reply arrives.
  3. The reply shows, with each device result marked (for example a cross for a failed device).
  4. Member starts a new conversation, or opens a past one (read-only).
- Acceptance criteria (Definition of Done):
  - [ ] AC-39.1 Given the kitchen light is off, when the member types "turn on the kitchen light" and presses Enter, then the message shows, "Thinking..." shows, then the reply shows and the light is on in HA.
  - [ ] AC-39.2 Given a reply with a failed device (T16), when it shows, then the failed device is marked as failed under the reply.
  - [ ] AC-39.3 Given the member clicks "New conversation", when it opens, then the chat is empty and the old conversation is at the top of the conversation list.
  - [ ] AC-39.4 Given the member opens a past conversation, when it loads, then its messages show and the text box is replaced by "This conversation is read-only" with a "New conversation" button.
- Edge cases:
  - UC-39-E1: Given the text box is empty, when the member presses Enter, then nothing is sent (Send is disabled).
  - UC-39-E2: Given a reply is pending, when the member tries to send another message, then Send stays disabled until the reply arrives.
  - UC-39-E3: Given the backend returns an error (for example HA down), when it arrives, then the error message shows in the chat in a different style, and the typed text is not lost.
  - UC-39-E4: Given more than 1000 characters are typed, when the member types more, then a counter shows "1000/1000" and Send is disabled above the limit.
  - UC-39-E5: Given a long conversation, when a new reply arrives, then the chat scrolls to the newest message.
- How to test by hand:
  1. Send T1, T8 and T16 (fan offline) in the UI; watch HA.
  2. Click "New conversation"; open the old one from the list.
  3. E1 to E5: as written (E3: stop HA, send a command).
- Not included: editing or deleting messages; streaming replies word by word.

### UC-40: Live dashboard
- Actor: Home member
- Milestone: M3
- Preconditions: Member is on the assistant page; WebSocket `/ws/homes/{home_id}` works.
- Main flow:
  1. The dashboard shows a card per device, grouped by room, with state and main values.
  2. Any state change (from the assistant, the HA UI or the simulator) updates the card within about 1 second.
  3. Each light, AC and fan card has an on/off button (UC-16 endpoint).
- Acceptance criteria (Definition of Done):
  - [ ] AC-40.1 Given the home is connected, when the dashboard loads, then it shows Living room, Bedroom and Kitchen with their 11 devices, and AC cards show set point and mode, fan cards show speed, sensor cards show temperature and humidity.
  - [ ] AC-40.2 Given the dashboard is open, when the kitchen light is switched in the HA UI, then the kitchen card updates within 1 second without a page reload.
  - [ ] AC-40.3 Given the dashboard is open, when the member clicks the kitchen light's on/off button, then the button shows a spinner until HA confirms, then the card shows the new state.
  - [ ] AC-40.4 Given a device is added in `devices.yaml`, when HA adds it, then its card appears within 10 seconds without a reload.
- Edge cases:
  - UC-40-E1: Given a device is offline, when the dashboard shows it, then its card is greyed out with "Not responding" and its button is disabled.
  - UC-40-E2: Given the on/off button result is `timeout`, when it returns, then the card shows its real state and a short message "Device didn't respond".
  - UC-40-E3: Given the backend restarts, when the WebSocket drops, then the dashboard shows "Reconnecting..." and reconnects on its own, then reloads the states.
  - UC-40-E4: Given the room temperature drifts (UC-05), when the sensor changes, then the sensor card updates without a reload.
- How to test by hand:
  1. Open the assistant page and HA side by side; toggle devices in HA.
  2. Click on/off buttons on the dashboard; send a chat command; watch the cards.
  3. E1 to E4: set a fault; set `ignore_commands` and click; `docker compose restart backend`; turn an AC on and watch its room sensor.
- Not included: brightness, temperature, mode and speed controls on the dashboard (UC-46, Should).

### UC-41: WebSocket access control
- Actor: Logged-in user who is not a member
- Milestone: M3
- Preconditions: UC-40 works.
- Main flow:
  1. A browser connects to `/ws/homes/{home_id}`.
  2. The backend checks the cookie and membership on connect.
- Acceptance criteria (Definition of Done):
  - [ ] AC-41.1 Given no cookie, when a client connects to `/ws/homes/$HOME_A`, then the connection is closed with code 4401 and no events are sent.
  - [ ] AC-41.2 Given B is not a member, when B connects to `/ws/homes/$HOME_A`, then it is closed with code 4404.
  - [ ] AC-41.3 Given B is connected as a member and is then removed, when the next event happens, then B's connection is closed with code 4404.
- Edge cases:
  - UC-41-E1: Given two members are connected, when a device changes, then both get the event.
- How to test by hand:
  1. Open the browser console on another page and run `new WebSocket("ws://localhost:5173/ws/homes/<id>")` while logged out, then as B; watch the close code.
  2. AC-41.3: connect as B, remove B with `curl`, toggle a device.
  3. Automated: `cd backend && pytest -k websocket`.
- Not included: chat over WebSocket (chat uses HTTP).

### UC-42: Push-to-talk voice input
- Actor: Home member
- Milestone: M3
- Preconditions: UC-39 works; the browser allows the microphone (localhost or HTTPS).
- Main flow:
  1. Member holds the microphone button (mouse or touch) and speaks.
  2. On release, the audio is uploaded to `/voice`; faster-whisper transcribes it.
  3. The transcript shows as the user's message; the rest works like text.
- Acceptance criteria (Definition of Done):
  - [ ] AC-42.1 (T17) Given the living room main light is off, when the member holds the button and says "Turn on the living room main light", then the transcript shows and the light turns on.
  - [ ] AC-42.2 (T17) Given the T8 start states, when the member speaks T8, then the results match the text version.
  - [ ] AC-42.3 Given the member is holding the button, when they look at it, then it shows a recording state (colour and timer) until released.
  - [ ] AC-42.4 Given `tests/audio/t1.wav` and `t8.wav`, when `run_eval.py --only T17` runs, then T17 passes through the voice endpoint.
- Edge cases:
  - UC-42-E1: Given the microphone permission is denied, when the member presses the button, then "Microphone access is blocked. Allow it in your browser settings." shows.
  - UC-42-E2: Given the member releases in under 0.5 seconds or says nothing, when the audio is processed, then "I didn't catch that. Please try again." shows and the LLM is not called.
  - UC-42-E3: Given the member holds for more than 30 seconds, when 30 seconds pass, then recording stops and is sent automatically.
  - UC-42-E4: Given a file that is not audio is uploaded to `/voice`, when the backend checks it, then the response is `415` "Unsupported audio format".
  - UC-42-E5: Given a phone-sized screen, when the member presses and holds with a finger, then recording works and the page does not scroll or select text.
- How to test by hand:
  1. Hold the button, say T1; check the transcript and HA. Then T8.
  2. E1: block the mic in site settings and press. E2: tap quickly. E3: hold for 31 seconds.
  3. E4: `curl -b a.txt -F "audio=@README.md" $BASE/homes/$HOME_A/conversations/$CONV/voice`.
  4. E5: Chrome device mode (touch) on localhost.
  5. `run_eval.py --only T17`.
- Not included: wake word, always-on listening, Urdu (out of scope).

### UC-43: Spoken replies and mute
- Actor: Home member
- Milestone: M3
- Preconditions: UC-42 works.
- Main flow:
  1. When the request came by voice, the reply is also spoken (Piper).
  2. The member can mute spoken replies with a toggle.
- Acceptance criteria (Definition of Done):
  - [ ] AC-43.1 Given the member spoke a command, when the reply arrives, then it is shown and spoken.
  - [ ] AC-43.2 Given the member typed a command, when the reply arrives, then it is shown and not spoken.
  - [ ] AC-43.3 Given mute is on, when a voice reply arrives, then it is shown and not spoken; mute stays on after a page reload.
- Edge cases:
  - UC-43-E1: Given a reply is being spoken, when the member presses the microphone button, then the speech stops at once.
  - UC-43-E2: Given text-to-speech fails, when the reply arrives, then the text still shows and the failure is logged (no error for the user).
- How to test by hand:
  1. Speak a command; type a command; compare.
  2. Turn mute on, reload, speak a command.
  3. E1: speak a command that gives a long reply ("What's on right now?"), then press the button while it speaks.
- Not included: choosing a voice.

### UC-44: Latency per stage for voice
- Actor: Developer
- Milestone: M3
- Preconditions: UC-42 works.
- Main flow:
  1. Each voice turn records `stt_ms`, `llm_ms`, `device_ms`, `tts_ms` and `total_ms`.
- Acceptance criteria (Definition of Done):
  - [ ] AC-44.1 Given a voice turn, when the developer reads `request_metrics`, then `input_mode` is `voice` and all five timings are filled in.
  - [ ] AC-44.2 Given a voice turn, when the timings are added up, then `stt_ms + llm_ms + device_ms + tts_ms` is not more than `total_ms`.
- Edge cases:
  - UC-44-E1: Given mute is on, when a voice turn runs, then `tts_ms` is still recorded (speech is made on the server; mute only stops playback).
- How to test by hand:
  1. Speak 3 commands. `sqlite3 data/app.db "select input_mode, stt_ms, llm_ms, device_ms, tts_ms, total_ms from request_metrics order by id desc limit 3;"`.
- Not included: browser-side timings (recording and playback).

### UC-45: Works on phone, tablet and desktop
- Actor: Home member
- Milestone: M3
- Preconditions: UC-36 to UC-43 done.
- Main flow:
  1. The member uses every page on a phone, a tablet and a desktop screen.
- Acceptance criteria (Definition of Done):
  - [ ] AC-45.1 Given a desktop screen (1280 px or wider), when the assistant page opens, then chat and dashboard are side by side.
  - [ ] AC-45.2 Given a phone screen (390 px), when the assistant page opens, then chat and dashboard are on separate tabs, the conversation list is a drawer, and nothing scrolls sideways.
  - [ ] AC-45.3 Given any page at 390 px, 768 px and 1280 px, when it is checked, then all text is readable and every button can be tapped (at least 44 px high).
- Edge cases:
  - UC-45-E1: Given the phone is turned to landscape, when the assistant page shows, then the layout still works and push-to-talk is reachable.
- How to test by hand:
  1. Chrome device mode: iPhone 12 Pro (390 px), iPad (768 px), desktop. Visit every page.
- Not included: native mobile apps; dark mode (light mode only).

### UC-46: Full device controls on the dashboard (Should)
- Actor: Home member
- Milestone: M3 (Should: built if voice is done in time, otherwise the first fix in M4)
- Preconditions: UC-40 done.
- Main flow:
  1. On a device card, the member changes a setting: brightness slider (dimmable lights), AC temperature +/- buttons, AC mode and fan pickers, fan speed buttons.
  2. The frontend calls `POST /api/homes/{home_id}/devices/{entity_id}/command` with only the changed setting (same fields as the assistant's tools, for example `{"temperature": 23}`).
  3. The backend uses the same validation, HA call and confirmation as the tools, and returns the per-device result.
  4. The card shows the confirmed state; the assistant sees the same state in its next snapshot.
- Acceptance criteria (Definition of Done):
  - [ ] AC-46.1 Given the living room main light is on, when the member drags its brightness slider to 40% and lets go, then one request is sent and HA shows 40%.
  - [ ] AC-46.2 Given the bedroom AC is on at 22 °C, when the member presses + once, then HA shows 23 °C; the card's controls show only this AC's modes (cool, auto) and its range (18 to 28 °C).
  - [ ] AC-46.3 Given the bedroom ceiling fan, when the member presses speed 3, then HA shows 60%.
  - [ ] AC-46.4 Given the member changed the AC on the dashboard, when they then say "make it a bit warmer" in the chat, then the assistant starts from the new temperature (it reads HA, not old chat values).
  - [ ] AC-46.5 Given the kitchen light (on/off only) and the kitchen exhaust fan (on/off only), when their cards show, then they have only the on/off button.
- Edge cases:
  - UC-46-E1: Given the bedroom AC is at 28 °C, when the member looks at the + button, then it is disabled; and if `{"temperature": 35}` is sent to the endpoint with `curl`, the response is `422` "Bedroom AC allows 18 to 28 °C".
  - UC-46-E2: Given the member presses + three times quickly, when the requests finish, then the AC ends at the last value pressed (25 °C from 22 °C) and the card shows HA's confirmed value.
  - UC-46-E3: Given the device has `ignore_commands`, when the member changes a setting, then the card goes back to the real state and shows "Device didn't respond".
  - UC-46-E4: Given a non-member, when they call the command endpoint for `$HOME_A`, then the response is `404` "Home not found".
  - UC-46-E5: Given a field that does not fit the device (`{"brightness": 50}` for the kitchen light), when it is sent, then the response is `422` "This light can't be dimmed".
- How to test by hand:
  1. Use each control in the app; check HA after each.
  2. AC-46.4: change the AC on the dashboard, then use the chat.
  3. E1 to E5: as written; use `curl -b a.txt -X POST $BASE/homes/$HOME_A/devices/climate.bedroom_ac/command -H 'Content-Type: application/json' -d '{"temperature": 35}'` for E1.
- Not included: room-level controls ("all bedroom lights"); schedules.

---

## M4: POC delivered (2026-12-11)

### UC-47: Test server and phone test (Should)
- Actor: Developer
- Milestone: M4
- Preconditions: IT gave access to the internal BrainX test server (task 1.10).
- Main flow:
  1. On day 1 of Sprint 4 the developer deploys the Compose stack to the test server with HTTPS.
  2. The developer opens the app on a phone on the BrainX network or VPN and uses push-to-talk.
- Acceptance criteria (Definition of Done):
  - [ ] AC-47.1 Given the stack is deployed, when the app's HTTPS address is opened on a phone on the BrainX network, then the login page loads with a valid certificate.
  - [ ] AC-47.2 Given the phone is logged in, when the member holds push-to-talk and says T1, then the light turns on and the reply is spoken.
  - [ ] AC-47.3 Given a device outside the BrainX network and VPN, when it opens the address, then it can't connect.
  - [ ] AC-47.4 Given the server, when the developer checks the repo and server files, then secrets are only in the server's `.env` (not in Git) and the login cookie has `Secure`.
- Edge cases:
  - UC-47-E1: Given the app is opened over plain HTTP, when the user goes there, then they are redirected to HTTPS.
- How to test by hand:
  1. Open the URL on your phone (Wi-Fi on the BrainX network); log in; speak T1.
  2. Try from mobile data without VPN.
  3. Check the cookie flags in desktop browser dev tools.
- Not included: public hosting; cloud deployment (out of scope).

### UC-48: Final evaluation and statistics
- Actor: Developer
- Milestone: M4
- Preconditions: M3 done.
- Main flow:
  1. The developer runs the full evaluation (T1 to T24), fixes the most common failures, and runs it again.
  2. The developer creates the latency and token statistics from SQLite.
- Acceptance criteria (Definition of Done):
  - [ ] AC-48.1 Given the final run, when it finishes, then results exist for all 24 scenarios, and the pass rate before and after fixes is recorded in the report.
  - [ ] AC-48.2 Given `scripts/stats.py` runs, when it finishes, then it prints, for text and voice separately, the average and 95th percentile of each stage and of the total, and average tokens per request.
  - [ ] AC-48.3 Given the statistics, when they are compared with the targets (text about 2 s, voice about 4 s), then the report shows the real numbers and says whether each target was met.
- Edge cases:
  - UC-48-E1: Given there are no voice turns yet, when `stats.py` runs, then it says "No voice requests recorded" for that part instead of failing.
- How to test by hand:
  1. `docker compose exec backend python tests/run_eval.py --repeat 3`.
  2. `docker compose exec backend python scripts/stats.py`.
- Not included: performance tests with many users.

### UC-49: Setup from the README
- Actor: Another developer (or the team lead)
- Milestone: M4
- Preconditions: A machine with Docker and Git, but no project files.
- Main flow:
  1. The person follows the README from clone to first command.
- Acceptance criteria (Definition of Done):
  - [ ] AC-49.1 Given only the README, when another person follows it on a clean machine, then they reach a working "turn on the kitchen light" in the web app (T21) without asking the developer.
  - [ ] AC-49.2 Given the README, when it is read, then it covers prerequisites, setup, `.env` keys, HA first-time setup, connecting HA, running and using the app, and running the evaluation.
- Edge cases:
  - UC-49-E1: Given a step fails for the tester, when it is reported, then the README is fixed and the step is tried again.
- How to test by hand:
  1. Ask a colleague (or use a fresh macOS user account) to follow the README; note every question they ask.
- Not included: Windows-specific setup.

### UC-50: Code, security and dependency review
- Actor: Developer, team lead
- Milestone: M4
- Preconditions: Code complete.
- Main flow:
  1. The developer reviews all AI-generated code and runs the dependency audits.
  2. The team lead signs off.
- Acceptance criteria (Definition of Done):
  - [ ] AC-50.1 Given the final code, when `pip-audit` and `npm audit` run, then there are no high or critical findings left (or each one is explained in the report).
  - [ ] AC-50.2 Given the Git history, when it is searched for secrets (for example with `gitleaks`), then no key, token or password is found.
  - [ ] AC-50.3 Given `requirements*.txt` and `package-lock.json`, when they are checked, then every dependency version is pinned exactly.
  - [ ] AC-50.4 Given the tests, when `pytest` and `npm run lint && npm run build` run, then they all pass.
- Edge cases:
  - UC-50-E1: Given an audit finding has no fix available, when it is reviewed, then the risk and reason are written in the report.
- How to test by hand:
  1. `cd backend && pip-audit -r requirements.txt`; `cd frontend && npm audit`.
  2. `gitleaks detect` in the repo root.
  3. `pytest`; `npm run lint && npm run build`.
- Not included: an external penetration test.

### UC-51: Manage rooms in the app (Could)
- Actor: Home member
- Milestone: M4 (only if time is left)
- Preconditions: M3 done; HA connected.
- Main flow:
  1. On the home settings page, the member creates, renames or deletes a room, moves a device to another room, or edits aliases.
  2. The backend sends the change to HA's WebSocket API. HA stays the source of truth; nothing is stored in our database.
- Acceptance criteria (Definition of Done):
  - [ ] AC-51.1 Given the member creates the room "Study", when they open HA > Settings > Areas, then "Study" exists.
  - [ ] AC-51.2 Given the member moves the living room lamp to Bedroom, when the dashboard and HA are checked, then both show it in Bedroom, and "turn on the bedroom lamp" works.
  - [ ] AC-51.3 Given the member adds the alias "hall" to Living room, when they say "turn on the hall light", then the living room main light turns on (or the assistant asks which light, since the room has two).
- Edge cases:
  - UC-51-E1: Given a room name that already exists, when it is created, then "A room with this name already exists" shows.
  - UC-51-E2: Given a room still has devices, when the member deletes it, then a dialog says the devices will have no room (and leave the assistant) and asks to confirm.
- How to test by hand:
  1. Do each action in the app; check HA after each.
- Not included: adding devices (out of scope).

### UC-52: Matter virtual light (Could)
- Actor: Developer
- Milestone: M4 (only if time is left)
- Preconditions: A Linux host with host networking (Matter needs mDNS and IPv6); HA's Matter Server add-on or container.
- Main flow:
  1. The developer starts a matter.js virtual light and adds it to HA through Matter.
  2. The developer puts it in a room in HA.
  3. A member controls it by text.
- Acceptance criteria (Definition of Done):
  - [ ] AC-52.1 Given the Matter light is in HA in the Living room, when the member says "turn on the Matter light", then it turns on, with no app change.
- Edge cases:
  - UC-52-E1: Given Matter can't run on the macOS Docker setup, when this is found, then the finding is written in the report's Matter section instead.
- How to test by hand:
  1. Follow the matter.js example; add it in HA; send the text command.
- Not included: real Matter hardware.
