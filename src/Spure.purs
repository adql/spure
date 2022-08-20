module Spure (mkSpure)
       where

import Prelude

import Data.Array (elem)
import Data.Maybe (Maybe(..), fromJust)
import Data.Nullable (null)
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import React.Basic.DOM as D
import React.Basic.DOM.Events (capture, capture_, key, nativeEvent, target)
import React.Basic.Events (handler, merge)
import React.Basic.Hooks (Component, component, readRefMaybe, useEffectOnce, useRef)
import React.Basic.Hooks as R
import Spure.Internal.InputEvent (inputType)
import Web.DOM.Node (Node, toEventTarget)
import Web.Event.Event (Event, preventDefault)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.HTML.HTMLElement (focus, fromEventTarget)
import Web.HTML.HTMLInputElement as HtmlIE
import Web.UIEvent.InputEvent (fromEvent)
import Web.UIEvent.InputEvent.EventTypes (beforeinput)

mkSpure :: Component { dispatch::String -> Effect Unit }
mkSpure = component "Spure" \{dispatch} -> R.do
  spureRef <- useRef null

  let beforeInputHandler :: Node -> Effect Unit
      beforeInputHandler node =
        let eTarget = toEventTarget node
            inputElem = (unsafePartial fromJust) $ HtmlIE.fromNode node
        in do
          eListener <- eventListener \e -> do
            let inputE = (unsafePartial fromJust) $ fromEvent e
            case inputType inputE of
              "insertText" -> pure unit
              "insertLineBreak" -> do
                newParagraph <- HtmlIE.value inputElem
                HtmlIE.setValue "" inputElem
                dispatch newParagraph
              otherwise -> preventDefault e
          addEventListener beforeinput eListener true eTarget

  useEffectOnce do
    spure <- readRefMaybe spureRef
    case spure of
      Nothing -> pure mempty
      Just node -> beforeInputHandler node *> pure mempty
    
  pure $ D.div { id:"container"
               , children: [ D.input { ref: spureRef
                                     , id: "spure"
                                     , spellCheck: false
                                     , onKeyDown: handler (merge { key, nativeEvent }) handleKeyDown
                                     , onMouseDown: capture target handleMouseDown
                                     , onContextMenu: capture_ $ pure unit
                                     }
                           ]
               }

forbiddenKeyValues :: Array String
forbiddenKeyValues = [ "ArrowDown"
                     , "ArrowLeft"
                     , "ArrowRight"
                     , "ArrowUp"
                     , "End"
                     , "Home"
                     , "PageDown"
                     , "PageUp"
                     ]

handleKeyDown :: { key::Maybe String, nativeEvent::Event } -> Effect Unit
handleKeyDown { key, nativeEvent } =
  if (unsafePartial fromJust) key `elem` forbiddenKeyValues
  then preventDefault nativeEvent
  else pure unit

handleMouseDown :: EventTarget -> Effect Unit
handleMouseDown = focus <<< (unsafePartial fromJust) <<< fromEventTarget
