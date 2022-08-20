module Main where

import Prelude

import Data.Array (snoc)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, Reducer, component, mkReducer, useReducer, (/\))
import React.Basic.Hooks as R
import Spure (mkSpure)
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

mkTextReducer :: Effect (Reducer (Array String) String)
mkTextReducer = mkReducer snoc

mkApp :: Component Unit
mkApp = do
  spure <- mkSpure
  reducer <- mkTextReducer
  component "App" \_ -> R.do
    text /\ dispatch <- useReducer [] reducer
    pure $ spure { dispatch }
