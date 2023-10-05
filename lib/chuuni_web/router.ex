defmodule ChuuniWeb.Router do
  use ChuuniWeb, :router

  import ChuuniWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChuuniWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug ChuuniWeb.HTMXPlug
    plug :htmx_bare_layout
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  def htmx_bare_layout(conn, _opts) do
    if conn.assigns[:htmx] do
      put_root_layout(conn, html: false)
    else
      conn
    end
  end

  scope "/", ChuuniWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/search", PageController, :search

    get "/anime/search", AnimeController, :search
  end

  scope "/", ChuuniWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/reviews", ReviewController
    get "/anime/new", AnimeController, :new
    post "/anime/import", AnimeController, :import

    scope "/anime/:anime_id" do
      get "/summary_card", AnimeController, :summary_card
      get "/edit", AnimeController, :edit
      put "/", AnimeController, :update

      resources "/reviews", ReviewController, only: [:new, :create]
    end
  end

  scope "/", ChuuniWeb do
    pipe_through :browser

    resources "/anime", AnimeController, only: [:show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChuuniWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chuuni, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChuuniWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ChuuniWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ChuuniWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ChuuniWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ChuuniWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ChuuniWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ChuuniWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope "/", ChuuniWeb do
    pipe_through :browser

    # must go after the other /users paths
    get "/users/:username", UserProfileController, :profile
  end
end
