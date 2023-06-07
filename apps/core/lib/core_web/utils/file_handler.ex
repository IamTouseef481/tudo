defmodule CoreWeb.Utils.FileHandler do
  @moduledoc false

  @lang_paths ["en", "hi", "es", "ur", "te"]

  def read_translations_slug_file(file \\ "apps/core/priv/gettext/screens_and_slugs.csv") do
    file
    |> Path.absname()
    |> File.stream!()
    |> CSV.decode()
    #    |> Enum.filter(fn a -> if {:ok, _} = a, do: true end)
    |> make_translation_slugs_map()
  end

  def write_csvs_to_po do
    Enum.each(@lang_paths, fn path ->
      write_to_po_file(
        "apps/core/priv/gettext/#{path}.csv",
        "apps/core/priv/gettext/#{path}/LC_MESSAGES/general.po"
      )
    end)
  end

  def write_to_po_file(
        reading_file \\ "english-language.csv",
        writing_file \\ "apps/core/priv/gettext/en/LC_MESSAGES/general.po"
      ) do
    reading_file
    |> Path.absname()
    |> File.stream!()
    |> CSV.decode()
    |> write_translations_to_po_file(writing_file)
  end

  defp make_translation_slugs_map(file_data) do
    file_data
    |> Enum.reduce(%{"prev_screen" => ""}, fn
      {:ok, [screen | [slug | _]]}, %{"prev_screen" => prev_screen} = acc ->
        case screen do
          "" ->
            slug_val =
              if slug in ["title", "update_title"], do: prev_screen <> "_" <> slug, else: slug

            updated_slugs =
              Map.merge(acc["#{prev_screen}"], %{"#{slug}" => %{"translation" => "#{slug_val}"}})

            Map.merge(acc, %{"#{prev_screen}" => updated_slugs})

          _ ->
            slug_val = if slug in ["title", "update_title"], do: screen <> "_" <> slug, else: slug

            if Map.has_key?(acc, "#{screen}") do
              updated_slugs =
                Map.merge(acc["#{prev_screen}"], %{"#{slug}" => %{"translation" => "#{slug_val}"}})

              Map.merge(acc, %{"#{screen}" => updated_slugs})
            else
              Map.merge(acc, %{
                "#{screen}" => %{"#{slug}" => %{"translation" => "#{slug_val}"}},
                "prev_screen" => screen
              })
            end
        end

      _, acc ->
        acc
    end)
    |> Map.delete("prev_screen")

    #    |> Enum.reduce([], fn {_, list}, acc -> acc ++ Map.keys(list) end)
    #    |> Enum.count()
  end

  defp write_translations_to_po_file(file_data, file) do
    {:ok, opened_file} = File.open(file, [:append])

    remove_repeating_msg_ids(file_data)
    |> Enum.each(fn {:ok, [screen | [msgid | [msgstr | _]]]} ->
      msgid = if msgid in ["title", "update_title"], do: screen <> "_" <> msgid, else: msgid
      IO.binwrite(opened_file, ~s(msgid "#{msgid}"\nmsgstr "#{msgstr}"\n\n))
    end)

    File.close(opened_file)
  end

  defp remove_repeating_msg_ids(file_data) do
    Enum.filter(file_data, fn
      {:ok, _} -> true
      _ -> false
    end)
    |> Enum.uniq_by(fn {:ok, [screen | [msgid | _]]} ->
      if msgid in ["title", "update_title"], do: screen <> "_" <> msgid, else: msgid
    end)
  end

  def sort_list(list) do
    Enum.reduce(list, %{list: [], inner_list: list}, fn x,
                                                        %{
                                                          list: sorted_list,
                                                          inner_list: inner_list
                                                        } = acc ->
      min =
        Enum.reduce(inner_list, x, fn y, accumulator ->
          if y > accumulator do
            y
          else
            accumulator
          end
        end)

      Map.merge(acc, %{list: sorted_list ++ [min], inner_list: List.delete(inner_list, min)})
    end)
  end
end
