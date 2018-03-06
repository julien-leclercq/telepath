module Views.TorrentList.Item exposing (..)

import Data.Torrent exposing (File, Torrent)
import Html exposing (Html, button, div, input, label, progress, span, text)
import Html.Attributes as Attrs


view : Torrent -> Html msg
view torrent =
    let
        showFileCheckId =
            "show-files-torrent" ++ (toString torrent.id)

        showInfosCheckId =
            "show-infos-torrent" ++ (toString torrent.id)
    in
        div [ Attrs.class "box torrent" ]
            [ input [ Attrs.type_ "checkbox", Attrs.class "show-files", Attrs.id showFileCheckId ] []
            , input [ Attrs.type_ "checkbox", Attrs.class "show-infos", Attrs.id showInfosCheckId ] []
            , div [ Attrs.class "level torrent-header" ]
                [ div [ Attrs.class "level-left" ] [ span [ Attrs.class "level-item" ] [ text torrent.name ] ]
                , div [ Attrs.class "level-right" ]
                    [ label [ Attrs.for showFileCheckId, Attrs.class "button show-files-label level-item" ] []
                    , label [ Attrs.for showInfosCheckId, Attrs.class "button show-infos-label level-item" ] []
                    ]
                ]
            , filesView torrent
            , infosView torrent
            ]


fileView : File -> Html msg
fileView file =
    div [ Attrs.class "level columns" ]
        [ div [ Attrs.class "level-left column is-one-fifth" ]
            [ span [ Attrs.class "file-title level-item" ] [ text file.name ] ]
        , div [ Attrs.class "level-right column" ]
            [ div [ Attrs.class "level-item" ]
                [ progress [ Attrs.class "progress", Attrs.value file.bytesCompleted, Attrs.max file.length ] []
                ]
            ]
        ]


filesView : Torrent -> Html msg
filesView torrent =
    div [ Attrs.class "files media" ] [ div [ Attrs.class "media-content" ] (List.map fileView torrent.files) ]


infosView torrent =
    div [ Attrs.class "infos media" ] [ text torrent.tracker ]
