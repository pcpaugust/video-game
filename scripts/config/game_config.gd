extends Resource
class_name GameConfig

# Customer & level settings
const BASE_CUSTOMER_COUNT: int = 2
const MAX_CUSTOMERS: int = 5

const CHILD_CUSTOMER_CHANCE: float = 0.1

const SPAWN_INTERVAL_BASE: float = 7.0
const SPAWN_INTERVAL_DECREASE_PER_LEVEL: float = 0.7
const MIN_SPAWN_INTERVAL: float = 5.0

# Patience / time settings
const BASE_PATIENCE_TIME: float = 72.0
const PATIENCE_TIME_PER_LEVEL: float = 1.5
const CHILD_PATIENCE_BONUS: float = 4.0
const MIN_PATIENCE_TIME: float = 8.0

const TIME_BONUS_PER_DISH: float = 12

const MAX_DISH_SLOTS: int = 2

# Fail conditions
const BASE_MISSED_CUSTOMERS: int = 2

# Scoring
const BASE_SCORE_PER_DISH: int = 15
const FULL_ORDER_BONUS: int = 10
const CHILD_SCORE_MULTIPLIER: float = 0.8

# Target progression for next level
const TARGET_INCREMENT_BASE: int = 10
const TARGET_INCREMENT_PER_LEVEL: int = 5

static func next_level_target(current_target: int, level: int) -> int:
	return current_target + TARGET_INCREMENT_BASE + (level * TARGET_INCREMENT_PER_LEVEL)
