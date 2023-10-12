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
    get "/search", PageController, :search
    get "/top", PageController, :top

    get "/register", UserController, :new
    post "/register", UserController, :create

    resources "/shelves", ShelfController
    resources "/reviews", ReviewController

    scope "/anime" do
      get "/search", AnimeController, :search
      post "/import", AnimeController, :import

      resources "/", AnimeController, except: [:delete] do
        resources "/reviews", ReviewController, only: [:new, :create]
      end
    end

    get "/@:username", UserProfileController, :profile

    scope "/users" do
      get "/menu", UserSessionController, :menu

      get "/log_in", UserSessionController, :new
      post "/log_in", UserSessionController, :create
      get "/log_out", UserSessionController, :delete
      delete "/log_out", UserSessionController, :delete

      scope "/reset_password" do
        get "/", User.PasswordResetController, :index
        post "/send_instructions", User.PasswordResetController, :send_reset_instructions
        get "/token/:token", User.PasswordResetController, :password_reset_form
        post "/update", User.PasswordResetController, :update_password
      end

      scope "/settings" do
        get "/", UserSettingsController, :edit
        get "/confirm_email/:token", UserSettingsController, :confirm_email
        post "/email", UserSettingsController, :update_email
        get "/email/edit", UserSettingsController, :edit_email
        post "/password", UserSettingsController, :update_password
      end

      scope "/confirm" do
        get "/", User.ConfirmationController, :confirmation_instructions
        post "/", User.ConfirmationController, :confirm
        get "/:token", User.ConfirmationController, :confirm_form
        post "/send", User.ConfirmationController, :send_confirm_email
      end
    end
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
end
