defmodule Library.InfosFetcher.Dispatcher do
  use GenServer
  require Logger

  alias Kaur.Result
  alias Library.InfosFetcher.Worker

  @worker_amount 2

  defstruct [:tasks_queue, :tasks_state, :tasks_results, :tasks_errors, :available_workers]

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    state =
      %__MODULE__{
        tasks_queue: [],
        tasks_state: :in_progress,
        tasks_results: [],
        available_workers: @worker_amount
      }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast({:add_path, path}, state) do
    Logger.info "Infos Fetcher adding path and its children : #{path}"
    state = %{
      state
      | tasks_queue: [{:fetch_infos, path} | state.tasks_queue]
    }

    try_to_work(state)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:infos_fetched, {path, res}}, state) do
    handle_success = fn res ->
      case res do
        {:dir, children} ->
          children
          |> Enum.map(fn child_path ->
            complete_child_path = Path.join(path, child_path)
            {:fetch_infos, complete_child_path}
          end)
          |> (fn tasks ->
                Enum.concat([state.tasks_queue, tasks])
              end).()
          |> (fn tasks ->
                %{state | tasks_queue: tasks}
              end).()

        _ ->
          %{
            state
            | tasks_results: [{path, res} | state.tasks_results]
          }
      end
    end

    handle_failure = fn res -> %{state | tasks_errors: [{path, res}]} end

    new_state =
      res
      |> Result.either(handle_failure, handle_success)
      |> Map.update!(:available_workers, &(&1 + 1))
      |> try_to_work()

    {:noreply, new_state}
  end

  def try_to_work(%{tasks_queue: tasks_queue, available_workers: available_workers} = state) do
    case {tasks_queue, available_workers} do
      {[], @worker_amount} ->
        Logger.info("Library.InfosFetcher.Dispatcher has finished its work #{inspect(self())}")

      {[], _} ->
        %{state | tasks_state: :done}

      {_, 0} ->
        state

      {[{:fetch_infos, path} | tasks_queue], available_workers} ->
        spawn(fn -> Worker.fetch_infos(path) end)
        %{state | tasks_queue: tasks_queue, available_workers: available_workers - 1}
    end
  end
end
