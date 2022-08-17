module Spure.Internal.InputEvent where

import Web.UIEvent.InputEvent (InputEvent)

foreign import inputType :: InputEvent -> String
