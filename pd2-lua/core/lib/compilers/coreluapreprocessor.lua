require("core/lib/compilers/CoreCompilerSystem")

CoreLuaPreprocessor = CoreLuaPreprocessor or class()
CoreLuaPreprocessor.preprocessors = {}
CoreLuaPreprocessor.DEBUG = false
CoreLuaPreprocessor._WHITESPACE_CHARACTERS = {
	[" "] = true,
	["\n"] = true,
	["\r"] = true,
	["\t"] = true
}
CoreLuaPreprocessor._IF_STATEMENT = "#IF"
CoreLuaPreprocessor._ELSEIF_STATEMENT = "#ELSE_IF"
CoreLuaPreprocessor._ELSE_STATEMENT = "#ELSE"
CoreLuaPreprocessor._OR_OPERATOR = "or"
CoreLuaPreprocessor._OPENING_BRACKET = "{"
CoreLuaPreprocessor._CLOSING_BRACKET = "}"

function CoreLuaPreprocessor:preprocess(path, constants_table, code)
	self._source_path = path
	local c = self:_apply_preprocessor_1(constants_table, code)

	return c
end

function CoreLuaPreprocessor:_apply_preprocessor_1(constants_table, source_str)
	local params = {
		output_str = ""
	}
	local source_len = string.len(source_str)
	local current_pos = 1

	repeat
		current_pos = self:_parse_next_block(constants_table, current_pos, source_str, source_len, params)
	until source_len < current_pos

	return params.output_str
end

