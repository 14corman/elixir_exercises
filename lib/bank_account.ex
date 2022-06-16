defmodule Exercises.BankAccount do
  @moduledoc """
  A bank account that supports access from multiple processes.
  """

  defmodule Account do
    @moduledoc """
    An account that can be started, stopped, checked, and have transactions made on
    it within the BankAccount.

    All GenServer calls are synchronous so that a user cannot get a balance before 
    a transaction is made, and transactions are made back-to-back.
    """

    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [])
    end

    @impl true
    def init([]) do
      {:ok, %{balance: 0}}
    end

    def balance(pid) do
      GenServer.call(pid, :balance)
    end

    @impl true
    def handle_call(:balance, _from, %{balance: balance} = state) do
      {:reply, balance, state}
    end

    def update(pid, value) do
      GenServer.call(pid, {:update, value})
    end

    @impl true
    def handle_call({:update, value}, _from, %{balance: balance} = state) do

      new_balance = balance + value
      new_state = %{balance: new_balance}

      {:reply, new_balance, new_state}
    end
  end

  @typedoc """
  An account handle.
  """
  @opaque account :: pid

  @doc """
  Open the bank. Makes the account available.
  """
  @spec open_bank() :: account
  def open_bank() do
    {:ok, pid} = Account.start_link()
    pid
  end

  @doc """
  Close the bank. Makes the account unavailable.
  """
  @spec close_bank(account) :: none
  def close_bank(account) do
    :ok = GenServer.stop(account)
  end

  @doc """
  Get the account's balance.
  """
  @spec balance(account) :: integer
  def balance(account) do
    if Process.alive?(account) do
      Account.balance(account)
    else
      {:error, :account_closed}
    end
  end

  @doc """
  Update the account's balance by adding the given amount which may be negative.
  """
  @spec update(account, integer) :: any
  def update(account, amount) do
    if Process.alive?(account) do
      Account.update(account, amount)
    else
      {:error, :account_closed}
    end
  end
end