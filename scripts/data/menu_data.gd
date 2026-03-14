extends Resource
class_name MenuData

static func all_ingredients() -> Array[String]:
	return (
		MenuConfig.BROTH_TYPES
		+ MenuConfig.NOODLE_TYPES
		+ MenuConfig.MEAT_TYPES
		+ MenuConfig.VEGETABLE_TYPES
		+ MenuConfig.DRINK_TYPES
	)


static func is_valid_ingredient(token: String) -> bool:
	return token in all_ingredients()


static func canonical_dish_key(ingredients: Array[String]) -> String:
	var filtered: Array[String] = []
	for ing in ingredients:
		if ing in all_ingredients() and not filtered.has(ing):
			filtered.append(ing)
	filtered.sort()
	return " | ".join(filtered)


static func is_drink(ingredients: Array[String]) -> bool:
	# A simple rule: a pure drink contains exactly one drink token and nothing else.
	if ingredients.size() != 1:
		return false
	return ingredients[0] in MenuConfig.DRINK_TYPES


static func get_unlocked_ingredients_for_level(level: int) -> Array[String]:
	# Unlock more variety as the level increases.
	var unlocked: Array[String] = []

	# Everyone starts with basic broth + two noodles + one meat + one vegetable.
	unlocked.append_array(MenuConfig.BROTH_TYPES)
	unlocked.append_array(
		MenuConfig.NOODLE_TYPES.slice(
			0,
			clamp(level, 1, MenuConfig.NOODLE_TYPES.size())
		)
	)
	unlocked.append_array(
		MenuConfig.MEAT_TYPES.slice(
			0,
			clamp(level, 1, MenuConfig.MEAT_TYPES.size())
		)
	)
	unlocked.append_array(
		MenuConfig.VEGETABLE_TYPES.slice(
			0,
			clamp(level, 1, MenuConfig.VEGETABLE_TYPES.size())
		)
	)

	if level >= 3:
		unlocked.append_array(MenuConfig.DRINK_TYPES)

	# Remove duplicates just in case.
	var result: Array[String] = []
	for ing in unlocked:
		if not result.has(ing):
			result.append(ing)
	return result


static func random_customer_name(is_special: bool, is_child: bool) -> String:
	if is_child:
		var child_names: Array[String] = MenuConfig.CHILD_CUSTOMER_NAMES
		return child_names[randi() % child_names.size()]
	if is_special:
		var special_names: Array[String] = MenuConfig.SPECIAL_CUSTOMER_NAMES
		return special_names[randi() % special_names.size()]
	var normal_names: Array[String] = MenuConfig.NORMAL_CUSTOMER_NAMES
	return normal_names[randi() % normal_names.size()]


static func build_random_order_keys(unlocked_ingredients: Array[String], level: int) -> Array[String]:
	var order_keys: Array[String] = []

	var num_dishes: int = clamp(1 + level / 2, 1, 4)
	for i in range(num_dishes):
		order_keys.append(_build_single_dish_key(unlocked_ingredients))
	return order_keys


static func _build_single_dish_key(unlocked_ingredients: Array[String]) -> String:
	var ingredients: Array[String] = []

	# Decide if this is a drink or noodle dish.
	var make_drink: bool = MenuConfig.DRINK_TYPES.size() > 0 and randf() < 0.2
	if make_drink:
		ingredients.append(
			MenuConfig.DRINK_TYPES[randi() % MenuConfig.DRINK_TYPES.size()]
		)
	else:
		# Choose broth
		ingredients.append(
			MenuConfig.BROTH_TYPES[randi() % MenuConfig.BROTH_TYPES.size()]
		)

		# Choose noodle
		ingredients.append(
			MenuConfig.NOODLE_TYPES[randi() % MenuConfig.NOODLE_TYPES.size()]
		)

		# Maybe add 1–2 meats
		var meats_to_add: int = randi_range(0, 2)
		for i in range(meats_to_add):
			ingredients.append(
				MenuConfig.MEAT_TYPES[randi() % MenuConfig.MEAT_TYPES.size()]
			)

		# Maybe add 0–2 vegetables
		var veg_to_add: int = randi_range(0, 2)
		for i in range(veg_to_add):
			ingredients.append(
				MenuConfig.VEGETABLE_TYPES[
					randi() % MenuConfig.VEGETABLE_TYPES.size()
				]
			)

	return canonical_dish_key(ingredients)
