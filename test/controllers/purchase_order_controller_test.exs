require Alfred.Helpers, as: H
alias Tino.Test.Helpers.PurchaseOrder, as: Po
alias Tino.Test.Helpers.Common
alias Tino.Repo
import Ecto.Query

defmodule Tino.PurchaseOrderControllerTest do
  use ExUnit.Case
  use Tino.ConnCase, async: true

  alias Tino.PurchaseOrder

  setup do
    # Populate the database with some fake data
    Po.insert_sample_row(%{"amount" => 3.00134524, "number" => "99993333"})
    Po.insert_sample_row(%{"amount" => 983.4534524352, "number" => "99943333"})
    Po.insert_sample_row(%{"amount" => 9022.45242, "number" => "99953333"})
    Po.insert_sample_row(%{"amount" => 55.524253446225, "number" => "99963333"})
  end

    # Example URL: purchase_orders/autocomplete?term=cola
  describe "GET /autocomplete" do
    @doc """
      Autocomplete with the whole word, or part of it
      Result: %{"valid" => true, "result" => [%{"id" => <some_id>, "name" => "cola", "permalink" => "111111111"},
      %{"id" => <some_other_id>, "name" => "cola 2", "permalink" => "22222222"},
      %{"id" => <some_random_id>, "name" => "cola 4", "permalink" => "444444444"} ] }
    """
    test "autocomplete purchase order results", %{conn: conn}  do

      autocomplete_action("99993333", conn)
      autocomplete_action("3333", conn)
      autocomplete_action("999", conn)

    end

    @doc """
      Autocomplete with empty results, not existing records for the words searched
      Example URL: campaigns/autocomplete?term=<some_random_term>
      Result: %{"valid" => true, "result" => []}
    """
    test "autocomplete empty result", %{conn: conn}  do

      autocomplete_action("some random string", conn)
      autocomplete_action("INtravenoso", conn)
      autocomplete_action("CaMeL", conn)
      autocomplete_action(" ", conn)

    end

    @doc """
      No param term, should respond accordingly
      Example URL: campaigns/autocomplete
      Result: %{"valid" => false, "result" => "Param 'term' is required" }
    """
    test "autocomplete no term involved", %{conn: conn} do

      autocomplete_action("", conn)
      res = conn
      |> get(purchase_order_path(conn, :autocomplete))
      |> response(200)
      |> Poison.decode!
      assert res["valid"] == false
      assert res["result"] == "Param 'term' is required"
    end


    defp autocomplete_action(term, conn) do

      query_res = Common.build_results(PurchaseOrder.autocomplete_fields, PurchaseOrder, term, PurchaseOrder.select_fields)
      |> H.Map.stringify_keys

      res = conn
      |> get(purchase_order_path(conn, :autocomplete, term: term))
      |> response(200)
      |> Poison.decode!
      assert Map.get(res, "result", []) == query_res
    end
  end


  describe "POST /create" do
    test "create new valid value", %{conn: conn} do
      # A valid params for a valid record
      params = %{description: "a valid purchase_order", number: "91204393", amount: 42598}

      # get the number for multiuse purposes
      number = Map.get(params, :number, "")
      # Check that the query has all the setup values (4 in this case)
      query_res = Common.get_all_results(PurchaseOrder, PurchaseOrder.select_fields)
      assert length(query_res) == 4

      # Try to insert another value
      Po.insert_sample_row(%{"number" => number, "description" => Map.get(params, :description), "amount" => Map.get(params, :amount)})

      # Check that the value has been inserted
      query_res = purchase_order_query(number)
      assert length(query_res) == 1

      # And the database record was increased by 1
      query_res = Common.get_all_results(PurchaseOrder, PurchaseOrder.select_fields)
      assert length(query_res) == 5

      # Delete and perform the insert through the controller
      Repo.delete_all(PurchaseOrder)

      res = post_call(conn, params)
      assert Map.get(res, "valid")

      # The only value in the database should be the one inserted by the controller
      all_res = Common.get_all_results(PurchaseOrder, PurchaseOrder.select_fields)
      assert length(all_res) == 1
      # Check the result is the same
      first_res = Common.stringify_element(all_res) |> List.first
      assert Map.get(res, "result") == first_res
    end

    test "create an invalid value", %{conn: conn} do
      params = %{description: "a valid purchase_order", number: "91204393", amount: "some invalid amount", created_ts: "somewhere in time and space...."}

      number = Map.get(params, :number, "")
      query_res = Common.get_all_results(PurchaseOrder, PurchaseOrder.select_fields)
      assert length(query_res) == 4
      query_res = purchase_order_query(number)
      assert length(query_res) == 0

      Po.insert_sample_row(%{"number" => number, "description" => Map.get(params, :description), "created_ts" => Map.get(params, :created_ts), "amount" => Map.get(params, :amount)})

      query_res = Common.get_all_results(PurchaseOrder, PurchaseOrder.select_fields)
      assert length(query_res) == 4
      query_res = purchase_order_query(number)
      assert length(query_res) == 0

      Repo.delete_all(PurchaseOrder)

      res = post_call(conn, params)
      refute Map.get(res, "valid")

      query_res = purchase_order_query(number)
      assert length(query_res) == 0
    end
  end

  describe "PUT /update" do
    test "update with valid params", %{conn: conn} do

      params = %{description: "some description for a change"}
      purchase_order = purchase_order_query("99993333") |> List.first
      changeset = PurchaseOrder.changeset(purchase_order, params)

      res = Repo.update(changeset)
      # Update successfully
      assert elem(res, 0) == :ok
      assert elem(res, 1) |> Map.get(:description) == Map.get(params, :description)

      update_params = %{description: "The ultimate Purchase Order"} |> Map.put(:id, Map.get(purchase_order, :id))

      res = put_call(conn, update_params)
      assert Map.get(res, "valid")
      assert Map.get(res, "result") |> Map.get("description") == Map.get(update_params, :description)
    end

    test "update with invalid params", %{conn: conn} do

      params = %{description: "some description for a change", created_ts: "fjeaiojaofjoifj"}
      purchase_order = purchase_order_query("99993333") |> List.first
      changeset = PurchaseOrder.changeset(purchase_order, params)
      refute changeset.valid?

      res = Repo.update(changeset)
      # Not updated, returned error instead
      assert elem(res, 0) == :error
      refute elem(res, 1).valid?
      refute elem(res, 1).errors |> Enum.empty?

      update_params = %{description: "The ultimate Purchase Order",  created_ts: "fjeaiojaofjoifj"} |> Map.put(:id, Map.get(purchase_order, :id))

      # Put call with status expected (422 -> unprocessable_entity, URL and params are good, but the request contains invalid params)
      res = put_call(conn, update_params, :unprocessable_entity)

      refute Map.get(res, "valid")
    end
  end

  defp purchase_order_query(number, select_fields) do
    query = from po in PurchaseOrder, where: po.number == ^number, select: map(po, ^select_fields)
    Repo.all(query)
  end

  defp purchase_order_query(number) do
    query = from po in PurchaseOrder, where: po.number == ^number
    Repo.all(query)
  end
    # Controller call for create
  defp post_call(conn, params) do
    conn
    |> post(purchase_order_path(conn, :create, %{"purchase_order" => params}))
    |> response(200)
    |> Poison.decode!
  end

  defp put_call(conn, params) do
    conn
    |> put(purchase_order_path(conn, :update, struct(PurchaseOrder, params)), %{purchase_order: params} )
    |> response(200)
    |> Poison.decode!
  end

  def put_call(conn, params, status) do
    conn
    |> put(purchase_order_path(conn, :update, struct(PurchaseOrder, params)), %{purchase_order: params} )
    |> response(status)
    |> Poison.decode!
  end
end
