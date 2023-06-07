# defmodule CoreWeb.Plugs.Authorization do
#  @moduledoc false
#  @behaviour Plug
#
#  import Plug.Conn
#
#  def init(default), do: default
#
#  def call(conn, _) do
#    [res, action, id] = entityParams(conn)
#    rule = Acl.has_access(role_id, conn.method, res, conn.params)
#  end
#
#  def entityParams(conn) doa
#    last_path_item = hd(Enum.take(conn.path_info, -1))
#    second_last_path_item = hd(Enum.take(conn.path_info, -2))
#    third_last_path_item = hd(Enum.take(conn.path_info, -3))
#    if second_last_path_item != "v1" do
#      if third_last_path_item != "v1" do
#        [third_last_path_item, second_last_path_item, last_path_item]
#      else
#        [second_last_path_item, last_path_item, last_path_item]
#      end
#    else
#      [last_path_item, nil, nil]
#    end
#  end
#
# end
