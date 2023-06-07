defmodule Core.ErrorsTest do
  use Core.DataCase

  alias Core.Errors

  describe "dart_errors" do
    alias Core.Schemas.DartError

    @valid_attrs %{level: "some level", message: "some message", tag: "some tag"}
    @update_attrs %{
      level: "some updated level",
      message: "some updated message",
      tag: "some updated tag"
    }
    @invalid_attrs %{level: nil, message: nil, tag: nil}

    def dart_error_fixture(attrs \\ %{}) do
      {:ok, dart_error} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Errors.create_dart_error()

      dart_error
    end

    test "list_dart_errors/0 returns all dart_errors" do
      dart_error = dart_error_fixture()
      assert Errors.list_dart_errors() == [dart_error]
    end

    test "get_dart_error!/1 returns the dart_error with given id" do
      dart_error = dart_error_fixture()
      assert Errors.get_dart_error!(dart_error.id) == dart_error
    end

    test "create_dart_error/1 with valid data creates a dart_error" do
      assert {:ok, %DartError{} = dart_error} = Errors.create_dart_error(@valid_attrs)
      assert dart_error.level == "some level"
      assert dart_error.message == "some message"
      assert dart_error.tag == "some tag"
    end

    test "create_dart_error/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Errors.create_dart_error(@invalid_attrs)
    end

    test "update_dart_error/2 with valid data updates the dart_error" do
      dart_error = dart_error_fixture()

      assert {:ok, %DartError{} = dart_error} =
               Errors.update_dart_error(dart_error, @update_attrs)

      assert dart_error.level == "some updated level"
      assert dart_error.message == "some updated message"
      assert dart_error.tag == "some updated tag"
    end

    test "update_dart_error/2 with invalid data returns error changeset" do
      dart_error = dart_error_fixture()
      assert {:error, %Ecto.Changeset{}} = Errors.update_dart_error(dart_error, @invalid_attrs)
      assert dart_error == Errors.get_dart_error!(dart_error.id)
    end

    test "delete_dart_error/1 deletes the dart_error" do
      dart_error = dart_error_fixture()
      assert {:ok, %DartError{}} = Errors.delete_dart_error(dart_error)
      assert_raise Ecto.NoResultsError, fn -> Errors.get_dart_error!(dart_error.id) end
    end

    test "change_dart_error/1 returns a dart_error changeset" do
      dart_error = dart_error_fixture()
      assert %Ecto.Changeset{} = Errors.change_dart_error(dart_error)
    end
  end
end
