module Main exposing (main)

import Html exposing (Attribute, Html, button, code, div, form, h1, h4, img, input, li, pre, program, span, text, ul)
import Html.Attributes exposing (class, src, type_)
import Html.Events as Events
import Http
import Json.Decode
import Json.Decode.Pipeline
import RemoteData


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


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


type alias Model =
    { imageSearchResponse : RemoteData.WebData ImageSearchResponse
    , selectedKeyword : Maybe String
    , keywords : List String
    , searchInput : String
    }


init : ( Model, Cmd Msg )
init =
    ( { imageSearchResponse = RemoteData.NotAsked
      , selectedKeyword = Nothing
      , keywords = [ "cat", "dog", "hot dog", "monkey", "car", "star wars", "coffee" ]
      , searchInput = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = FetchImages String
    | ImagesResult (RemoteData.WebData ImageSearchResponse)
    | SetSearchInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchImages keyword ->
            ( { model
                | selectedKeyword = Just keyword
                , imageSearchResponse = RemoteData.Loading
              }
            , getPictures keyword
            )

        ImagesResult webData ->
            ( { model | imageSearchResponse = webData }
            , Cmd.none
            )

        SetSearchInput value ->
            ( { model | searchInput = value }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "container" ]
        [ form
            [ class "form-inline float-right mt-3"
            , Events.onSubmit <| FetchImages model.searchInput
            ]
            [ input [ class "form-control", Events.onInput SetSearchInput ] []
            , button
                [ class "btn btn-primary ml-2"
                , type_ "submit"
                ]
                [ text <| "Search for \"" ++ model.searchInput ++ "\"" ]
            ]
        , h1 [] [ text "Image Gallery" ]
        , tabBarView model.keywords <|
            Maybe.withDefault "" model.selectedKeyword
        , case model.imageSearchResponse of
            RemoteData.NotAsked ->
                div [ class "alert alert-primary m-2" ]
                    [ text "Please select a category"
                    ]

            RemoteData.Loading ->
                span [] [ text "Loading..." ]

            RemoteData.Success imageSearchResponse ->
                imageListView imageSearchResponse.hits

            RemoteData.Failure error ->
                div [ class "alert alert-danger m-2" ]
                    [ h4 [ class "alert-heading" ] [ text "Error" ]
                    , code [] [ text <| toString error ]
                    ]
        ]


tabBarView : List String -> String -> Html Msg
tabBarView keywords selectedKeyword =
    ul
        [ class "nav nav-tabs"
        ]
        (List.map (tabView selectedKeyword) keywords)


tabView : String -> String -> Html Msg
tabView selectedKeyword keyword =
    let
        activeClass =
            if selectedKeyword == keyword then
                "active"
            else
                ""
    in
    li
        [ class "nav-item" ]
        [ button
            [ class ("btn btn-link nav-link text-capitalize " ++ activeClass)
            , Events.onClick <| FetchImages keyword
            ]
            [ text keyword ]
        ]


imageListView : List Image -> Html Msg
imageListView images =
    div [] <|
        List.map imageView images


imageView : Image -> Html Msg
imageView image =
    img
        [ src image.webformatURL
        , class "rounded float-left gallery-image m-1 bg-dark"
        ]
        []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


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
