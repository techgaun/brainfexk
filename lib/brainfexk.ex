defmodule Brainfexk do
  @moduledoc """
  A simple C code generator given the brainfuck code

  Raw code with no formatting of output source code.
  """

  @c_head """
  #include <stdio.h>

  int main(int argc, char **argv) {
    char array[30000] = {0};
    char *ptr = array;
  """

  @tokens [?+, ?-, ?<, ?>, ?,, ?., ?[, ?]]

  @tokens_map %{
    "+" => :add,
    "-" => :sub,
    "<" => :left,
    ">" => :right,
    "," => :read,
    "." => :write,
    "[" => :loop_start,
    "]" => :loop_end
  }

  @doc """
  Given a file containing bf source code, creates a C source code file at outfile.
  The default outfile path is `/tmp/out.c`.

      iex> Brainfexk.compile_file("/home/techgaun/projects/personal/brainfexk/hello.bf")
  """
  def compile_file(file, outfile \\ "/tmp/out.c") do
    out =
      file
      |> File.read!()
      |> compile()

    File.write(outfile, out)
  end

  @doc """
  Given the bf source code, generate appropriate C source code.

      iex> Brainfexk.compile("[->+<]")
  """
  def compile(source) do
    source
    |> tokenize()
    |> generate()
  end

  def tokenize(input), do: do_tokenize(input, [])

  defp do_tokenize("", tokens), do: Enum.reverse(tokens)
  defp do_tokenize(<<chr::utf8, rest::binary>>, tokens) when chr in @tokens do
    do_tokenize(rest, [@tokens_map[<<chr::utf8>>] | tokens])
  end
  defp do_tokenize(<<_::utf8, rest::binary>>, tokens), do: do_tokenize(rest, tokens)

  def generate(tokens), do: do_generate(tokens, @c_head)

  defp do_generate([], code), do: "#{code}\n  return 0;\n}"
  defp do_generate([tok | rest], code) do
    do_generate(rest, "#{code}  #{token_code(tok)}\n")
  end

  defp token_code(:add), do: "++*ptr;"
  defp token_code(:sub), do: "--*ptr;"
  defp token_code(:left), do: "--ptr;"
  defp token_code(:right), do: "++ptr;"
  defp token_code(:read), do: "*ptr = getchar();"
  defp token_code(:write), do: "putchar(*ptr);"
  defp token_code(:loop_start), do: "while (*ptr) {"
  defp token_code(:loop_end), do: "}"
end
