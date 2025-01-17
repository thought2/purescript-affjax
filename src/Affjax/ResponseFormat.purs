module Affjax.ResponseFormat where

import Prelude

import Data.Argonaut.Core (Json)
import Data.ArrayBuffer.Types (ArrayBuffer)
import Data.Maybe (Maybe(..))
import Data.MediaType (MediaType)
import Data.MediaType.Common (applicationJSON)
import Foreign (Foreign, ForeignError)
import Foreign as Foreign
import Web.DOM.Document (Document)
import Web.File.Blob (Blob)

-- | Used to represent how a HTTP response body should be interpreted.
data ResponseFormat a
  = ArrayBuffer (forall f. Functor f => f ArrayBuffer -> f a)
  | Blob (forall f. Functor f => f Blob -> f a)
  | Document (forall f. Functor f => f Document -> f a)
  | Json (forall f. Functor f => f Json -> f a)
  | String (forall f. Functor f => f String -> f a)
  | Ignore (forall f. Functor f => f Unit -> f a)

derive instance functorResponseFormat :: Functor ResponseFormat

arrayBuffer :: ResponseFormat ArrayBuffer
arrayBuffer = ArrayBuffer identity

blob :: ResponseFormat Blob
blob = Blob identity

document :: ResponseFormat Document
document = Document identity

json :: ResponseFormat Json
json = Json identity

string :: ResponseFormat String
string = String identity

ignore :: ResponseFormat Unit
ignore = Ignore identity

-- | Converts a `Response a` into a string representation of the response type
-- | that it represents.
toResponseType :: forall a. ResponseFormat a -> String
toResponseType =
  case _ of
    ArrayBuffer _ -> "arraybuffer"
    Blob _ -> "blob"
    Document _ -> "document"
    Json _ -> "text" -- IE doesn't support "json" ResponseFormat
    String _ -> "text"
    Ignore _ -> ""

toMediaType :: forall a. ResponseFormat a -> Maybe MediaType
toMediaType =
  case _ of
    Json _ -> Just applicationJSON
    _ -> Nothing

-- | Used when an error occurs when attempting to decode into a particular
-- | response format. The error that occurred when decoding is included, along
-- | with the value that decoding was attempted on.
data ResponseFormatError = ResponseFormatError ForeignError Foreign

printResponseFormatError :: ResponseFormatError → String
printResponseFormatError (ResponseFormatError err _) =
  Foreign.renderForeignError err
