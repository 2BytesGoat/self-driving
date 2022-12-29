extends Node

func evaluate_expression(command, variable_names = [], variable_values = []):
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)
	if expression.has_execute_failed():
		return null
	return result

func get_distance(vect1, vect2):
	var difference = vect1 - vect2
	return sqrt(pow(difference.x, 2) + pow(difference.y, 2))
