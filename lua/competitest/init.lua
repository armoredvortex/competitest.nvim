local config = require("competitest.config")
local competitest_loaded = false
local M = {}

---Setup CompetiTest
---@param opts competitest.Config? CompetiTest configuration provided by user
function M.setup(opts)
	config.current_setup = config.update_config_table(config.current_setup, opts)

	if not competitest_loaded then
		competitest_loaded = true

		-- CompetiTest command
		vim.cmd([[
    function! s:command_completion(_, CmdLine, CursorPos) abort
      let prefix = a:CmdLine[:a:CursorPos]
      let ending_space = prefix[-1:-1] == " "
      let words = split(prefix)
      let wlen = len(words)

      " first word completion (subcommand)
      if wlen == 1 || wlen == 2 && !ending_space
        return "add_testcase\nedit_testcase\ndelete_testcase\nconvert\nrun\nrun_no_compile\nshow_ui\nreceive\nsubmit"
      " second word completion (sub-args)
      elseif wlen == 2 || wlen == 3 && !ending_space
        if wlen == 2
          let lastword = words[-1]
        else
          let lastword = words[-2]
        endif

        if lastword == "convert"
          return "auto\nfiles_to_singlefile\nsinglefile_to_files"
        elseif lastword == "receive"
          return "testcases\nproblem\ncontest\npersistently\nstatus\nstop"
        endif
      endif
      return ""
    endfunction
    command! -bar -nargs=* -complete=custom,s:command_completion CompetiTest lua require("competitest.commands").command(<q-args>)
    ]])

		-- create highlight groups
		M.setup_highlight_groups()
		vim.api.nvim_command("autocmd ColorScheme * lua require('competitest').setup_highlight_groups()")

		-- resize ui autocommand
		vim.api.nvim_command("autocmd VimResized * lua require('competitest').resize_ui()")

		-- start receiving persistently if required
		if config.current_setup.start_receiving_persistently_on_setup then
			if vim.v.vim_did_enter == 1 then
				require("competitest.commands").receive("persistently")
			else
				vim.api.nvim_command("autocmd VimEnter * lua require('competitest.commands').receive('persistently')")
			end
		end
	end
end

---Resize CompetiTest user interface if visible
function M.resize_ui()
	vim.schedule(function()
		require("competitest.widgets").resize_widgets()
		for _, r in pairs(require("competitest.commands").runners) do
			r:resize_ui()
		end
	end)
end

---Create CompetiTest highlight groups
function M.setup_highlight_groups()
	local highlight_groups = {
		{ "CompetiTestRunning", "cterm=bold gui=bold" },
		{ "CompetiTestDone", "cterm=none gui=none" },
		{ "CompetiTestCorrect", "ctermfg=green guifg=#00ff00" },
		{ "CompetiTestWarning", "ctermfg=yellow guifg=orange" },
		{ "CompetiTestWrong", "ctermfg=red guifg=#ff0000" },
	}
	for _, hl in ipairs(highlight_groups) do
		vim.api.nvim_command("hi! def " .. hl[1] .. " " .. hl[2])
	end
end

---Submit current buffer to Codeforces via CPH browser extension
---Requires a comment in the file:
---   // problem-url: https://codeforces.com/problemset/problem/1927/D
function M.submit()
	local bufnr = api.nvim_get_current_buf()
	config.load_buffer_config(bufnr)
	local cfg = config.get_buffer_config(bufnr)

	-- 1) Read buffer lines & full source
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local source = table.concat(lines, "\n")

	-- 2) Extract problem URL from comment
	local url
	for _, line in ipairs(lines) do
		-- C++-style comment: // problem-url: <url>
		local m = line:match("//%s*problem%-url:%s*(%S+)")
		if m then
			url = m
			break
		end
	end

	if not url then
		utils.notify("submit: problem url comment not found. Expected '// problem-url: <url>'", "ERROR")
		return
	end

	-- 3) Derive problemName like '1927D' from Codeforces URL
	local contest, index = url:match("/contest/(%d+)/problem/(%u+)")
	if not contest then
		local c2, i2 = url:match("/problemset/problem/(%d+)/(%u+)")
		if c2 and i2 then
			contest, index = c2, i2
		end
	end

	local problemName = ""
	if contest and index then
		problemName = contest .. index
	end

	-- 4) Detect filetype -> CF languageId
	local ft = vim.bo[bufnr].filetype or vim.bo.filetype
	local lang_map = {
		cpp = 91, -- GNU++17
		c = 43, -- GNU C11 (common CF ID)
		cxx = 91,
		cc = 91,
		python = 31, -- Python 3
		python3 = 31,
		java = 36, -- Java 11
	}

	local languageId = lang_map[ft]
	if not languageId then
		utils.notify("submit: unsupported filetype '" .. tostring(ft) .. "' for Codeforces languageId mapping.", "ERROR")
		return
	end

	-- 5) Fill payload into competitest.receive global
	local receive = require("competitest.receive")
	receive.submit_payload = {
		empty = false,
		url = url,
		problemName = problemName,
		sourceCode = source,
		languageId = languageId,
	}

	-- 6) Ensure HTTP server is running on cfg.companion_port
	--    We use a special 'submit' mode that just keeps the server alive;
	--    /getSubmit is handled inside receive.lua's Receiver.
	local err = receive.start_receiving("submit", cfg.companion_port, false, false, nil, cfg)
	if err and err ~= "receiving already enabled, stop it if you want to change receive mode" then
		utils.notify("submit: " .. err, "ERROR")
		return
	end

	utils.notify("CFSubmit: waiting for browser to collect payload…", "INFO")
end

return M
