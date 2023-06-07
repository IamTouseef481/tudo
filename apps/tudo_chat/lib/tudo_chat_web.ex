defmodule TudoChatWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TudoChatWeb, :controller
      use TudoChatWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TudoChatWeb
      import Sage
      import Plug.Conn
      import TudoChatWeb.Gettext
      import TudoChatWeb.Utils.{Helpers, Errors, CommonFunctions}
      alias TudoChatWeb.Router.Helpers, as: Routes
      use TudoChatWeb.Kernel
      use TudoChatWeb.Controller
    end
  end

  def chat_helper do
    quote do
      require IEx
      import Sage
      import TudoChatWeb.Utils.{Helpers, Errors, CommonFunctions}
    end
  end

  def chat_resolver do
    quote do
      import TudoChatWeb.Utils.{Helpers, Errors, CommonFunctions}
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/tudo_chat_web",
        namespace: TudoChatWeb

      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML
      import TudoChatWeb.Views.ErrorHelpers
      import TudoChatWeb.Gettext
      alias TudoChatWeb.Router.Helpers, as: Routes
      use TudoChatWeb.Kernel
      use TudoChatWeb.View
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import TudoChatWeb.Gettext
      import TudoChatWeb.Utils.Errors
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
