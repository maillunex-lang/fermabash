# Stage 5: local grain market, elevator contracts, hired crew

## Decision
Roadmap item 4 is an authoritative server. That stays blocked: no VPS and no accounts without an explicit request. This stage is the local slice of roadmap item 5 (market, contracts, equipment/employees).

Agronomy timings are unchanged: soil preparation, sowing and harvest still take 6 real seconds, and a sown crop still matures in 10. The season clock is still seven real days per game year (`GameClock`). A new **trading day** lasts 90 real seconds and drives only the elevator price, contract deadlines and crew duration. Day 1 of a session still sells wheat at the historical 450 ₽/t, so older cash assertions stay valid. Prices then follow a fixed 28-day seasonal table (no randomness).

## Implemented
- Spot sale uses the trading-day price. The base table starts at 450 ₽/t.
- Two local offers refresh every trading day:
  - Ufa elevator: 3 t, spot + 80 ₽/t, deadline in 2 trading days.
  - Sterlitamak mill: 6 t, spot + 40 ₽/t, deadline in 4 trading days.
- One accepted contract at a time. Delivery takes grain from the existing warehouse and pays the contract price, not the spot price. A missed deadline fines 150 ₽ (or whatever cash remains) and clears the contract.
- A crew costs 400 ₽ and works for 5 trading days. While hired, field work takes 4.5 s instead of 6 s and road travel is 1.25×. With no crew, both speeds match stage 4.
- Saves stay on version 1. `contract` and `crew_until_day` are optional. Older saves load with no contract and no crew. Purchases, deliveries and fines autosave.

## Not included
No shared order book, no player-to-player land conflict, no equipment yard beyond the temporary crew, no crop varieties, no server persistence. Roads, field groups, action-first assignment and building rules are unchanged.
