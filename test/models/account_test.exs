defmodule Wall.AccountTest do
  use Wall.ModelCase

  alias Wall.Account

  @valid_attrs %{email: "some content", family_name: "some content", given_name: "some content", hd: "some content", name: "some content", picture: "some content", sub: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Account.changeset(%Account{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Account.changeset(%Account{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "finds an existing account" do
    account = insert_account(%{email: @valid_attrs[:email]})
    assert Account.get_or_create(%{"email" => @valid_attrs[:email]}) == account
  end

  test "creates a new account using given details" do
    account = Account.get_or_create(%{"email" => @valid_attrs[:email], "hd" => "domain.tld"})
    refute account.id == nil
  end

  test "fails when trying to get or create a new, invalid account" do
    {:error, _reason} = Account.get_or_create(%{"email" => @valid_attrs[:email]})
  end
end
