module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Console (error)
import React.Basic.DOM as D
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Events (handler_)
import React.Basic.Hooks (Component, component, useState, (/\))
import React.Basic.Hooks as R
import Spure (mkSpureUI)
import Spure.UI (mkAfterDoneUI, mkOutput)
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
  spureUI <- mkSpureUI
  afterDoneUI <- mkAfterDoneUI
  output <- mkOutput
  footer <- mkFooter
  component "App" \_ -> R.do
    writing /\ setWriting <- useState false
    done /\ setDone <- useState false
    text /\ setText <- useState []
    
    pure $ D.div { id: "viewport"
                 , onMouseMove: handler_ $ setWriting \_ -> false
                 , children: [ D.main { className: if done then "done" else ""
                                      , children: [ D.div { id:"main-ui"
                                                          , children: [ spureUI { setWriting, setText, setDone, writing , done }
                                                                      , afterDoneUI { setDone, setText, text, done }
                                                                      ]
                                                          }
                                                  , output { text, done }]
                                      }
                             , footer { writing }
                             ]
                 }

mkFooter :: Component { writing :: Boolean }
mkFooter = do
  component "Footer" \{writing} -> R.do
    pure $ D.footer { className: if writing then "writing-hidden" else "not-writing-visible"
                    , children: [ D.text "Made by Amir Dekel ("
                                , D.a { href: "https://github.com/adql"
                                      , children: [ D.text "@adql"]
                                      }
                                , D.text ") with "
                                , D.a { href: "https://www.purescript.org/"
                                      , children: [ D.text "PureScript" ]
                                      }
                                , D.text " // "
                                , D.a { href: "https://github.com/adql/spure"
                                      , children: [ D.text "<src>"]
                                      }
                                ]
                    }
