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
    { keywords : List String
    , selectedKeyword : String
    , imagesResult : RemoteData.WebData ImageSearchResponse
    }


init : ( Model, Cmd Msg )
init =
    ( { keywords = [ "cat", "dog", "hot dog", "monkey", "car", "star wars", "coffee" ]
      , selectedKeyword = ""
      , imagesResult = RemoteData.NotAsked
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | SelectKeyword String
    | ImagesResult (RemoteData.WebData ImageSearchResponse)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SelectKeyword keyword ->
            ( { model
                | selectedKeyword = keyword
                , imagesResult = RemoteData.Loading
              }
            , getPictures keyword
            )

        ImagesResult webData ->
            ( { model
                | imagesResult = webData
              }
            , Cmd.none
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 []
            [ text "Image Gallery" ]
        , tabBarView model
        , imagesView model
        ]


imagesView : Model -> Html Msg
imagesView model =
    case model.imagesResult of
        RemoteData.NotAsked ->
            text "Select a keyword"

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Failure error ->
            text <| toString error

        RemoteData.Success imageResponse ->
            div []
                (List.map imageView imageResponse.hits)


imageView : Image -> Html Msg
imageView image =
    img
        [ class "rounded float-left gallery-image m-1 bg-dark"
        , src image.webformatURL
        ]
        []


tabBarView : Model -> Html Msg
tabBarView model =
    ul [ class "nav nav-tabs" ]
        (List.map (tabBarItemView model.selectedKeyword) model.keywords)


tabBarItemView : String -> String -> Html Msg
tabBarItemView selectedKeyword keyword =
    let
        activeClass =
            if selectedKeyword == keyword then
                "active"
            else
                ""
    in
    li [ class "nav-item" ]
        [ button
            [ class ("btn btn-link nav-link text-capitalize " ++ activeClass)
            , Events.onClick <| SelectKeyword keyword
            ]
            [ text keyword ]
        ]



---- HTTP ----


getPictures : String -> Cmd Msg
getPictures keyword =
    let
        apiKey =
            "9032446-3c6daac515f13233f663b0957"

        url =
            "https://pixabay.com/api/?per_page=6&key=" ++ apiKey ++ "&q=" ++ keyword
    in
    Http.get url decodeImageSearchResponse
        |> RemoteData.sendRequest
        |> Cmd.map ImagesResult


type alias Image =
    { id : Int
    , pageURL : String
    , webformatHeight : Int
    , webformatURL : String
    , webformatWidth : Int
    }


type alias ImageSearchResponse =
    { hits : List Image
    }


decodeImage : Json.Decode.Decoder Image
decodeImage =
    Json.Decode.Pipeline.decode Image
        |> Json.Decode.Pipeline.required "id" Json.Decode.int
        |> Json.Decode.Pipeline.required "pageURL" Json.Decode.string
        |> Json.Decode.Pipeline.required "webformatHeight" Json.Decode.int
        |> Json.Decode.Pipeline.required "webformatURL" Json.Decode.string
        |> Json.Decode.Pipeline.required "webformatWidth" Json.Decode.int


decodeImageSearchResponse : Json.Decode.Decoder ImageSearchResponse
decodeImageSearchResponse =
    Json.Decode.Pipeline.decode ImageSearchResponse
        |> Json.Decode.Pipeline.required "hits" (Json.Decode.list decodeImage)



---- PROGRAM ----


main : Program Never Model Msg
main =
    program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
