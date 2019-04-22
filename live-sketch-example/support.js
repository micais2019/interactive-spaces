/// EventEmitter3
!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{("undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:this).EventEmitter3=e()}}(function(){return function i(s,f,c){function u(t,e){if(!f[t]){if(!s[t]){var n="function"==typeof require&&require;if(!e&&n)return n(t,!0);if(a)return a(t,!0);var r=new Error("Cannot find module '"+t+"'");throw r.code="MODULE_NOT_FOUND",r}var o=f[t]={exports:{}};s[t][0].call(o.exports,function(e){return u(s[t][1][e]||e)},o,o.exports,i,s,f,c)}return f[t].exports}for(var a="function"==typeof require&&require,e=0;e<c.length;e++)u(c[e]);return u}({1:[function(e,t,n){"use strict";var r=Object.prototype.hasOwnProperty,v="~";function o(){}function f(e,t,n){this.fn=e,this.context=t,this.once=n||!1}function i(e,t,n,r,o){if("function"!=typeof n)throw new TypeError("The listener must be a function");var i=new f(n,r||e,o),s=v?v+t:t;return e._events[s]?e._events[s].fn?e._events[s]=[e._events[s],i]:e._events[s].push(i):(e._events[s]=i,e._eventsCount++),e}function u(e,t){0==--e._eventsCount?e._events=new o:delete e._events[t]}function s(){this._events=new o,this._eventsCount=0}Object.create&&(o.prototype=Object.create(null),(new o).__proto__||(v=!1)),s.prototype.eventNames=function(){var e,t,n=[];if(0===this._eventsCount)return n;for(t in e=this._events)r.call(e,t)&&n.push(v?t.slice(1):t);return Object.getOwnPropertySymbols?n.concat(Object.getOwnPropertySymbols(e)):n},s.prototype.listeners=function(e){var t=v?v+e:e,n=this._events[t];if(!n)return[];if(n.fn)return[n.fn];for(var r=0,o=n.length,i=new Array(o);r<o;r++)i[r]=n[r].fn;return i},s.prototype.listenerCount=function(e){var t=v?v+e:e,n=this._events[t];return n?n.fn?1:n.length:0},s.prototype.emit=function(e,t,n,r,o,i){var s=v?v+e:e;if(!this._events[s])return!1;var f,c,u=this._events[s],a=arguments.length;if(u.fn){switch(u.once&&this.removeListener(e,u.fn,void 0,!0),a){case 1:return u.fn.call(u.context),!0;case 2:return u.fn.call(u.context,t),!0;case 3:return u.fn.call(u.context,t,n),!0;case 4:return u.fn.call(u.context,t,n,r),!0;case 5:return u.fn.call(u.context,t,n,r,o),!0;case 6:return u.fn.call(u.context,t,n,r,o,i),!0}for(c=1,f=new Array(a-1);c<a;c++)f[c-1]=arguments[c];u.fn.apply(u.context,f)}else{var l,p=u.length;for(c=0;c<p;c++)switch(u[c].once&&this.removeListener(e,u[c].fn,void 0,!0),a){case 1:u[c].fn.call(u[c].context);break;case 2:u[c].fn.call(u[c].context,t);break;case 3:u[c].fn.call(u[c].context,t,n);break;case 4:u[c].fn.call(u[c].context,t,n,r);break;default:if(!f)for(l=1,f=new Array(a-1);l<a;l++)f[l-1]=arguments[l];u[c].fn.apply(u[c].context,f)}}return!0},s.prototype.on=function(e,t,n){return i(this,e,t,n,!1)},s.prototype.once=function(e,t,n){return i(this,e,t,n,!0)},s.prototype.removeListener=function(e,t,n,r){var o=v?v+e:e;if(!this._events[o])return this;if(!t)return u(this,o),this;var i=this._events[o];if(i.fn)i.fn!==t||r&&!i.once||n&&i.context!==n||u(this,o);else{for(var s=0,f=[],c=i.length;s<c;s++)(i[s].fn!==t||r&&!i[s].once||n&&i[s].context!==n)&&f.push(i[s]);f.length?this._events[o]=1===f.length?f[0]:f:u(this,o)}return this},s.prototype.removeAllListeners=function(e){var t;return e?(t=v?v+e:e,this._events[t]&&u(this,t)):(this._events=new o,this._eventsCount=0),this},s.prototype.off=s.prototype.removeListener,s.prototype.addListener=s.prototype.on,s.prefixed=v,s.EventEmitter=s,void 0!==t&&(t.exports=s)},{}]},{},[1])(1)});

/// Websocket Connection

window.DEBUG = false

function WebSocketClient() {
  this.reconnect_interval = 1500;
}

WebSocketClient.prototype.open = function (url) {
  this.url = url
  this.instance = new WebSocket(this.url);

  var self = this

  this.instance.onopen = function () {
    if (window.DEBUG)
      console.log("[WebSocketClient on open]")
    self.onopen()
  }

  this.instance.onclose = function (evt) {
    if (window.DEBUG)
      console.log("[WebSocketClient on close]")
    switch (evt.code){
    case 1000:  // CLOSE_NORMAL
      if (window.DEBUG)
        console.log("WebSocketClient: closed");
      break;
    default:  // Abnormal closure
      self.reconnect(evt);
      break;
    }
    if (self.onclose)
      self.onclose(evt);
  }

  this.instance.onerror = function (evt) {
    if (window.DEBUG)
      console.log("[WebSocketClient on error]")
    switch (evt.code){
    case 'ECONNREFUSED':
      self.reconnect(evt);
      break;
    default:
      if (self.onerror) self.onerror(evt);
      break;
    }
  }

  this.instance.onmessage = function (evt) {
    if (window.DEBUG)
      console.log("[WebSocketClient on message]")
    self.onmessage(evt.data)
  }

  if (window.DEBUG)
    console.log("[WebSocketClient open] completed")
}

WebSocketClient.prototype.removeAllListeners = function () {
  this.instance.onopen = null
  this.instance.onclose = null
  this.instance.onerror = null
  this.instance.onmessage = null
}

WebSocketClient.prototype.reconnect = function (evt) {
  if (window.DEBUG)
    console.log("WebSocketClient: retry in", this.reconnect_interval, "ms", evt);
  this.removeAllListeners();

  var self = this
  setTimeout(function() {
    if (window.DEBUG)
      console.log("WebSocketClient: reconnecting...")
    self.open(self.url)
  }, this.reconnect_interval)
}

window.Socket = new EventEmitter3()

function startWebsocket(callback) {
  var sock = new WebSocketClient()
  sock.open(window.WS_URL)

  sock.onopen = function (event) {
    console.log("socket connected")
  }

  sock.onclose = function () {
    console.log("socket closed")
  }
  sock.onerror = sock.onclose

  sock.onmessage = function (data) {
    if (data instanceof Blob) {
      var reader = new FileReader()
      reader.onload = function () {
        var message = JSON.parse(reader.result)
        if (callback) {
          callback(message)
        } else {
          window.Socket.emit('data.*', message)
          if (message.key) {
            window.Socket.emit('data.' + message.key, {
              key: message.key,
              value: message.value,
              mode: message.mode ? message.mode : 'live'
            })
          } else {
            window.Socket.emit('data', message)
          }
        }
      }
      reader.readAsText(data)
    } else if (typeof data == "string") {
      var message = JSON.parse(data)
      if (callback) {
        callback(message)
      } else {
        window.Socket.emit('data.*', message)
        if (message.key) {
          window.Socket.emit('data.' + message.key, {
            key: message.key,
            value: message.value,
            mode: message.mode ? message.mode : 'live'
          })
        } else {
          window.Socket.emit('data', { message: message })
        }
      }
    }
  }
}

/// Sketch Creation

if (!window.sketches) {
  window.sketches = {}
}

function createProcessingSketch(channel, callback) {
  return function (container) {
    // console.log("[createProcessingSketch] got container")
    var sketch = function (p) {
      var self = this
      var resize = function () {
        self.width = $(container).width()
        self.height = $(container).height()
      }
      resize()

      var last_call = null

      // this function returns a Promise that serves historical data
      p.getData = function (feed_key, limit=25) {
        var now = new Date().getTime()
        if (last_call && now - last_call < 5000) {
          console.log("slow down......")
          return Promise.resolve([])
        }

        console.log("requesting")
        last_call = now
        return fetch("https://io.adafruit.com/api/v2/mica_ia/feeds/"+ feed_key + "/data?limit=" + limit).then(function (response) {
          return response.json()
        })
      }

      // user defined callback includes only the actual Processing drawing code
      callback(self, p)

      p.windowResized = _.debounce(function () {
        resize()
        p.resizeCanvas(self.width, self.height);
      }, 300)

      // give the p5 sketch time to start before pumping data
      setTimeout(function () {
        var channels
        if (!Array.isArray(channel)) {
          channels = [ channel ]
        } else {
          channels = channel
        }

        channels.forEach(function (chan) {
          window.Socket.on('data.' + chan, function (data) {
            if (p.onData) {
              p.onData(data)
            }
          })
        })
      }, 75)
    }

    return new p5(sketch, container)
  }
}
