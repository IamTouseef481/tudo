defmodule TudoChatWeb.GroupControllerTest do
  use TudoChatWeb.ConnCase

  alias TudoChat.Groups

  @create_attrs %{
    add_members: true,
    allow_pvt_message: true,
    editable: true,
    expires_by_date: "2010-04-17T14:00:00Z",
    forward: true,
    group_type: "some group_type",
    is_active: true,
    name: "some name",
    profile_pic: "some profile_pic",
    reference_id: 42,
    service_request_id: 42
  }
  @update_attrs %{
    add_members: false,
    allow_pvt_message: false,
    editable: false,
    expires_by_date: "2011-05-18T15:01:01Z",
    forward: false,
    group_type: "some updated group_type",
    is_active: false,
    name: "some updated name",
    profile_pic: "some updated profile_pic",
    reference_id: 43,
    service_request_id: 43
  }
  @invalid_attrs %{
    add_members: nil,
    allow_pvt_message: nil,
    editable: nil,
    expires_by_date: nil,
    forward: nil,
    group_type: nil,
    is_active: nil,
    name: nil,
    profile_pic: nil,
    reference_id: nil,
    service_request_id: nil
  }

  def fixture(:group) do
    {:ok, group} = Groups.create_group(@create_attrs)
    group
  end

  describe "index" do
    test "lists all groups", %{conn: conn} do
      conn = get(conn, Routes.group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Groups"
    end
  end

  describe "new group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.group_path(conn, :new))
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "create group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.group_path(conn, :create), group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.group_path(conn, :show, id)

      conn = get(conn, Routes.group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.group_path(conn, :create), group: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "edit group" do
    setup [:create_group]

    test "renders form for editing chosen group", %{conn: conn, group: group} do
      conn = get(conn, Routes.group_path(conn, :edit, group))
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "update group" do
    setup [:create_group]

    test "redirects when data is valid", %{conn: conn, group: group} do
      conn = put(conn, Routes.group_path(conn, :update, group), group: @update_attrs)
      assert redirected_to(conn) == Routes.group_path(conn, :show, group)

      conn = get(conn, Routes.group_path(conn, :show, group))
      assert html_response(conn, 200) =~ "some updated group_type"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put(conn, Routes.group_path(conn, :update, group), group: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete(conn, Routes.group_path(conn, :delete, group))
      assert redirected_to(conn) == Routes.group_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.group_path(conn, :show, group))
      end
    end
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end
end
