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

  end

  @doc """
  Given the supervisor pid, return the number of
  child processes.
  """
  def count_children(supervisor) do

  end

  @doc """
  Given the supervisor pid, return the state of the
  supervisor.
  """
  def which_children(supervisor) do

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

  def handle_info({:EXIT, from, reason}, state) do
    {:noreply, Map.delete(state, from)}
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
end
