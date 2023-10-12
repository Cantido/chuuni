defmodule ChuuniWeb.Router do
  use ChuuniWeb, :router

  import ChuuniWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug ChuuniWeb.HTMXPlug
    plug :htmx_layout
    plug :cache_control
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  require Logger

  def htmx_layout(conn, _opts) do
    if get_in(conn.assigns, [:htmx, :request]) do
      conn = put_root_layout(conn, html: false)

      if conn.assigns.htmx[:boosted] or conn.assigns.htmx[:history_restore_request] do
        put_layout(conn, html: {ChuuniWeb.Layouts, :app})
      else
        put_layout(conn, html: false)
      end
    else
      conn
      |> put_root_layout(html: {ChuuniWeb.Layouts, :root})
      |> put_layout(html: {ChuuniWeb.Layouts, :app})
    end
  end

  def cache_control(conn, _opts) do
    put_resp_header(conn, "vary", "hx-request accept accept-encoding accept-language")
  end

  scope "/", ChuuniWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/users/menu", UserSessionController, :menu
    get "/search", PageController, :search
    get "/top", PageController, :top

    get "/anime/search", AnimeController, :search

    scope "/users" do
      get "/reset_password", User.PasswordResetController, :index
      post "/reset_password/send_instructions", User.PasswordResetController, :send_reset_instructions
      get "/reset_password/token/:token", User.PasswordResetController, :password_reset_form
      post "/reset_password/update", User.PasswordResetController, :update_password

      get "/register", UserController, :new
      post "/create", UserController, :create
    end
  end

  scope "/", ChuuniWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/shelves", ShelfController do
      post "/move", ShelfController, :move
    end
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

    scope "/users" do
      get "/log_in", UserSessionController, :new
      get "/log_in/form", UserSessionController, :form
      post "/log_in", UserSessionController, :create
    end

  end

  scope "/", ChuuniWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
    get "/users/settings", UserSettingsController, :edit
    post "/users/settings/email", UserSettingsController, :update_email
    get "/users/settings/email/edit", UserSettingsController, :edit_email
    post "/users/settings/password", UserSettingsController, :update_password
  end

  scope "/", ChuuniWeb do
    pipe_through [:browser]

    get "/users/log_out", UserSessionController, :delete
    delete "/users/log_out", UserSessionController, :delete

    get "/users/confirm/:token", User.ConfirmationController, :confirm_form
    post "/users/confirm", User.ConfirmationController, :confirm
    post "/users/confirm/send", User.ConfirmationController, :send_confirm_email
    get "/users/confirm", User.ConfirmationController, :confirmation_instructions

    get "/@:username", UserProfileController, :profile
  end
end
