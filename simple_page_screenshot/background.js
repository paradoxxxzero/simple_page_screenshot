// Generated by CoffeeScript 1.7.1

/*
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
 */
var image;

image = null;

chrome.extension.onMessage.addListener(function(message, sender) {
  var img, position;
  switch (message.cmd) {
    case 'capture':
      position = message.data;
      img = new Image();
      img.onload = function() {
        var canvas, ctx;
        canvas = document.createElement('canvas');
        canvas.width = position.w;
        canvas.height = position.h;
        ctx = canvas.getContext('2d');
        ctx.drawImage(img, position.x, position.y, position.w, position.h, 0, 0, position.w, position.h);
        image = null;
        return chrome.tabs.sendMessage(sender.tab.id, {
          cmd: 'image',
          data: canvas.toDataURL()
        });
      };
      return img.src = image;
  }
});

chrome.browserAction.onClicked.addListener(function(tab) {
  return chrome.tabs.captureVisibleTab(null, {
    format: 'png'
  }, function(data) {
    image = data;
    return chrome.tabs.sendMessage(tab.id, {
      cmd: 'select'
    });
  });
});