module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import React.Basic.DOM as D
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, component, fragment, useState, (/\))
import React.Basic.Hooks as R
import Spure (mkSpure)
import Spure.UI (mkDoneButton, mkOutput, mkResetButton, mkSaveButton)
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
  saveButton <- mkSaveButton
  resetButton <- mkResetButton
  output <- mkOutput
  component "App" \_ -> R.do
    writing /\ setWriting <- useState false
    done /\ setDone <- useState false
    text /\ setText <- useState []
    
    pure $ D.main { className: if done then "done" else ""
                  , children: [ D.div { id:"main-ui"
                                      , children: [ spure { setWriting, setText, done }
                                                  , if not done
                                                    then doneButton { setDone, writing }
                                                    else fragment [ saveButton { text }
                                                                  , resetButton { setDone, setText }
                                                                  ]
                                                  ]
                                      }
                              , output { text, done }]
                  }
