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
                           , D.button { onClick: capture_ $ setInfoVisible \_ -> false
                                      , children: [ D.text "Go on writing" ]
                                      }
                           ]
               }
