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

  end

  @doc """
  Given a supervisor pid and a child specification,
  start the child process and link it to the supervisor.
  """
  def start_child(supervisor, child_spec) do

  end

  @doc """
  Given a supervisor pid and a child pid, terminate
  the child.
  """
  def terminate_child(supervisor, pid) do

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
end
