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
	for ing in all_ingredients():
		if ing in ingredients and not filtered.has(ing):
			filtered.append(ing)
	return " ".join(filtered)


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


static func random_customer_name(is_child: bool) -> String:
	if is_child:
		var child_names: Array[String] = MenuConfig.CHILD_CUSTOMER_NAMES
		return child_names[randi() % child_names.size()]
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
	var unlocked_broths: Array[String] = _filter_unlocked(MenuConfig.BROTH_TYPES, unlocked_ingredients)
	var unlocked_noodles: Array[String] = _filter_unlocked(MenuConfig.NOODLE_TYPES, unlocked_ingredients)
	var unlocked_meats: Array[String] = _filter_unlocked(MenuConfig.MEAT_TYPES, unlocked_ingredients)
	var unlocked_vegetables: Array[String] = _filter_unlocked(MenuConfig.VEGETABLE_TYPES, unlocked_ingredients)
	var unlocked_drinks: Array[String] = _filter_unlocked(MenuConfig.DRINK_TYPES, unlocked_ingredients)

	# Decide if this is a drink or noodle dish.
	var make_drink: bool = unlocked_drinks.size() > 0 and randf() < 0.2
	if make_drink:
		ingredients.append(
			unlocked_drinks[randi() % unlocked_drinks.size()]
		)
	else:
		if unlocked_noodles.is_empty() or unlocked_broths.is_empty():
			return ""

		# Choose noodle
		ingredients.append(
			unlocked_noodles[randi() % unlocked_noodles.size()]
		)

		# Choose broth
		ingredients.append(
			unlocked_broths[randi() % unlocked_broths.size()]
		)

		# Maybe add 1–2 meats
		if not unlocked_meats.is_empty():
			var meats_to_add: int = randi_range(0, 2)
			for i in range(meats_to_add):
				ingredients.append(
					unlocked_meats[randi() % unlocked_meats.size()]
				)

		# Maybe add 0–2 vegetables
		if not unlocked_vegetables.is_empty():
			var veg_to_add: int = randi_range(0, 2)
			for i in range(veg_to_add):
				ingredients.append(
					unlocked_vegetables[randi() % unlocked_vegetables.size()]
				)

	return canonical_dish_key(ingredients)


static func _filter_unlocked(source: Array[String], unlocked_ingredients: Array[String]) -> Array[String]:
	var result: Array[String] = []
	for ing in source:
		if ing in unlocked_ingredients:
			result.append(ing)
	return result
