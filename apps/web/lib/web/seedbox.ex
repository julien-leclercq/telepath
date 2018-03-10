defmodule Web.Seedbox do
  @moduledoc """
  This module provide functions to access and treat seedbox informations
  """

  def list do
    {:ok,
     [
       %{
         id: 1,
         url: "seedbox url",
         port: 3454,
         remote: true
       }
     ]}
  end

  #   torrents : List Torrent
  # torrents =
  #     [ { id = 1
  #       , name = "torrent 1"
  #       , downloadDir = "/user/Downloads/torrents"
  #       , tracker = "such tracker"
  #       , files =
  #             [ { name = "file 1", bytesCompleted = "45", length = "176" }
  #             , { name = "file 2", bytesCompleted = "38", length = "3456" }
  #             ]
  #       }
  #     , { id = 2
  #       , name = "torrent 14"
  #       , tracker = "very tracker"
  #       , downloadDir = "/user/Downloads/torrents"
  #       , files = []
  #       }
  #     , { id = 3
  #       , name = "torrent 3"
  #       , tracker = "much pirate"
  #       , downloadDir = "/user/Downloads/torrents"
  #       , files = []
  #       }
  #     ]
end
