###
Copyright (c) <2014> Florian Mounier - paradoxxxzero

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
###


class Selection
  constructor: ->
    @selection = null
    @begin = @_begin.bind(@)
    @select = @_select.bind(@)
    @end = @_end.bind(@)
    addEventListener 'mousedown', @begin

  style: ->
    @selection.style.position = 'fixed'
    @selection.style.backgroundColor = 'rgba(0, 0, 255, 0.2)'
    @selection.style.border = '2px solid rgba(0, 0, 255, 0.8)'

  position: ->
    if @portion.w >= 0
      @selection.style.left = "#{@portion.x}px"
      @selection.style.width = "#{@portion.w}px"
    else
      @selection.style.left = "#{@portion.x + @portion.w}px"
      @selection.style.width = "#{-@portion.w}px"

    if @portion.h >= 0
      @selection.style.top = "#{@portion.y}px"
      @selection.style.height = "#{@portion.h}px"
    else
      @selection.style.top = "#{@portion.y + @portion.h}px"
      @selection.style.height = "#{-@portion.h}px"

    @selection.style.zIndex = 99999999

  _begin: (e) ->
    document.body.style.webkitUserSelect = 'none'
    removeEventListener 'mousedown', @begin
    @portion =
      x: e.clientX
      y: e.clientY
      w: 0
      h: 0

    @selection = document.createElement 'div'
    @style()
    @position()

    document.body.appendChild @selection
    addEventListener 'mousemove', @select
    addEventListener 'mouseup', @end

  _select: (e) ->
    x = e.clientX
    y = e.clientY
    @portion.w = x - @portion.x
    @portion.h = y - @portion.y
    @position()

  _end: ->
    removeEventListener 'mousemove', @select
    removeEventListener 'mouseup', @end
    document.body.removeChild @selection
    if @portion.w < 0
      @portion.x += @portion.w
      @portion.w *= -1
    if @portion.h < 0
      @portion.y += @portion.h
      @portion.h *= -1
    @done @portion
    document.body.style.removeProperty '-webkit-user-select'


display = (imagedata) ->
  @overlay = document.createElement 'div'
  @overlay.style.position = 'fixed'
  @overlay.style.top = 0
  @overlay.style.left = 0
  @overlay.style.width = '100%'
  @overlay.style.height = '100%'
  @overlay.style.display = 'flex'
  @overlay.style.justifyContent = 'center'
  @overlay.style.backgroundColor = 'rgba(0, 0, 0, 0.2)'
  @overlay.style.zIndex = 999999

  @img = document.createElement 'img'
  @img.style.alignSelf = 'center'
  @img.style.maxWidth = '50%'
  @img.style.maxHeight = '50%'
  @img.src = imagedata
  @overlay.appendChild @img
  document.body.appendChild @overlay
  
  @overlay.addEventListener 'click', (e) =>
    if e.target is @overlay
      document.body.removeChild @overlay


chrome.extension.onMessage.addListener (message, sender) ->
  switch message.cmd
    when 'select'
      sel = new Selection()
      sel.done = (selection) ->
        chrome.extension.sendMessage(sender.id,
          cmd: 'capture'
          data: selection)

    when 'image'
      display message.data
