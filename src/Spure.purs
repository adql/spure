module Spure (mkSpure)
       where

import Prelude

import Data.Array (elem)
import Data.Maybe (Maybe(..), fromJust)
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable, null)
import Data.String as S
import Data.String.CodeUnits (takeRight)
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import React.Basic.DOM as D
import React.Basic.DOM.Events (capture, capture_, key, nativeEvent, target)
import React.Basic.Events (handler, merge)
import React.Basic.Hooks (Component, Hook, Ref, UseEffect, UseRef, coerceHook, component, readRefMaybe, useEffect, useRef)
import React.Basic.Hooks as R
import Spure.Internal.InputEvent (inputType)
import Web.DOM.Node (Node, toEventTarget)
import Web.Event.Event (Event, preventDefault)
import Web.Event.EventTarget (EventTarget, addEventListener, eventListener)
import Web.HTML (HTMLInputElement)
import Web.HTML.HTMLElement (focus, fromEventTarget)
import Web.HTML.HTMLInputElement as HtmlIE
import Web.UIEvent.InputEvent (fromEvent)
import Web.UIEvent.InputEvent.EventTypes (beforeinput)

mkSpure :: Component { setText ::
                          (Array String -> Array String) -> Effect Unit
                     , done :: Boolean
                     }
mkSpure = component "Spure" \{setText, done} -> R.do
  let appendParagraph :: HTMLInputElement -> Effect Unit
      appendParagraph inputElem = do
        newParagraph <- HtmlIE.value inputElem
        HtmlIE.setValue "" inputElem
        if not (S.null newParagraph) then setText (_ <> [newParagraph])
          else pure unit

  spureRef <- useControlledInput appendParagraph

  useEffect done $ 
    if done
    then do
      node <- map (unsafePartial fromJust) $ readRefMaybe spureRef
      let inputElem = (unsafePartial fromJust) $ HtmlIE.fromNode node
      appendParagraph inputElem
      pure mempty
    else pure mempty

  pure $ D.input { ref: spureRef
                 , id: "spure"
                 , spellCheck: false
                 , hidden: if done then true else false
                 , onKeyDown: handler (merge { key, nativeEvent }) handleKeyDown
                 , onContextMenu: capture_ $ pure unit
                 , required: true
                 , autoFocus: true
                 }

newtype UseControlledInput hooks =
  UseControlledInput (UseEffect Unit (UseRef (Nullable Node) hooks))

derive instance ntUseControlledInput :: Newtype (UseControlledInput hooks) _

useControlledInput :: (HTMLInputElement -> Effect Unit) ->
                      Hook UseControlledInput (Ref (Nullable Node))
useControlledInput handleLineBreak = coerceHook R.do
  spureRef <- useRef null
  useEffect unit do
    spure <- readRefMaybe spureRef
    case spure of
      Nothing -> pure mempty
      Just node -> do
        let eTarget = toEventTarget node
            inputElem = (unsafePartial fromJust) $ HtmlIE.fromNode node
        eListener <- eventListener \e -> do
          let inputE = (unsafePartial fromJust) $ fromEvent e
          case inputType inputE of
            "insertText" -> pure unit
            "insertLineBreak" -> handleLineBreak inputElem
            "deleteContentBackward" -> filterDeletion inputElem e
            _ -> preventDefault e
        addEventListener beforeinput eListener true eTarget
        pure mempty

  pure spureRef

filterDeletion :: HTMLInputElement -> Event -> Effect Unit
filterDeletion inputElem e = do
  value <- HtmlIE.value inputElem
  if takeRight 1 value == " "
    then preventDefault e
    else pure unit

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
