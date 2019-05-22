module Test.Generated.Main107525160 exposing (main)

import ZipperTest

import Test.Reporter.Reporter exposing (Report(..))
import Console.Text exposing (UseColor(..))
import Test.Runner.Node
import Test

main : Test.Runner.Node.TestProgram
main =
    [     Test.describe "ZipperTest" [ZipperTest.suite] ]
        |> Test.concat
        |> Test.Runner.Node.run { runs = Nothing, report = (ConsoleReport UseColor), seed = 246594699889472, processes = 4, paths = ["/Users/julien/workspace/telepath/apps/web/assets/tests/ZipperTest.elm"]}