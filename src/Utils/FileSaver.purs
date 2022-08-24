module Utils.FileSaver (saveBlobAs) where

import Prelude

import Effect (Effect)
import Web.File.Blob (Blob)

foreign import saveBlobAs :: Blob -> String -> Effect Unit
