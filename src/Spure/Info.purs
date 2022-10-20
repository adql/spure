module Spure.Info
       ( mkInfoBox
       )
       where

import Prelude

import Effect (Effect)
import React.Basic.DOM as D
import React.Basic.DOM.Events (capture_)
import React.Basic.Hooks (Component, component)

mkInfoBox :: Component { infoVisible :: Boolean
                       , setInfoVisible :: (Boolean -> Boolean) -> Effect Unit
                       }
mkInfoBox = component "InfoBox" \{infoVisible, setInfoVisible} -> R.do
  pure $ D.div { id: "info-box"
               , className: if infoVisible then "visible" else "hidden"
               , children: [ D.p_ [ D.em_ [ D.text "Spure" ]
                                  , D.text " is a no-regrets minimal writing app. It encourages you to stay in the flow of writing without editing and, even more importantly, without even seeing what you have written."
                                  ]
                           , D.p_ [ D.text "Just write one or more paragraphs of text. You can only correct the current word! When you're done, hit "
                                  , D.em_ [ D.text "Spure!" ]
                                  , D.text " – your work will be displayed for you for saving."
                                  ]
                           , D.p_ [ D.text "Currently, in order to enjoy "
                                  , D.em_ [ D.text "Spure"]
                                  , D.text "'s full features of editing inhibition, a computer with a physical keyboard is needed."
                                  ]
                           , D.p_ [ D.strong_ [ D.text "Privacy notice:"]
                                  , D.text " The app runs completely local in your browser, including all the typed text. No data is sent to any server and no cookies are used."
                                  ]
                           , D.button { onClick: capture_ $ setInfoVisible \_ -> false
                                      , children: [ D.text "Go on writing" ]
                                      }
                           ]
               }
