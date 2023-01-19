local M = {}

local function remove_whitespace(str)
    return str:gsub("%s+", "")
end

local function check_if_commented(lines, comment_symbol)
    local commented = false
    for _, current_line in ipairs(lines) do
        local pos = string.find(current_line, "%S");
        if pos ~= nil then
            if remove_whitespace(string.sub(current_line, pos, pos + #comment_symbol)) == comment_symbol then
                commented = true
            else
                commented = false
                break
            end
        end
    end
    return commented
end

local function is_line_empty()
    local current_line = vim.fn.getline(".")
    if current_line == "" then return true end
    return false
end

M.config = {
    multiple_line_comments = false,
    empty_line_comment = false,
}


function M.setup(opts)
end

function M.single_line_comment()
    if is_line_empty() then return end

    local comment = vim.api.nvim_buf_get_option(0, "commentstring")
    local comment_symbol = string.sub(comment, 1, 2)
    -- get current line
    local current_line = vim.api.nvim_get_current_line()
    local first_char_pos = string.find(current_line, "%S")

    -- update current line with appropiate comment
    local comment_line = string.sub(current_line, 1, first_char_pos - 1) .. comment_symbol .. " " .. string.sub(current_line, first_char_pos)
    local lines = {current_line}

    local curr = vim.api.nvim_win_get_cursor(0)[1]
    if not check_if_commented(lines, comment_symbol) then
        vim.api.nvim_buf_set_lines(0, curr - 1, curr, false, {comment_line})
    else
        -- replcae comment symbol with empty string
        local previous_line = string.sub(current_line, 1, first_char_pos - 1) .. string.sub(current_line, first_char_pos + #comment_symbol + 1)
        vim.api.nvim_buf_set_lines(0, curr - 1, curr, false, {previous_line})
    end
end

M.test = {}

function M.multi_line_comment()
    vim.cmd([[execute "normal! \<esc>"]])

    local comment = vim.api.nvim_buf_get_option(0, "commentstring")
    local comment_symbol = string.sub(comment, 1, 2)

    -- get highlighted lines 
    local line_start = vim.api.nvim_buf_get_mark(0, '<')[1]
    local line_end = vim.api.nvim_buf_get_mark(0, '>')[1]
    M.test = {line_start, line_end}

    -- get lines
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local comment_lines = {}

    local minimum_whitespace = 1000000

    if not check_if_commented(lines, comment_symbol) then
        for i, current_line in ipairs(lines) do
            local first_char_pos = string.find(current_line, "%S")
            if first_char_pos ~= nil then
                minimum_whitespace = math.min(minimum_whitespace, first_char_pos)
                comment_lines[i] = string.sub(current_line, 1, minimum_whitespace - 1) .. comment_symbol .. " " .. string.sub(current_line, minimum_whitespace)
            else
                comment_lines[i] = ""
            end
        end
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, comment_lines)
    else
        local previous_lines = {}
        for i, current_line in ipairs(lines) do
            local first_char_pos = string.find(current_line, "%S")
            if first_char_pos ~= nil then
                previous_lines[i] = string.sub(current_line, 1, first_char_pos - 1) .. string.sub(current_line, first_char_pos + #comment_symbol + 1)
            else
                previous_lines[i] = ""
            end
        end
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, previous_lines)
    end
    M.test = lines
end

return M
