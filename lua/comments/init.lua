local M = {}

local function check_if_commented(lines, comment_symbol)
    local commented = false
    for _, current_line in ipairs(lines) do
        if current_line:sub(1, #comment_symbol) == comment_symbol then
            commented = true
        else
            commented = false
            break
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

    -- update current line with appropiate comment
    local comment_line = string.gsub(current_line, "^", comment_symbol.." ")
    local lines = {current_line}

    local curr = vim.api.nvim_win_get_cursor(0)[1]
    if not check_if_commented(lines, comment_symbol) then
        vim.api.nvim_buf_set_lines(0, curr - 1, curr, false, {comment_line})
    else
        local previous_line = current_line:sub(#comment_symbol + 2)
        vim.api.nvim_buf_set_lines(0, curr - 1, curr, false, {previous_line})
    end
end

function M.multi_line_comment()
    if is_line_empty() then return end

    M.select_comment_chunk()
    local comment = vim.api.nvim_buf_get_option(0, "commentstring")
    local comment_symbol = string.sub(comment, 1, 2)

     -- get highlighted lines 
     local line_start = vim.api.nvim_buf_get_mark(0, '<')[1]
     local line_end = vim.api.nvim_buf_get_mark(0, '>')[1]

    -- get lines
     local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)
    local comment_lines = {}

    for i, line in ipairs(lines) do
        comment_lines[i] = string.gsub(line, "^", comment_symbol.." ")
    end

    -- replace lines
    if not check_if_commented(lines, comment_symbol) then
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, comment_lines)
    else
        local previous_lines = {}
        for i, line in ipairs(lines) do
            previous_lines[i] = line:sub(#comment_symbol + 2)
        end
        vim.api.nvim_buf_set_lines(0, line_start - 1, line_end, false, previous_lines)
    end
end

function M.select_comment_chunk()
    print("select comment chunk")
    vim.cmd([[execute "normal! \<esc>"]])
    local up = vim.fn.search("\\v^(\\s*--)@!", "wbcn")
    up = up + 1
    local down = vim.fn.search("\\v^(\\s*--)@!", "wzn")
    if down ~= 0 then
        down = down - 1
    end

    local pos = vim.api.nvim_win_get_cursor(0)[1]

    if up <= down and up <= pos and down >= pos then
        vim.api.nvim_buf_set_mark(0, "<", up, 1, {})
        vim.api.nvim_buf_set_mark(0, ">", down, 1, {})
        vim.cmd([[execute "normal! `<v`>"]])
    end
end

return M
