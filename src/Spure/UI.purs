module Spure.UI
       where

import Prelude

import Data.Array (singleton)
import Effect (Effect)
import React.Basic.DOM as D
import React.Basic.Events (handler_)
import React.Basic.Hooks (Component, component, empty)
import React.Basic.Hooks as R

mkDoneButton :: Component { setDone::(Boolean -> Boolean) -> Effect Unit }
mkDoneButton = component "SpureButton" \{setDone} -> R.do
  pure $ D.button { onClick: handler_ $ setDone \_ -> true
                  , children: [D.text "Spure!"]
                  }

mkResetButton :: Component { setDone::(Boolean -> Boolean) -> Effect Unit
                           , setText::(Array String -> Array String) -> Effect Unit
                           }
mkResetButton = component "ResetButton"
                \{ setDone, setText } -> R.do
  pure $ D.button { onClick: handler_ $ setDone (\_ -> false) *>
                                        setText (\_ -> [])
                  , children: [D.text "Reset"]
                  }

mkOutput :: Component { text::Array String, done::Boolean}
mkOutput = component "Output" \props -> R.do
  pure $ if props.done
         then D.div { id:"output"
                    , children: map (D.p_ <<< singleton <<< D.text) props.text
                    }
         else empty
