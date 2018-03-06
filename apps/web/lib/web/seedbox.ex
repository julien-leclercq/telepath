defmodule Web.Seedbox do
  def list do
    {:ok,
     [
       %{
         id: 1,
         url: "",
         port: nil,
         remote: true
       }
     ]}
  end
end
