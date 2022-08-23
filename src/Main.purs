module Main where

import Prelude

import Data.Array (snoc)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import React.Basic.DOM as D
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, Reducer, component, fragment, mkReducer, useReducer, useState, (/\))
import React.Basic.Hooks as R
import Spure (mkSpure)
import Spure.UI (mkDoneButton, mkOutput, mkResetButton)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main :: Effect Unit
main = do
  doc <- document =<< window
  app' <- getElementById "app" $ toNonElementParentNode doc
  case app' of
    Nothing -> error "No app element found"
    Just app -> do
      root <- createRoot app
      spureApp <- mkApp
      renderRoot root $ spureApp unit

mkApp :: Component Unit
mkApp = do
  spure <- mkSpure
  doneButton <- mkDoneButton
  resetButton <- mkResetButton
  output <- mkOutput
  component "App" \_ -> R.do
    done /\ setDone <- useState false
    text /\ setText <- useState []

    pure $ fragment [ D.div { id:"main-ui"
                            , children: [ spure { setText }
                                        , if done
                                          then resetButton { setDone, setText }
                                          else doneButton { setDone }
                                        ]
                            }
                    , output { text, done }
                    ]
