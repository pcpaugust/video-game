extends Resource
class_name GameConfig

# Customer & level settings
const BASE_CUSTOMER_COUNT: int = 2
const MAX_CUSTOMERS: int = 4

const SPECIAL_CUSTOMER_CHANCE: float = 0.2
const CHILD_CUSTOMER_CHANCE: float = 0.2

# Patience / time settings
const BASE_PATIENCE_TIME: float = 100.0
const PATIENCE_TIME_PER_LEVEL: float = 1.5
const CHILD_PATIENCE_BONUS: float = 4.0
const SPECIAL_PATIENCE_PENALTY: float = 4.0
const MIN_PATIENCE_TIME: float = 8.0

const TIME_BONUS_PER_DISH: float = 3.0

# Dish / slot settings
const MAX_DISH_SLOTS: int = 3

# Fail conditions
const MAX_MISSED_CUSTOMERS: int = 2

# Scoring
const BASE_SCORE_PER_DISH: int = 10
const FULL_ORDER_BONUS: int = 20
const SPECIAL_SCORE_MULTIPLIER: float = 1.5
const CHILD_SCORE_MULTIPLIER: float = 0.8
