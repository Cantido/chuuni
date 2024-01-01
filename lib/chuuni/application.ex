defmodule Chuuni.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    test_artwork_path()
    Chuuni.Media.Anilist.register_fragments()

    children = [
      Chuuni.Vault,
      # Start the Telemetry supervisor
      ChuuniWeb.Telemetry,
      # Start the Ecto repository
      Chuuni.Repo,
      # Start the Oban job runner
      {Oban, Application.fetch_env!(:chuuni, Oban)},
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

  defp test_artwork_path do
    artwork_path = Chuuni.Media.artwork_path()

    unless File.exists?(artwork_path) do
      raise "expected $CHUUNI_ARTWORK_PATH (#{inspect artwork_path}) to point to a directory, but there is nothing there."
    end

    stat = File.stat!(artwork_path)

    unless stat.type == :directory do
      raise "expected $CHUUNI_ARTWORK_PATH (#{inspect artwork_path}) to point to a directory, but it points to a #{stat.type}."
    end

    test_file_path = Path.join(artwork_path, ".tmp." <> to_string(System.unique_integer()))
    case File.touch(test_file_path) do
      :ok ->
        File.rm!(test_file_path)
      {:error, err} ->
        raise "expected $CHUUNI_ARTWORK_PATH (#{inspect artwork_path}) to be writeable but got error: #{err}"
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChuuniWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
