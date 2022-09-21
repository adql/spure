module Spure (mkSpureUI)
       where

import Prelude

import Data.Array (elem)
import Data.Maybe (Maybe(..), fromJust)
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable, null)
import Data.String (length)
import Data.String as S
import Data.String.CodeUnits (takeRight)
import Effect (Effect)
import Partial.Unsafe (unsafePartial)
import React.Basic.DOM as D
import React.Basic.DOM.Events (capture_, key, nativeEvent)
import React.Basic.Events (handler, handler_, merge)
import React.Basic.Hooks (Component, Hook, Ref, UseEffect, UseRef, coerceHook, component, readRefMaybe, useEffect, useRef)
import React.Basic.Hooks as R
import Spure.Internal.InputEvent (inputType)
import Spure.UI (mkDoneButton)
import Web.DOM.Node (Node, toEventTarget)
import Web.Event.Event (Event, preventDefault)
import Web.Event.EventTarget (addEventListener, eventListener)
import Web.HTML (HTMLInputElement)
import Web.HTML.HTMLInputElement as HtmlIE
import Web.UIEvent.InputEvent (fromEvent)
import Web.UIEvent.InputEvent.EventTypes (beforeinput)

mkSpureUI :: Component { setWriting :: (Boolean -> Boolean) -> Effect Unit
                       , setText :: (Array String -> Array String) -> Effect Unit
                       , setDone :: (Boolean -> Boolean) -> Effect Unit
                       , writing :: Boolean
                       , done :: Boolean
                       }
mkSpureUI = do
  spure <- mkSpure
  doneButton <- mkDoneButton
  component "SpureUI" \{ setWriting, setText, setDone, writing, done } -> R.do
    pure $ D.div { id: "spure-ui"
                 , className: "ui-container " <> if done then "ui-hidden" else "ui-visible"
                 , children:  [ spure { setWriting, setText, done }
                              , doneButton { setDone, writing }
                              ]
                 }

mkSpure :: Component { setWriting ::
                          (Boolean -> Boolean) -> Effect Unit
                     , setText ::
                          (Array String -> Array String) -> Effect Unit
                     , done :: Boolean
                     }
mkSpure = component "Spure" \{setWriting, setText, done} -> R.do
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
                 , onKeyDown: handler (merge { key, nativeEvent }) handleKeyDown
                 , onContextMenu: capture_ $ pure unit
                 , onChange: handler_ $ setWriting $ \_ -> true
                 , onBlur: handler_ $ setWriting $ \_ -> false
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
            "insertText" -> collapseSelection inputElem
            "insertLineBreak" -> handleLineBreak inputElem
            "deleteContentBackward" -> filterDeletion inputElem e
            _ -> preventDefault e
        addEventListener beforeinput eListener true eTarget
        pure mempty

  pure spureRef

filterDeletion :: HTMLInputElement -> Event -> Effect Unit
filterDeletion inputElem e = do
  collapseSelection inputElem
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

collapseSelection :: HTMLInputElement -> Effect Unit
collapseSelection inputElem = HtmlIE.value inputElem >>= \value ->
  HtmlIE.setSelectionStart (length value) inputElem
