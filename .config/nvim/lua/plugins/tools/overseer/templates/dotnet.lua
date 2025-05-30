return {
  -----------
  -- Build --
  -----------
  {
    name = "Build",
    builder = function(params)
      return {
        cmd = "dotnet build  " .. params.project,
        components = {
          "default",
          "unique",
          {
            "on_output_parse",
            parser = {
              diagnostics = {
                {
                  "extract",
                  "^(.+%.cs)%((%d+),(%d+)%)%: (%w+) ([%w%d]+)%: (.+)%[(.+)%]$",
                  "filename",
                  "lnum",
                  "col",
                  "severity",
                  "code",
                  "text",
                  "module",
                },
              },
            },
          },
          { "on_result_diagnostics_quickfix", open = true },
        },
      }
    end,
    condition = {
      filetype = { "cs", "csproj", "sln" },
    },
    params = {
      project = {
        type = "string",
        optional = false,
        default = "Backend",
        desc = "Path to project or solution",
      },
    },
  },
  ---------
  -- Run --
  ---------
  {
    name = "Run",
    builder = function(params)
      return {
        cmd = "dotnet run --project " .. params.project,
        components = {
          "default",
          "unique",
        },
      }
    end,
    condition = {
      filetype = { "cs", "csproj", "sln" },
    },
    params = {
      project = {
        type = "string",
        optional = false,
        desc = "Path to project or solution",
      },
    },
  },
  -- mk_dotnet_task("dotnet test", { "dotnet", "test" }),
  -- mk_dotnet_task("dotnet watch run", { "dotnet", "watch", "run" }),
}
