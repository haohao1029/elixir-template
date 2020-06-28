
  def items(conn, params) do
    limit = String.to_integer(params["length"])
    offset = String.to_integer(params["start"])

    column_no = params["order"]["0"]["column"]
    key = params["columns"][column_no]["data"] |> String.to_atom()
    dir = params["order"]["0"]["dir"] |> String.to_atom()
    order_by = [{dir, key}]
    data = Repo.all(from(i in Item, where: ilike(i.title, ^"%#{params["search"]["value"]}%")))

    data2 =
      Repo.all(
        from(
        i in Item,
          where: ilike(i.title, ^"%#{params["search"]["value"]}%"),
          select: %{id: i.id, title: i.title, amount: i.amount, price: i.price},
          limit: ^limit,
          offset: ^offset,
          order_by: ^order_by
        )
      )


    json = %{
      data: data2,
      recordsTotal: Enum.count(data2),
      recordsFiltered: Enum.count(data),
      draw: String.to_integer(params["draw"])
    }

    status = 200

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(json))
  end

  def formitems(conn, params) do
    status = 200
    id = params["id"]
    data = Repo.all(from(i in Item, where: i.id == ^id))

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(data))
  end
  def newitems(conn,params) do
    status = 200
    Repo.insert(%Item{title: params["title"], amount: (String.to_integer(params["amount"])), price: (String.to_integer(params["price"]))/1})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, "ok")

  end

  def edititems(conn, params) do
    status = 200
    query = from(i in Item, where: i.id == ^params["id"])
    Repo.update_all(query, set: [price: params["price"]])
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Jason.encode!(params))
  end
  def deleteitems(conn, params) do
    status = 200
    query = from(i in Item, where: i.id == ^params["id"])
    Repo.delete_all(query)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, "ok")
  end
