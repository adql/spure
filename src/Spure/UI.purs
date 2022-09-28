module Spure.UI
       ( mkAfterDoneUI
       , mkDoneButton
       , mkInfoButton
       , mkOutput
       )
       where

import Prelude

import Data.Array (singleton)
import Data.MediaType.Common (textPlain)
import Data.String (joinWith)
import Effect (Effect)
import React.Basic.DOM as D
import React.Basic.DOM.Events (capture_)
import React.Basic.Hooks (Component, component, empty)
import React.Basic.Hooks as R
import Utils.FileSaver (saveBlobAs)
import Web.File.Blob (fromString)

mkAfterDoneUI :: Component { setDone :: (Boolean -> Boolean) -> Effect Unit
                           , setText :: (Array String -> Array String) -> Effect Unit
                           , text :: Array String
                           , done :: Boolean
                           }
mkAfterDoneUI = do
  saveButton <- mkSaveButton
  resetButton <- mkResetButton
  component "AfterDoneUI" \{ setDone, setText, text, done } -> R.do
    pure $ D.div { id: "after-done-ui"
                 , className: "ui-container " <> if done then "ui-visible" else "ui-hidden"
                 , children: [ saveButton { text }
                             , resetButton { setDone, setText }
                             ]
                 }

mkInfoButton :: Component { setInfoVisible :: (Boolean -> Boolean) -> Effect Unit
                          }
mkInfoButton = component "InfoButton" \{setInfoVisible} -> R.do
  pure $ D.button { id: "info-button"
                  , onClick: capture_ $ setInfoVisible not
                  , children: [ D.text "i" ]
                  }

mkDoneButton :: Component { setDone :: (Boolean -> Boolean) -> Effect Unit
                          }
mkDoneButton = component "SpureButton" \{setDone} -> R.do
  pure $ D.button { id: "done-button"
                  , onClick: capture_ $ setDone \_ -> true
                  , children: [D.text "Spure!"]
                  }

mkResetButton :: Component { setDone::(Boolean -> Boolean) -> Effect Unit
                           , setText::(Array String -> Array String) -> Effect Unit
                           }
mkResetButton = component "ResetButton"
                \{ setDone, setText } -> R.do
  pure $ D.button { onClick: capture_ $ setDone (\_ -> false) *>
                                        setText (\_ -> [])
                  , children: [D.text "Reset"]
                  }

mkSaveButton :: Component { text::Array String }
mkSaveButton = component "SaveButton" \{text} -> R.do
  let blob = fromString (joinWith "\n\n" text) textPlain

  pure $ D.button { onClick: capture_ $ saveBlobAs blob "spure.txt"
                  , children: [D.text "Save"]
                  }

mkOutput :: Component { text::Array String, done::Boolean}
mkOutput = component "Output" \props -> R.do
  pure $ if props.done
         then D.div { id:"output"
                    , children: map (D.p_ <<< singleton <<< D.text) props.text
                    }
         else empty
