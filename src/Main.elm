module Main exposing (main)

import Html exposing (Attribute, Html, button, code, div, form, h1, h4, img, input, li, pre, program, span, text, ul)
import Html.Attributes exposing (class, src, type_)
import Html.Events as Events
import Http
import Json.Decode
import Json.Decode.Pipeline
import RemoteData


---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Your Elm App is working!" ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
