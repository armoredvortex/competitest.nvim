A [competitest.nvim](https://github.com/xeluxee/competitest.nvim) fork with the ability to submit solutions using **CPH Submit**.


## Installation instructions

1) Download the [Competitive Companion](https://github.com/jmerle/competitive-companion) and the [CPH Submit](https://github.com/agrawal-d/cph-submit) browser extensions.

2) Install the plugin using your preferred plugin manager. For example, using lazy.nvim:

```lua
return {
  "armoredvortex/competitest.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  keys = {
    -- Testcases
    { "<leader>rt", "<cmd>CompetiTest run<cr>", desc = "Run Testcases" },
    { "<leader>ra", "<cmd>CompetiTest add_testcase<cr>", desc = "Add Testcase" },
    { "<leader>re", "<cmd>CompetiTest edit_testcase<cr>", desc = "Edit Testcase" },
    -- Fetch problem / contest
    { "<leader>pf", "<cmd>CompetiTest receive problem<cr>", desc = "Fetch Problem" },
    { "<leader>pc", "<cmd>CompetiTest receive contest<cr>", desc = "Fetch Contest" },
    { "<leader>ps", "<cmd>CompetiTest submit<cr>", desc = "Submit Problem" },
  },
  config = function()
    require("competitest").setup({
      -- Local config file support
      local_config_file_name = ".competitest.lua",

      floating_border = "rounded",
      floating_border_highlight = "FloatBorder",

      -- Picker UI for selecting testcases
      picker_ui = {
        width = 0.2,
        height = 0.3,
        mappings = {
          focus_next = { "j", "<down>", "<Tab>" },
          focus_prev = { "k", "<up>", "<S-Tab>" },
          close = { "<esc>", "<C-c>", "q", "Q" },
          submit = "<cr>",
        },
      },

      -- Editor UI for adding/editing testcases
      editor_ui = {
        popup_width = 0.4,
        popup_height = 0.6,
        show_nu = true,
        show_rnu = false,
        normal_mode_mappings = {
          switch_window = { "<C-h>", "<C-l>", "<C-i>" },
          save_and_close = "<C-s>",
          cancel = { "q", "Q" },
        },
        insert_mode_mappings = {
          switch_window = { "<C-h>", "<C-l>", "<C-i>" },
          save_and_close = "<C-s>",
          cancel = "<C-q>",
        },
      },

      -- Runner UI for viewing test results
      runner_ui = {
        interface = "popup",
        selector_show_nu = false,
        selector_show_rnu = false,
        show_nu = true,
        show_rnu = false,
        mappings = {
          run_again = "R",
          run_all_again = "<C-r>",
          kill = "K",
          kill_all = "<C-k>",
          view_input = { "i", "I" },
          view_output = { "a", "A" },
          view_stdout = { "o", "O" },
          view_stderr = { "e", "E" },
          toggle_diff = { "d", "D" },
          close = { "q", "Q" },
        },
        viewer = {
          width = 0.5,
          height = 0.5,
          show_nu = true,
          show_rnu = false,
          open_when_compilation_fails = true,
        },
      },

      -- Popup UI layout
      popup_ui = {
        total_width = 0.8,
        total_height = 0.8,
        layout = {
          { 4, "tc" },
          { 5, { { 1, "so" }, { 1, "si" } } },
          { 5, { { 1, "eo" }, { 1, "se" } } },
        },
      },

      -- Split UI layout (alternative to popup)
      split_ui = {
        position = "right",
        relative_to_editor = true,
        total_width = 0.3,
        vertical_layout = {
          { 1, "tc" },
          { 1, { { 1, "so" }, { 1, "eo" } } },
          { 1, { { 1, "si" }, { 1, "se" } } },
        },
        total_height = 0.4,
        horizontal_layout = {
          { 2, "tc" },
          { 3, { { 1, "so" }, { 1, "si" } } },
          { 3, { { 1, "eo" }, { 1, "se" } } },
        },
      },

      -- File saving behavior
      save_current_file = true,
      save_all_files = false,

      -- Compilation settings
      compile_directory = ".",
      compile_command = {
        c = { exec = "gcc", args = { "-Wall", "$(FNAME)", "-o", "$(FNOEXT)" } },
        cpp = { exec = "g++", args = { "-Wall", "-std=c++17", "$(FNAME)", "-O2", "-o", "$(FNOEXT)" } },
        cxx = { exec = "g++", args = { "-Wall", "-std=c++17", "$(FNAME)", "-O2", "-o", "$(FNOEXT)" } },
        rust = { exec = "rustc", args = { "$(FNAME)" } },
        java = { exec = "javac", args = { "$(FNAME)" } },
      },

      -- Running settings
      running_directory = ".",
      run_command = {
        c = { exec = "./$(FNOEXT)" },
        cpp = { exec = "./$(FNOEXT)" },
        cxx = { exec = "./$(FNOEXT)" },
        rust = { exec = "./$(FNOEXT)" },
        python = { exec = "python", args = { "$(FNAME)" } },
        java = { exec = "java", args = { "$(FNOEXT)" } },
      },

      -- Testing behavior
      multiple_testing = -1,
      maximum_time = 5000,
      output_compare_method = "squish",
      view_output_diff = false,

      -- Testcases storage
      testcases_directory = "./testcases",
      testcases_use_single_file = false,
      testcases_auto_detect_storage = true,
      testcases_single_file_format = "$(FNOEXT).testcases",
      testcases_input_file_format = "$(FNOEXT)_input$(TCNUM).txt",
      testcases_output_file_format = "$(FNOEXT)_output$(TCNUM).txt",

      -- Competitive Companion integration
      companion_port = 27121,
      receive_print_message = true,
      start_receiving_persistently_on_setup = false,

      -- Template settings
      template_file = "~/.config/nvim/competitest/templates/cpp.tpl",
      evaluate_template_modifiers = true,
      date_format = "%c",

      -- Received files settings
      received_files_extension = "cpp",

      -- Store fetched problems here (your custom settings preserved)
      received_problems_path = "problems/$(PROBLEM).$(FEXT)",
      received_problems_prompt_path = false,
      open_received_problems = true,
      replace_received_testcases = false,

      -- Store fetched contests here (your custom settings preserved)
      received_contests_directory = "contests",
      received_contests_problems_path = "$(PROBLEM).$(FEXT)",
      received_contests_prompt_directory = false,
      received_contests_prompt_extension = false,
      open_received_contests = true,
    })
  end,
}
```

3) Create the template file at `~/.config/nvim/competitest/templates/cpp.tpl` (or your preferred path) and make sure it has problem-url in comments like so:

```cpp
// problem-url: $(URL)
```

## Usage
- Use `<leader>pf` to fetch a problem using Competitive Companion.
- Use `<leader>pc` to fetch a contest using Competitive Companion.
- Use `<leader>rt` to run testcases.
- Use `<leader>ps` to submit the solution using CPH Submit.