# This can be used in places where setting environment variables is not feasible
# e.g. in IDEs
Code.require_file("dotenv_parser.exs", "priv/config")

defmodule ConfigParser do
  def parse_env(mix_env) do
    for ext <- ["", ".local"] do
      filename = "e.env.#{mix_env}#{ext}"
      IO.puts("Parsing '#{filename}'")

      try do
        DotenvParser.load_file(".env.#{mix_env}#{ext}")
      rescue
        File.Error ->
          IO.puts("FILE #{filename} NOT FOUND, skpping")
      end
    end
  end
end