function CoreLuaPreprocessor:_parse_next_block(constants_table, current_pos, source_str, source_len, params)
	local statements_list = {}

	repeat
		local sussess, finished = self:_parse_next_conditional_statement(source_str, source_len, current_pos, constants_table, statements_list)

		if not sussess then
			self:print_error("[CoreLuaPreprocessor:_process_next_block] " .. self._IF_STATEMENT .. " statement parsing error. file: " .. self._source_path .. ". (" .. tostring(self:_line_number_at_pos(constants_end_pos + 1)) .. ")")

			return
		end

		if next(statements_list) then
			current_pos = statements_list[#statements_list].bracket_close_pos + 1 or current_pos
		end
	until finished

	if not next(statements_list) then
		params.output_str = params.output_str .. string.sub(source_str, current_pos, source_len)

		return source_len + 1
	end

	local true_statement_found = nil

	for i_statement, statement_info in ipairs(statements_list) do
		params.output_str = params.output_str .. statement_info.whitespace

		if not true_statement_found and statement_info.truth then
			true_statement_found = true
			local unprocessed_block = string.sub(source_str, statement_info.bracket_open_pos + 1, statement_info.bracket_close_pos - 1)
			local processed_block = self:_apply_preprocessor_1(constants_table, unprocessed_block)
			params.output_str = params.output_str .. processed_block
		else
			params.output_str = params.output_str .. self:_get_only_newlines(source_str, statement_info.bracket_open_pos + 1, statement_info.bracket_close_pos - 1)
		end
	end

	return statements_list[#statements_list].bracket_close_pos + 1
end

function CoreLuaPreprocessor:_parse_next_conditional_statement(source_str, source_len, start_pos, constants_table, statements_list)
	local statement_info, is_last_statement = nil

	if not next(statements_list) then
		local if_start_pos, if_end_pos = nil
		local search_pos = start_pos

		repeat
			if_start_pos, if_end_pos = string.find(source_str, self._IF_STATEMENT, search_pos, true)

			if not if_start_pos then
				return true, true
			end

			search_pos = if_end_pos and if_end_pos + 1
		until if_start_pos ~= 1 and self:_is_whitespace_or_singleline_comment(source_str, if_start_pos - 1) and self:_is_whitespace(source_str, if_end_pos + 1)

		statement_info = self:_parse_statement(source_str, source_len, if_end_pos + 1, constants_table, statements_list)

		if start_pos ~= if_start_pos then
			statement_info.whitespace = string.sub(source_str, start_pos, if_start_pos - 1)
		end
	else
		local elseif_start_pos, elseif_end_pos, else_start_pos, else_end_pos = nil
		local search_pos = start_pos

		repeat
			elseif_start_pos, elseif_end_pos = string.find(source_str, self._ELSEIF_STATEMENT, search_pos, true)
			search_pos = elseif_end_pos and elseif_end_pos + 1
		until not elseif_start_pos or self:_is_whitespace(source_str, elseif_end_pos + 1)

		search_pos = start_pos

		repeat
			else_start_pos, else_end_pos = string.find(source_str, self._ELSE_STATEMENT, search_pos, true)
			search_pos = else_end_pos and else_end_pos + 1
		until not else_start_pos or self:_is_whitespace(source_str, else_end_pos + 1)

		if elseif_start_pos and (elseif_start_pos == start_pos or self:_is_whitespace(source_str, start_pos, elseif_start_pos - 1)) then
			statement_info = self:_parse_statement(source_str, source_len, elseif_end_pos + 1, constants_table, statements_list)

			if not statement_info then
				return
			end
		elseif else_start_pos and (else_start_pos == start_pos or self:_is_whitespace(source_str, start_pos, else_start_pos - 1)) then
			statement_info = self:_parse_statement(source_str, source_len, else_end_pos + 1, false, statements_list)

			if not statement_info then
				return
			end

			is_last_statement = true
		end
	end

	if not statement_info then
		return true, true
	end

	statement_info.whitespace = statement_info.whitespace or self:_get_only_newlines(source_str, start_pos, statement_info.bracket_open_pos - 1)

	table.insert(statements_list, statement_info)

	return true, is_last_statement
end

function CoreLuaPreprocessor:_parse_statement(source_str, source_len, start_pos, constants_table)
	local statement_info = {}
	local constants_end_pos = nil

	if constants_table then
		local constants_statement_table, constants_end_pos_out = self:_extract_constants(source_str, start_pos)
		constants_end_pos = constants_end_pos_out
		statement_info.truth = self:_test_constants_truth(constants_statement_table, constants_table)
	else
		statement_info.truth = true
		constants_end_pos = start_pos
	end

	local bracket_open_pos, bracket_close_pos = self:_find_bracket_block(source_str, source_len, constants_end_pos + 1)

	if not bracket_open_pos then
		return
	end

	statement_info.bracket_open_pos = bracket_open_pos
	statement_info.bracket_close_pos = bracket_close_pos

	return statement_info
end

function CoreLuaPreprocessor:_extract_constants(source_str, start_pos)
	local bracket_open_pos = string.find(source_str, self._OPENING_BRACKET, start_pos, true)

	if not bracket_open_pos then
		self:print_error("[CoreLuaPreprocessor:_process_next_block] statement without opening bracket. file: " .. self._source_path .. ". (" .. tostring(self:_line_number_at_pos(start_pos)) .. ")")

		return
	end

	local constants_statement_str = string.sub(source_str, start_pos, bracket_open_pos - 1)
	local constants_statement_table = string.split(constants_statement_str, " " .. self._OR_OPERATOR .. " ", nil, nil)
	local constants_statement_table_out = {}

	for key, constant_statement in pairs(constants_statement_table) do
		constant_statement = self:_cleanup_constant(constant_statement)
		constants_statement_table_out[key] = constant_statement
	end

	return constants_statement_table_out, bracket_open_pos - 1
end

function CoreLuaPreprocessor:_cleanup_constant(constant)
	for whitespace_char, _ in pairs(self._WHITESPACE_CHARACTERS) do
		constant = string.gsub(constant, whitespace_char, "")
	end

	return constant
end

function CoreLuaPreprocessor:_find_bracket_block(source_str, source_len, start_pos)
	local bracket_open_pos = string.find(source_str, self._OPENING_BRACKET, start_pos, true)

	if not bracket_open_pos then
		return
	end

	if bracket_open_pos ~= start_pos and not self:_is_whitespace(source_str, start_pos, bracket_open_pos - 1) then
		return
	end

	local bracket_close_pos = self:_find_corresponding_closing_bracket(source_str, source_len, bracket_open_pos)

	if not bracket_close_pos then
		return
	end

	return bracket_open_pos, bracket_close_pos
end

function CoreLuaPreprocessor:_find_corresponding_closing_bracket(source_str, source_len, bracket_open_pos)
	local current_pos = bracket_open_pos + 1
	local nr_open_brackets = 1

	while nr_open_brackets > 0 and current_pos <= source_len do
		local closing_bracket_pos = string.find(source_str, self._CLOSING_BRACKET, current_pos, true)

		if closing_bracket_pos then
			nr_open_brackets = nr_open_brackets - 1
			nr_open_brackets = nr_open_brackets + self:_count_opening_brackets(source_str, current_pos, closing_bracket_pos - 1)
			current_pos = closing_bracket_pos + 1
		else
			self:print_error("[CoreLuaPreprocessor:_find_corresponding_closing_bracket_pos] Did not find corresponding closing bracket for opening bracket at " .. tostring(self:_line_number_at_pos(bracket_open_pos)) .. ". file: ", self._source_path)

			break
		end
	end

	return nr_open_brackets == 0 and current_pos - 1
end

function CoreLuaPreprocessor:_count_opening_brackets(source_str, search_start_pos, search_end_pos)
	local search_pos = search_start_pos
	local nr_opening_brackets = 0

	repeat
		local pos = string.find(source_str, self._OPENING_BRACKET, search_pos, true)

		if pos then
			if pos <= search_end_pos then
				nr_opening_brackets = nr_opening_brackets + 1
				search_pos = pos + 1
			else
				pos = nil
			end
		end
	until not pos or search_end_pos < search_pos

	return nr_opening_brackets
end

function CoreLuaPreprocessor:_line_number_at_pos(source_str, end_pos)
	local search_pos = 1
	local nr_newlines = 0

	repeat
		local pos = string.find(source_str, "\n", search_pos, true)

		if pos then
			if pos <= end_pos then
				nr_newlines = nr_newlines + 1
				search_pos = pos + 1
			else
				pos = nil
			end
		end
	until not pos or end_pos < search_pos

	return nr_newlines + 1
end

function CoreLuaPreprocessor:_is_whitespace(source_str, start_pos, end_pos)
	end_pos = end_pos or start_pos
	local search_pos = start_pos

	repeat
		local test_char = string.sub(source_str, search_pos, search_pos)

		if self._WHITESPACE_CHARACTERS[test_char] then
			search_pos = search_pos + 1
		else
			return false
		end
	until end_pos < search_pos

	return true
end

function CoreLuaPreprocessor:_is_whitespace_or_singleline_comment(source_str, start_pos)
	if self:_is_whitespace(source_str, start_pos) then
		return true
	end

	if start_pos == 1 then
		return false
	end

	if string.sub(source_str, start_pos, start_pos) == "-" and string.sub(source_str, start_pos - 1, start_pos - 1) == "-" then
		return true
	end

	return false
end

function CoreLuaPreprocessor:_get_only_newlines(source_str, start_pos, end_pos)
	local out = ""
	local search_pos = start_pos

	repeat
		local pos = string.find(source_str, "\n", search_pos, true)

		if pos then
			if pos <= end_pos then
				out = out .. "\r\n"
				search_pos = pos + 1
			else
				pos = nil
			end
		end
	until not pos or end_pos < search_pos

	return out
end

function CoreLuaPreprocessor:_test_constants_truth(constants_statement_table, constants_table)
	for key, constant in pairs(constants_statement_table) do
		if constants_table[constant] then
			return true
		end
	end
end

function CoreLuaPreprocessor:print_error(text)
	print("\n[ERROR] " .. text .. "\n")
end
