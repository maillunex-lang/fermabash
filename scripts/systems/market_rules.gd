extends RefCounted
## Local elevator prices, delivery contracts and a hired crew.
## Agronomy stays on the accelerated job clock. The season calendar
## (GameClock) is unchanged. Trading days are 90 real seconds so a
## play session can see price moves without waiting a real season.
## No accounts, shared order book, or server authority.
const BASE_PRICE := 450
const CYCLE := 28
const TRADING_DAY_SECONDS := 90.0
const FINE := 150
const CREW_COST := 400
const CREW_DAYS := 5
const CREW_JOB_SECONDS := 4.5
const BASE_JOB_SECONDS := 6.0
const CREW_TRAVEL := 1.25
const OFFSETS: Array[int] = [0, 20, 40, 55, 40, 15, -10, -30, -50, -70, -40, -15, 10, 25, 35, 20, 0, -20, -45, -60, -30, 10, 30, 50, 35, 15, 5, 0]

static func trading_day(elapsed: float) -> int:
 return 1 + int(floor(maxf(elapsed, 0.0) / TRADING_DAY_SECONDS))

static func spot_price(trading: int) -> int:
 var index := posmod(maxi(trading, 1) - 1, CYCLE)
 return BASE_PRICE + OFFSETS[index]

static func forecast(trading: int, count: int = 7) -> Array[int]:
 var result: Array[int] = []
 for i in range(maxi(count, 0)):
  result.append(spot_price(trading + i))
 return result

static func offer_short(trading: int) -> Dictionary:
 var day := maxi(trading, 1)
 return {
  "id": "short-%d" % day,
  "title": "Элеватор Уфы",
  "tons": 3,
  "deadline": day + 2,
  "price": spot_price(day) + 80
 }

static func offer_bulk(trading: int) -> Dictionary:
 var day := maxi(trading, 1)
 return {
  "id": "bulk-%d" % day,
  "title": "Мельница Стерлитамака",
  "tons": 6,
  "deadline": day + 4,
  "price": spot_price(day) + 40
 }

static func payout(data: Dictionary) -> int:
 return maxi(0, int(data.get("tons", 0))) * maxi(0, int(data.get("price", 0)))

static func validate_contract(data: Variant) -> bool:
 if not data is Dictionary:
  return false
 if data.is_empty():
  return true
 for key in ["id", "title", "tons", "deadline", "price"]:
  if not data.has(key):
   return false
 if not data["id"] is String or not data["title"] is String:
  return false
 return int(data["tons"]) > 0 and int(data["price"]) > 0 and int(data["deadline"]) >= 1

static func crew_active(trading: int, until_day: int) -> bool:
 return until_day > 0 and until_day >= maxi(trading, 1)

static func job_seconds(trading: int, until_day: int) -> float:
 if crew_active(trading, until_day):
  return CREW_JOB_SECONDS
 return BASE_JOB_SECONDS
