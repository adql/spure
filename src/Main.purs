module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import Spure (mkSpure)
import React.Basic.DOM (render)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main :: Effect Unit
main = do
  doc <- document =<< window
  app <- getElementById "app" $ toNonElementParentNode doc
  case app of
    Nothing -> error "No app element found"
    Just app' -> do
      spure <- mkSpure
      render (spure unit) app'
