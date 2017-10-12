defmodule SpySupervisor do
  @moduledoc """
  SpySupervisor is an implementation of a Supervisor using the GenServer behaviour.
  """
  use GenServer

  #######
  # API #
  #######

  @doc """
  Given a list of child specifications (possibly empty),
  start the supervisor process and corresponding
  children
  """
  def start_link(child_spec_list) do
    GenServer.start_link __MODULE__, [child_spec_list]
  end

  @doc """
  Given a supervisor pid and a child specification,
  start the child process and link it to the supervisor.
  """
  def start_child(supervisor, child_spec) do
    GenServer.call supervisor, {:start_child, child_spec}
  end

  @doc """
  Given a supervisor pid and a child pid, terminate
  the child.
  """
  def terminate_child(supervisor, pid) do
    GenServer.call supervisor, {:terminate_child, pid}
  end

  @doc """
  Given a supervisor pid, child pid, and a child
  specification, restart the child process and initialize
  the child process with the child specification.
  """
  def restart_child(supervisor, pid, child_spec) do
    GenServer.call supervisor, {:restart_child, pid, child_spec}
  end

  @doc """
  Given the supervisor pid, return the number of
  child processes.
  """
  def count_children(supervisor) do
    GenServer.call supervisor, :count_children
  end

  @doc """
  Given the supervisor pid, return the state of the
  supervisor.
  """
  def which_children(supervisor) do
    GenServer.call supervisor, :which_children
  end

  ######################
  # CALLBACK FUNCTIONS #
  ######################

  def init([child_spec_list]) do
    Process.flag(:trap_exist, true)
    state = child_spec_list
    |> start_children
    |> Enum.into(%{})
    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        state = Map.put(pid, child_spec)
        {:reply, {:ok, pid}, state}
      :error ->
        {:reply, {:error, "Error starting child"}, state}
    end
  end

  def handle_call({:terminate_child, pid}, _from, state) do
    case terminate_child(pid) do
      :ok ->
        new_state = Map.delete(state, pid)
        {:reply, :ok, new_state}
      :error ->
        {:reply, {:error, "Error terminating child"}, state}
    end
  end

  def handle_call({:restart_child, old_pid, child_spec}, _from, state) do
    case Map.fetch(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state = state
            |> Map.delete(old_pid)
            |> Map.put(pid, child_spec)
            {:reply, {:ok, pid}, new_state}
          :error ->
            {:reply, {:error, "Error restarting child"}, state}
        end
      :error ->
        {:reply, {:error, "There is no child with pid #{inspect old_pid}"}, state}
    end
  end

  def handle_call(:count_children, _from, state) do
    {reply, Enum.count(state), state}
  end

  def handle_call(:which_children, _from, state) do
    {reply, state, state}
  end

  def handle_info({:EXIT, pid, :killed}, state) do
    {:no_reply, Map.delete(state, pid)}
  end

  def handle_info({:EXIT, pid, :normal}, state) do
    {:no_reply, Map.delete(state, pid)}
  end

  def handle_info({:EXIT, old_pid, _reason}, state) do
    case Map.fetch(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state = state
                        |> Map.delete(old_pid)
                        |> Map.put(pid, child_spec)
            {:no_reply, new_state}
          :error ->
            {:no_reply, state}
        end
      :error ->
        {:no_reply, state}
    end
  end

  def terminate(reason, state) do
    terminate_children(state)
    :ok
  end

  ###########
  # HELPERS #
  ###########

  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]
      :error ->
        {:error, "Error starting the children"}
    end
  end
  defp start_children([]), do: []

  defp start_child({mod, func, args}) do
    case apply(mod, func, args) do
      pid when is_pid(pid) ->
        Process.link(pid)
        {:ok, pid}
      _ ->
        :error
    end
  end

  defp terminate_child(pid) do
    case Process.exit(pid, :kill) do
      true ->
        :ok
      _ ->
        :error
    end
  end

  defp terminate_children(%{}), do: %{}
  defp terminate_children(state) do
    state |> Enum.each(fn {pid, cihld_spec} -> terminate_child(pid) end)
  end

  defp restart_child(pid, child_spec) do
    case terminate_child(pid) do
      :ok ->
        case start_child(child_spec) do
          {:ok, pid} ->
            {:ok, {pid, child_spec}}
          :error ->
            :error
        end
      :error ->
        :error
    end
  end
end
