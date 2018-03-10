defmodule Web.Torrent do
  def list do
    {:ok,
     [
       %{
         id: 1,
         seedbox_id: 1,
         name: "torrent 1",
         downloadDir: "/user/Downloads/torrents",
         tracker: "such tracker",
         files: [
           %{name: "file 1", bytesCompleted: "45", length: "176"},
           %{name: "file 2", bytesCompleted: "38", length: "3456"}
         ]
       },
       %{
         id: 2,
         seedbox_id: 1,
         name: "torrent 14",
         tracker: "very tracker",
         downloadDir: "/user/Downloads/torrents",
         files: []
       },
       %{
         id: 3,
         seedbox_id: 1,
         name: "torrent 3",
         tracker: "much pirate",
         downloadDir: "/user/Downloads/torrents",
         files: []
       }
     ]}
  end

  # seedbox : Seedbox
  # seedbox:
  #     Remote
  #         { torrents = torrents
  #         , settings = { url = "", port_ = Nothing }
  #         }
end
