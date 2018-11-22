module Utils.Playlist exposing
    ( Playlist
    , add
    , addAtEnd
    , addNext
    , down
    , getCurrent
    , hasNext
    , new
    , next
    , previous
    , up
    )


type Playlist a
    = Playlist (List ( Int, a )) ( Int, a ) (List ( Int, a ))


type Error
    = IndexOutOfBounds
    | EmptyHead


getCurrent : Playlist a -> a
getCurrent (Playlist _ ( _, current ) _) =
    current


new : a -> Playlist a
new track =
    Playlist [] ( 0, track ) []


next : Playlist a -> Maybe a
next (Playlist _ _ tail) =
    case tail of
        ( _, nextElement ) :: _ ->
            Just nextElement

        _ ->
            Nothing


previous : Playlist a -> Maybe a
previous (Playlist head _ _) =
    case head of
        ( _, previousElement ) :: _ ->
            Just previousElement

        _ ->
            Nothing


down : Playlist a -> Maybe (Playlist a)
down (Playlist head current tail) =
    case tail of
        [] ->
            Nothing

        nextElem :: tailTail ->
            Playlist (current :: head)
                nextElem
                tailTail
                |> Just


up : Playlist a -> Maybe (Playlist a)
up (Playlist head current tail) =
    case head of
        prevElem :: headHead ->
            Playlist
                head
                prevElem
                (current :: head)
                |> Just

        _ ->
            Nothing


hasNext : Playlist a -> Bool
hasNext (Playlist _ _ tail) =
    case tail of
        [] ->
            False

        _ ->
            True


hasPrevious : Playlist a -> Bool
hasPrevious (Playlist head _ _) =
    case head of
        [] ->
            False

        _ ->
            True


add : a -> Playlist a -> Playlist a
add elem (Playlist head ( currentIndex, currentElem ) tail) =
    Playlist
        (( currentIndex, currentElem ) :: head)
        ( currentIndex + 1, elem )
        (incrIndexes tail)


addNext : a -> Playlist a -> Playlist a
addNext elem (Playlist head ( index, currentElem ) tail) =
    let
        newTail =
            List.map (\( i, v ) -> ( i + 1, v )) tail
    in
    Playlist head ( index, currentElem ) (( index + 1, elem ) :: newTail)


addAtEnd : a -> Playlist a -> Playlist a
addAtEnd elem (Playlist head ( currentIndex, currentElement ) tail) =
    case List.reverse tail of
        [] ->
            Playlist head ( currentIndex, currentElement ) [ ( currentIndex + 1, elem ) ]

        ( i, v ) :: _ ->
            let
                newTail =
                    ( i + 1, elem )
                        :: tail
                        |> List.reverse
            in
            Playlist head ( currentIndex, currentElement ) newTail


removeAt : Int -> Playlist a -> Result Error (Maybe (Playlist a))
removeAt index (Playlist head ( currentIndex, currentElement ) tail) =
    case compare index currentIndex of
        EQ ->
            case tail of
                -- Tail is empty
                [] ->
                    case head of
                        [] ->
                            Ok Nothing

                        x :: xs ->
                            Playlist xs x tail
                                |> Just
                                |> Ok

                -- destructuring nonempty tail
                ( i, v ) :: tailTail ->
                    let
                        mapper : ( Int, a ) -> ( Int, a )
                        mapper =
                            \( ind, val ) -> ( ind - 1, val )

                        newTail =
                            List.map mapper tailTail
                    in
                    Playlist head ( i - 1, v ) newTail
                        |> Just
                        |> Ok

        GT ->
            case tail of
                [] ->
                    Err IndexOutOfBounds

                _ ->
                    let
                        delete list =
                            case list of
                                ( thisIndex, thisValue ) :: tailTail ->
                                    if thisIndex == index then
                                        List.map (\( i, v ) -> ( i - 1, v )) tailTail
                                            |> Ok

                                    else
                                        tailTail
                                            |> delete
                                            |> Result.map (\newTail -> ( thisIndex, thisValue ) :: newTail)

                                [] ->
                                    Err IndexOutOfBounds
                    in
                    delete tail
                        |> Result.map
                            (\newTail ->
                                Playlist head ( currentIndex, currentElement ) newTail
                                    |> Just
                            )

        LT ->
            if index < 0 then
                Err IndexOutOfBounds

            else
                let
                    delete list =
                        case list of
                            [] ->
                                Err EmptyHead

                            ( i, v ) :: headHead ->
                                if i == index then
                                    headHead
                                        |> Ok

                                else
                                    delete headHead
                                        |> Result.map (\newHeadHead -> ( i - 1, v ) :: newHeadHead)
                in
                delete head
                    |> Result.map
                        (\newHead ->
                            Playlist newHead ( currentIndex - 1, currentElement ) (decrIndexes tail)
                                |> Just
                        )



----- Helpers


decrIndexes : List ( Int, a ) -> List ( Int, a )
decrIndexes =
    List.map (\( i, v ) -> ( i - 1, v ))


incrIndexes : List ( Int, a ) -> List ( Int, a )
incrIndexes =
    List.map (\( i, v ) -> ( i + 1, v ))
