# AI Home Assistant POC: Brainstorm

| | |
|---|---|
| **Status** | Agreed |
| **Date** | 2026-11-17 |
| **Author** | Arooj Fatima |
| **Related documents** | `../PRD.md`, `../ARCHITECTURE.md`, `../PROJECT_PLAN.md` (in the folder above the repo) |

This file records what was agreed in the brainstorm. The PRD and ARCHITECTURE documents stay the detailed source; this file adds priorities, scope decisions and open questions.

---

## Problem

This is a **training POC**, not a client project. The main goal is learning:

- AI assistant architecture
- Tool calling
- Conversation management
- Smart device integration (Home Assistant over MQTT)

The result must **really work end to end** (not a mock-up). The code should stay clean enough to reuse later for a client product (for example healthcare or hospitality), but nothing is built only for reuse in version 1.

The user-facing problem it demonstrates: controlling a smart home means opening each device's controls one by one. Natural language ("it's too hot in the bedroom") is faster.

## Users

| Role | Uses the app? | What they do |
|---|---|---|
| **Home member** | Yes (only app role) | Signs up, creates or joins a home, types or speaks commands, watches the live dashboard. All members have equal access (no owner or admin). |
| **Developer** | Indirectly | Reads tool, token and latency logs; adds devices in `devices.yaml`; injects faults; runs the evaluation. |
| **Team lead** | No | Reviews work and approves milestones. |

## MVP features

### Must

- Device simulator + Home Assistant + Mosquitto (MQTT) with the 11 test devices
- Agent: tool calling, validation in code, guards (unknown device, out of range, bulk confirmation), success only after HA confirms the state, partial-failure reporting
- Context: last 10 whole turns, follow-ups and pronouns ("it", "them"), several actions in one message
- Sign-up, login, logout; one home connected to HA (encrypted token, test connection); membership checks on every route, WebSocket and tool call
- Chat UI and live dashboard (rooms and devices, real-time updates)
- Push-to-talk voice input (faster-whisper) and spoken replies (Piper) with a mute toggle
- Tool, token and latency logging; evaluation script for PRD scenarios T1 to T24

### Should (first to simplify if Sprint 3 slips)

- Add members by email; remove a member
- Several homes per user and a home switcher; delete a home
- Past conversations list (read-only)
- Deploy to the internal BrainX test server (confirmed available; HTTPS, not public) to test push-to-talk on phones. Browsers allow the microphone only on HTTPS or localhost.

### Could (only if time is left, Sprint 4)

- Manage rooms in our app (create, rename, delete rooms, move devices, edit aliases) through HA's WebSocket API. HA stays the source of truth; no device tables. About 2 to 3 days.
- Matter virtual light through Home Assistant

### Trainer feedback (2026-11-17)

| Trainer's point | Where it is covered |
|---|---|
| Function calls must really change device state; a simulated success message is not enough | PRD FR-12 (wording made explicit), ARCHITECTURE D7; tests T15, T16 |
| Answer status questions ("Is the bedroom light on?", "What is the AC temperature?") | `get_device_state`, `get_sensor_reading`; tests T12, T13, new T24 |
| Conversation context ("Set the AC to 22" then "Actually, make it 20") | PRD FR-15 to FR-17; tests T2, T3, T6, new T23. With two ACs in the test home, "the AC" without a room must first ask which one (T4 rule), so T23 names the room. |

## Out of scope

| Item | Reason |
|---|---|
| Urdu or Roman Urdu | Future work |
| Schedules, timers, automations | Not required by the task |
| User roles and permissions | All members have equal access |
| Password reset, email verification, social login, 2FA | Production features |
| Adding or pairing devices inside our app | Devices come from HA integrations (or `devices.yaml`) |
| Real hardware | No device purchase for this POC. If added later, a Wi-Fi device with local control (for example Shelly) added to HA by IP needs no app code. The developer's Haier fridge (HaiSmart app) was checked: no Home Assistant integration was found for HaiSmart; the only Haier option is an unofficial hOn add-on that Haier asked to be taken down, so it is not used. The developer's Orient Ultron Lunar AC is used only with its IR remote (no app), so HA can't reach it without buying an IR blaster. |
| Vendor cloud apps (Tuya, SmartLife and similar) | Need cloud accounts; slow and unreliable for a demo |
| Zigbee and Z-Wave devices | Need a USB radio stick, which Docker on macOS can't pass to HA |
| Native mobile app | The web app is responsive |
| Wake word, always-on listening | Push-to-talk is enough |
| Document-based RAG | Excluded by the task |
| Public production deployment, cloud hosting | Local POC; only an internal test server is a Should |

## Risks and challenges

| Risk | Impact | Idea to reduce it |
|---|---|---|
| Home Assistant details (MQTT discovery fields, registries, matching `state_changed` to a command) | 1 to 2 days of trial and error in Sprint 1 | Start with one device type; check fields against current HA docs; integration tests against the Compose stack |
| gpt-4o-mini mistakes on follow-ups, bulk "yes" (T10) and implicit intent (T14) | Pass rate likely 85 to 95%, not 100% | Typed strict schemas, clear prompt, validation in code, low temperature, Sprint 4 fix time |
| Latency: text has 2 LLM calls plus device confirmation; voice adds CPU Whisper inside Docker (no Apple GPU) | Text about 1.5 to 3 s (target 2 s); voice about 3 to 5 s (target 4 s) | Whisper `base`; measure every stage and report real numbers |
| Development machine: Apple M1, 16 GB RAM | Enough, but Docker needs memory | Give Docker about 8 GB |
| HA first-time setup is manual (admin, MQTT integration, token) | Blocks automated integration tests and evaluation | Early setup checklist plus `scripts/load_demo_data.py` |
| Docker Desktop licence for company use | Legal only; no technical impact | IT to confirm (see Open questions); fallback Colima runs the same Compose file |
| Piper is GPL-3.0 | Fine for an internal POC; a problem if reused in a client product | Keep TTS behind one small interface so it can be swapped |
| OpenAI cost | Low (cents per day of testing) | Log tokens; set a usage limit in the OpenAI dashboard |
| Privacy | Only text (commands, device names) goes to OpenAI; audio stays local | Never log passwords, tokens, keys or audio; PII limited to name and email |
| gpt-4o-mini shutdown on 2027-01-14 | None for the POC (ends 2026-12-11) | Model name in `.env` |
| Time: one developer, 4 weeks, started 2026-11-16 | Voice or UI could slip | Must, Should, Could priorities above |
| Test server holds the OpenAI key and HA tokens on the network | Security exposure (ISO 27001) | IT approval, HTTPS, BrainX network or VPN only, secrets outside Git |

## Open questions

| # | Question | Owner | If not resolved |
|---|---|---|---|
| Q1 | Is Docker Desktop allowed for company use on BrainX machines without a paid subscription? Docker's free tier depends on company size and revenue (as understood: fewer than 250 employees and less than $10M USD revenue; IT to confirm current terms). | IT / Admin | Switch to Colima (free, same commands); nothing in the plan waits on this |

Resolved:
- The OpenAI API key is available.
- No real hardware will be bought for this POC; devices stay simulated.
- An internal BrainX test server will be used for phone testing (HTTPS, not public, access limited to the BrainX network or VPN).

## Doability verdict

**Go.** Every part is possible with known, free tools (except OpenAI, which is paid per token and already available). The hard parts are Home Assistant integration details, small-model accuracy and latency; all have mitigations above. The scope is large for one developer in 4 weeks, so the Should and Could lists define what gets simplified first.
