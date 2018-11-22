module ZipperTest exposing (suite)

import Expect exposing (Expectation)
import Test exposing (..)
import Utils.Zipper as Zipper


suite : Test
suite =
    describe "Zipper"
        [ describe "Zipper.append"
            [ test "can make a basic element appending"
                (\_ ->
                    let
                        zipper =
                            Zipper.new 0

                        expected =
                            Zipper.Zipper [ 0 ] 1 []
                    in
                    Expect.equal expected (Zipper.append 1 zipper)
                )
            , test "works on a more complex zipper"
                (\_ ->
                    let
                        zipper =
                            Zipper.Zipper [ 0 ] 1 [ 2 ]

                        expected =
                            Zipper.Zipper [ 1, 0 ] 3 [ 2 ]
                    in
                    Expect.equal expected (Zipper.append 3 zipper)
                )
            ]
        , describe "Zipper.up"
            [ test "moves the iterator toward head direction"
                (\_ ->
                    let
                        zipper =
                            Zipper.Zipper [ 0 ] 1 [ 2 ]

                        expected =
                            Zipper.Zipper [] 0 [ 1, 2 ]
                    in
                    Expect.equal expected (Zipper.up zipper)
                )
            ]
        , describe "Zipper.down"
            [ test "moves the iterator toward the tail"
                (\_ ->
                    let
                        zipper =
                            Zipper.Zipper [ 0 ] 1 [ 2 ]

                        expected =
                            Zipper.Zipper [ 1, 0 ] 2 []
                    in
                    Expect.equal expected (Zipper.down zipper)
                )
            ]
        ]
