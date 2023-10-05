defmodule Chuuni.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    test_file_path = Path.join(Chuuni.Media.artwork_path(), to_string(System.unique_integer()))
    :ok = File.touch(test_file_path)
    :ok = File.rm(test_file_path)

    children = [
      # Start the Telemetry supervisor
      ChuuniWeb.Telemetry,
      # Start the Ecto repository
      Chuuni.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Chuuni.PubSub},
      # Start Finch
      {Finch, name: Chuuni.Finch},
      # Start the Endpoint (http/https)
      ChuuniWeb.Endpoint
      # Start a worker by calling: Chuuni.Worker.start_link(arg)
      # {Chuuni.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chuuni.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChuuniWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
