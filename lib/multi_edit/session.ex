defmodule MultiEdit.Session do
  use GenServer

  @name __MODULE__

  def start_link(_) do
    initial = %{users: %{}, fields: %{}, cursors: %{}, selections: %{}}
    GenServer.start_link(__MODULE__, initial, name: @name)
  end

  def init(state) do
    {:ok, state}
  end

  def sign_in(user) do
    GenServer.call(@name, {:sign_in, user})
  end

  def sign_out(user_id) do
    GenServer.call(@name, {:sign_out, user_id})
  end

  def select(user_id, selection) do
    defaults = %{start: 0, end: 0}
    selection = Map.merge(defaults, selection)

    GenServer.call(@name, {:select, user_id, selection})
  end

  def select_all(user_id, field_id) do
    GenServer.call(@name, {:select_all, user_id, field_id})
  end

  def select_x(user_id, field_id, delta \\ 1) do
    GenServer.call(@name, {:select_x, user_id, field_id, delta})
  end

  def select_y(user_id, field_id, delta \\ 1) do
    GenServer.call(@name, {:select_y, user_id, field_id, delta})
  end

  def insert(user_id, field_id, text) do
    GenServer.call(@name, {:insert, user_id, field_id, text})
  end

  def delete(user_id, field_id) do
    GenServer.call(@name, {:delete, user_id, field_id})
  end

  def backspace(user_id, field_id) do
    GenServer.call(@name, {:backspace, user_id, field_id})
  end

  def move_to(user_id, field_id, position) do
    GenServer.call(@name, {:move_to, user_id, field_id, position})
  end

  def move_x(user_id, field_id, delta \\ 1) do
    GenServer.call(@name, {:move_x, user_id, field_id, delta})
  end

  def move_y(user_id, field_id, delta \\ 1) do
    GenServer.call(@name, {:move_y, user_id, field_id, delta})
  end

  def handle_call({:sign_in, user}, _from, state) do
    new_state = put_in(state, [:users, user.id], user)

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:sign_out, user_id}, _from, state) do
    {_, new_state} = pop_in(state, [:users, user_id])
    {_, new_state} = pop_in(new_state, [:cursors, user_id])
    {_, new_state} = pop_in(new_state, [:selections, user_id])

    {:reply, {:ok, new_state}, new_state}
  end

  def handle_call({:select, user_id, selection}, _from, state) do
    new_state = case state.fields[selection.field] do
      nil ->
        state
        |> put_in([:fields, selection.field], "")
        |> put_in([:cursors, user_id], {selection.field, selection.end})
      _ ->
        state
    end

    new_state = if selection[:end] == selection.start do
      new_state
    else
      put_in(new_state, [:selections, user_id], selection)
    end

    {:reply, :ok, new_state}
  end

  def handle_call({:select_all, user_id, field_id}, _from, state) do
    case state.fields[field_id] do
      nil ->
        {:reply, {:error, :field}, state}

      value ->
        selection = %{field: field_id, start: 0, end: String.length(value)}
        new_state = state
                  |> put_in([:selections, user_id], selection)
                  |> put_in([:cursors, user_id], {field_id, selection.end})

        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:insert, user_id, field_id, text}, _from, state) do
    selection = get_in(state, [:selections, user_id])
    cursor = get_in(state, [:cursors, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      selection && selection.field == field_id ->
        start = String.slice(value, 0..( selection.start-1 ))
        ending = String.slice(value, selection[:end]..-1)
        new_position = String.length(start) + String.length(text)

        new_state = state
          |> put_in([:fields, field_id], start <> text <> ending)
          |> put_in([:cursors, user_id], {field_id, new_position})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      cursor && elem(cursor, 0) == field_id ->
        {_, position} = cursor
        start = String.slice(value, 0..position)
        ending = String.slice(value, position..-1)
        new_position = String.length(start) + String.length(text)

        new_state = state
          |> put_in([:fields, field_id], start <> text <> ending)
          |> put_in([:cursors, user_id], {field_id, new_position})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, { :ok, new_state }, new_state}

      true ->
        {:reply, {:error, :selection}, state}
    end
  end

  def handle_call({:delete, user_id, field_id}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    selection = get_in(state, [:selections, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      selection && selection.field == field_id ->
        start = String.slice(value, 0..( selection.start-1 ))
        ending = String.slice(value, selection[:end]..-1)
        new_value = start <> ending

        new_state = state
          |> put_in([:fields, field_id], new_value)
          |> put_in([:cursors, user_id], {field_id, selection.start})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      cursor && elem(cursor, 0) == field_id ->
        {_, position} = cursor

        new_value = cond do
          position == 0 ->
            String.slice(value, position+1..-1)

          true ->
            start = String.slice(value, 0..position-1)
            ending = String.slice(value, position+1..-1)

            start <> ending
        end

        new_state = put_in(state, [:fields, field_id], new_value)

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      true ->
        {:reply, {:ok, state}, state}
    end
  end

  def handle_call({:backspace, user_id, field_id}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    selection = get_in(state, [:selections, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      selection && selection.field == field_id ->
        start = String.slice(value, 0..(selection.start-1))
        ending = String.slice(value, selection[:end]..-1)
        new_value = start <> ending

        new_state = state
          |> put_in([:fields, field_id], new_value)
          |> put_in([:cursors, user_id], {field_id, selection.start})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      cursor && elem(cursor, 0) == field_id && elem(cursor, 1) > 0 ->
        {_, position} = cursor

        new_value = cond do
          position == 1 ->
            String.slice(value, 1..-1)

          true ->
            start = String.slice(value, 0..(position-2))
            ending = String.slice(value, position..-1)
            start <> ending
        end

        new_state = state
          |> put_in([:fields, field_id], new_value)
          |> put_in([:cursors, user_id], {field_id, position-1})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      true ->
        {:reply, {:ok, state}, state}
    end
  end

  def handle_call({:move_to, user_id, field_id, position}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        new_state = state
          |> put_in([:fields, field_id], "")
          |> put_in([:cursors, user_id], {field_id, 0})

        {:reply, {:ok, new_state}, new_state}

      true ->
        position = Enum.min([position, String.length(value)])

        new_state = put_in(state, [:cursors, user_id], {field_id, position})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}
    end
  end

  def handle_call({:move_x, user_id, field_id, delta}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      cursor && elem(cursor, 0) == field_id ->
        {_, position} = cursor
        len = String.length(value)

        new_position = cond do
          position + delta > len ->
            len
          position + delta < 0 ->
            0
          true ->
            position + delta
        end

        new_state = put_in(state, [:cursors, user_id], {field_id, new_position})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      true ->
        {:reply, {:ok, state}, state}
    end
  end

  def handle_call({:move_y, user_id, field_id, delta}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      cursor && elem(cursor, 0) == field_id ->
        {_, position} = cursor
        lines = String.split(value, "\n")
        len = length(lines)
        counts = Enum.map(lines, &String.length/1)
        {_, count_map} = counts |> Enum.with_index |> Enum.reduce({0, %{}}, fn {count, index}, {acc, map} -> {acc + count + 1, Map.put(map, index, %{count: count, offset: acc})} end)
        {line, offset} = counts |> Enum.with_index |> Enum.reduce_while(0, fn {count, line}, acc ->
          if acc + count > position do
            {:halt, {line, position - acc - line}}
          else
            {:cont, acc + count}
          end
        end)

        new_line = cond do
          line + delta + 1> len ->
            len-1
          line + delta < 0 ->
            0
          true ->
            line + delta
        end

        new_line_length = count_map[new_line].count

        offset = cond do
          offset > new_line_length ->
            new_line_length
          true ->
            offset
        end

        new_position = count_map[new_line].offset + offset

        new_state = put_in(state, [:cursors, user_id], {field_id, new_position})

        {_, new_state} = pop_in(new_state, [:selections, user_id])

        {:reply, {:ok, new_state}, new_state}

      true ->
        {:reply, { :ok, state }, state}
    end
  end

  def handle_call({:select_x, user_id, field_id, delta}, _from, state) do
    cursor = get_in(state, [:cursors, user_id])
    selection = get_in(state, [:selections, user_id])
    value = get_in(state, [:fields, field_id])

    cond do
      is_nil(value) ->
        {:reply, {:error, :field}, state}

      selection && selection.field == field_id ->
        {_, cursor_position} = cursor
        ending = Enum.min([selection[:end]+delta, String.length(value)])

        new_state = cond do
          cursor_position == selection[:end] ->
            new_state = state
              |> put_in([:selections, user_id], %{field: field_id, start: selection.start, end: ending})
              |> put_in([:cursors, user_id], {field_id, ending})

            new_state

          cursor_position == selection[:start] ->
            new_state = state
              |> put_in([:selections, user_id], %{field: field_id, start: selection.start+delta, end: selection[:end]})
              |> put_in([:cursors, user_id], {field_id, selection.start+delta})

            new_state
        end

        selection = get_in(new_state, [:selections, user_id])

        new_state = cond do
          selection.end < selection.start ->
            put_in(new_state, [:selections, user_id], %{field: field_id, start: selection.end, end: selection.start})
          selection.start == selection[:end] ->
            {_, new_state} = pop_in(new_state, [:selections, user_id])
            new_state

          true ->
            new_state
        end

        {:reply, {:ok, new_state}, new_state}

      cursor && elem(cursor, 0) == field_id ->
        {_, position} = cursor
        ending = Enum.min([position+delta, String.length(value)])

        new_state = state
          |> put_in([:selections, user_id], %{field: field_id, start: position, end: ending})
          |> put_in([:cursors, user_id], {field_id, position+delta})

        {:reply, {:ok, new_state}, new_state}

      true ->
        min = Enum.min([delta, String.length(value)])

        new_state = state
          |> put_in([:selections, user_id], %{field: field_id, start: 0, end: min})
          |> put_in([:cursors, user_id], {field_id, delta})

        {:reply, {:ok, new_state}, new_state}
    end
  end
end
