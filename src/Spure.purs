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
import React.Basic.Hooks (Component, component)
import React.Basic.Hooks as R
import Spure.Internal.InputEvent (inputType)
import Web.DOM.Node (toEventTarget)
import Web.Event.Event (Event, preventDefault)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.HTML.HTMLElement (focus, fromEventTarget)
import Web.UIEvent.InputEvent (fromEvent)
import Web.UIEvent.InputEvent.EventTypes (beforeinput)

mkSpure :: Component Unit
mkSpure = component "Spure" \_ -> R.do
  spureRef <- R.useRef null

  R.useEffectOnce do
    spure <- R.readRefMaybe spureRef
    case spure of
      Nothing -> pure mempty
      Just node -> do
        let eTarget = toEventTarget node
        addInputBlocker eTarget
        pure mempty
  
  pure $ D.div { id:"container"
               , children: [ D.textarea { ref: spureRef
                                        , id: "spure"
                                        , spellCheck: false
                                        , rows: 1
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

allowedInputTypes :: Array String
allowedInputTypes = [ "insertText"
                    , "insertLineBreak"
                    , "insertParagraph"
                    ]

addInputBlocker :: EventTarget -> Effect Unit
addInputBlocker eTarget = do
  eListener <- eventListener \e -> do
    let inputE = (unsafePartial fromJust) $ fromEvent e
    if inputType inputE `elem` allowedInputTypes
      then pure unit
      else preventDefault e
  addEventListener beforeinput eListener true eTarget
