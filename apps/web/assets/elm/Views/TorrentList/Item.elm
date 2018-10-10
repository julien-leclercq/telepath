module Views.TorrentList.Item exposing (fileView, filesView, infosView, view)

import Data.Torrent exposing (File, Torrent)
import Html exposing (Html, button, div, input, label, p, progress, span, text)
import Html.Attributes as Attrs


view : Torrent -> Html msg
view torrent =
    let
        showFileCheckId =
            "show-files-torrent" ++ toString torrent.id

        showInfosCheckId =
            "show-infos-torrent" ++ toString torrent.id
    in
    div [ Attrs.class "card torrent" ]
        [ input [ Attrs.type_ "checkbox", Attrs.class "show-files", Attrs.id showFileCheckId ] []
        , input [ Attrs.type_ "checkbox", Attrs.class "show-infos", Attrs.id showInfosCheckId ] []
        , div [ Attrs.class "level" ] [ span [ Attrs.class "level-left level-item" ] [ text torrent.name ] ]
        , div [ Attrs.class "card-footer torrent-header" ]
            [ div [ Attrs.class "level-right" ]
                [ label [ Attrs.for showFileCheckId, Attrs.class "button show-files-label level-item" ] []
                , label [ Attrs.for showInfosCheckId, Attrs.class "button show-infos-label level-item" ] []
                ]
            ]
        , filesView torrent

        -- , infosView torrent
        ]


fileView : File -> Html msg
fileView file =
    div [ Attrs.class "media" ]
        [ div [ Attrs.class "media-content" ]
            [ div [ Attrs.class "level" ]
                [ span [ Attrs.class "file-title" ] [ text file.name ] ]
            , div []
                [ div [ Attrs.class "level" ]
                    [ progress [ Attrs.class "progress", file.bytesCompleted |> toString |> Attrs.value, Attrs.max <| toString file.length ] []
                    ]
                ]
            ]
        ]


filesView : Torrent -> Html msg
filesView torrent =
    div [ Attrs.class "files media" ] [ div [ Attrs.class "media-content" ] (List.map fileView torrent.files) ]



-- infosView : Torrent -> Html msg


infosView torrent =
    div [ Attrs.class "infos media" ] (List.map (\tracker -> p [] [ text tracker ]) torrent.trackers)
