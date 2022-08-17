module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import React.Basic.DOM.Client (createRoot, renderRoot)
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
      spure <- mkSpure
      renderRoot root $ spure unit
