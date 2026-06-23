extends RefCounted

class_name GameContent

static func load_game_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Arquivo de conteúdo não encontrado: %s" % path)
		return {}

	var raw_text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Falha ao ler conteúdo do jogo.")
		return {}

	var data: Dictionary = parsed
	_validate(data)
	return data

static func to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result

static func _validate(data: Dictionary) -> void:
	var phases: Array = data.get("phases", [])
	for phase_variant in phases:
		if typeof(phase_variant) != TYPE_DICTIONARY:
			push_warning("Fase inválida encontrada.")
			continue
		var phase_data: Dictionary = phase_variant
		_validate_phase(phase_data)

static func _validate_phase(phase_data: Dictionary) -> void:
	var phase_id := str(phase_data.get("id", "sem_id"))
	if str(phase_data.get("type", "")) == "boss":
		var rounds: Array = phase_data.get("rounds", [])
		for round_index in range(rounds.size()):
			if typeof(rounds[round_index]) != TYPE_DICTIONARY:
				push_warning("Rodada inválida no chefão %s." % phase_id)
				continue
			_validate_question_block(phase_id, rounds[round_index], "rodada %d" % (round_index + 1))
		return

	_validate_question_block(phase_id, phase_data, "fase")

static func _validate_question_block(phase_id: String, question_data: Dictionary, context_label: String) -> void:
	var correct_answer := int(question_data.get("correct_answer", 0))
	var options: Array = question_data.get("options", [])
	if options.is_empty():
		push_warning("%s sem alternativas em %s." % [phase_id, context_label])
		return

	var normalized_options: Array[int] = []
	for option_value in options:
		if typeof(option_value) not in [TYPE_INT, TYPE_FLOAT]:
			push_warning("%s possui alternativa não numérica em %s." % [phase_id, context_label])
			continue
		normalized_options.append(int(option_value))

	if not normalized_options.has(correct_answer):
		push_warning("%s com resposta correta fora das alternativas em %s." % [phase_id, context_label])
