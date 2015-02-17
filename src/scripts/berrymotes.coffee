window.$ = window.jQuery = require "jquery"

# Berrytube "lib"
`(function($){
  $.fn.timeOut = function(duration,callback) {
    return this.each(function() {
      var me = $(this);
      me.css('position','relative');
      me.css('cursor','pointer');
      var resolution = 100;
      var height = me.height();
      var d = height / duration * resolution;
      var timer = $('<div/>').appendTo(me);
      timer.css('position','absolute');
      timer.css('background',me.css('color'));
      timer.css('bottom','0');
      timer.addClass("timerTicker");
      timer.height(height);
      timer.width(me.width());
      var x = 0;
      function timeOut(){
        clearInterval(x);
        if(callback)callback();
        timer.remove();
        me.unbind('click');
        me.css('cursor','default');
      }
      var x = setInterval(function(){
        height -= d;
        if(height <= 0){
          timeOut();
        } else {
          timer.height(height);
        }
      },resolution);
      $(this).click(function(){
        timeOut();
      });
      console.log(height);
    });
  };
})(jQuery);

(function($){
  $.fn.confirmClick = function(callback) {
    return this.each(function() {
      var btn = $(this);
      var origText = $(btn).children("span").text();
      btn.revert = function(){
        $(btn).removeClass("confirm",200,function(){
          $(btn).css('width','');
          $(btn).children("span").text(origText);
        });
      }
      $(btn).dblclick(function(){
        if(callback)callback();
        btn.revert();
      });
      $(btn).click(function(){
        if($(btn).hasClass("confirm")){
          $(btn).dblclick();
        } else {
          $(btn).data("w",$(btn).width());
          $(btn).addClass("confirm",200,function(){
            $(btn).width($(btn).data("w"));
            $(btn).children("span").text("Really?");
            setTimeout(function(){
              btn.revert();
            },3000);
          });
        }
      });
    });
  };
})(jQuery);

(function($){
  $.fn.superSelect = function(data) {
    return this.each(function() {
      var on = $(this);
      var dropDown = $('<div/>').attr('id','dd-jquery').appendTo('body');

      var mhtml = "";
      $(data.options).each(function(key,val){
        var op = $(val).clone().appendTo(dropDown);
        op.css('cursor','pointer');
        op.click(function(){
          if(data.callback)data.callback($(val));
          dropDown.remove();
        });
      });

      var t = on.offset().top// + on.outerHeight(true)
      var l = on.offset().left;
      dropDown.css({
        position:"absolute",
        background:"white",
        height:"100px",
        overflowY:"scroll",
        border:"1px solid black",
        top:t,
        left:l,
        zIndex:1000
      });
      dropDown.show("blind");
    });
  };
})(jQuery);

(function($){
  $.fn.dialogWindow = function(data) {

    var parent = $('body');
    var myData = {
      title: "New Window",
      uid: false,
      offset:{
        top:0,
        left:0
      },
      onClose: false,
      center:false,
      toolBox:false,
      initialLoading:false
    }
    for(var i in data){
      myData[i] = data[i];
    }

    //Tweak data
    myData.title = myData.title.replace(/ /g,'&nbsp;');

    //get handle to window list.
    var windows = $(parent).data('windows');
    if(typeof windows == "undefined"){
      $(parent).data('windows',[]);
      windows = $(parent).data('windows');
    }

    // Remove old window if new uid matches an old one.
    if(myData.uid != false){
      $(windows).each(function(key,val){
        if($(val).data('uid') == myData.uid){
          val.close();
        }
      });
    }

    // Create Window
    var newWindow = $('<div/>').appendTo(parent);
    newWindow.addClass("dialogWindow");
    newWindow.data('uid',myData.uid);
    newWindow.css('z-index','999');
    newWindow.close = function(){
      var windows = $(parent).data('windows');
      windows.splice(windows.indexOf(this),1);
      $(this).fadeOut('fast',function(){
        $(this).remove();
      });
      if(myData.onClose)myData.onClose();
    };
    newWindow.setLoaded = function(){
      $(newWindow).find(".loading").remove();
    };
    newWindow.winFocus = function(){
      var highestWindow = false;
      var highestWindowZ = 0;
      var windows = $(parent).data('windows');
      for(var i in windows){
        if($(windows[i]) == $(this)) continue;
        var hisZ = $(windows[i]).css('z-index');
        if(hisZ > highestWindowZ){
          highestWindow = $(windows[i]);
          highestWindowZ = parseInt(hisZ);
        }
      }
      if($(highestWindow) !== $(this)){
        var newval = (highestWindowZ+1);
        $(this).css('z-index',newval);
      }
    }
    newWindow.mousedown(function(){
      newWindow.winFocus()
    });

    windows.push(newWindow);

    if(myData.toolBox){
      $(document).bind("mouseup.rmWindows",function (e){
        var container = newWindow;
        if (container.has(e.target).length === 0){
          container.close();
          $(document).unbind("mouseup.rmWindows");
        }
      });
    }

    if(!myData.toolBox){
      // Toolbar
      var toolBar = $('<div/>').addClass("dialogToolbar").prependTo(newWindow);
      newWindow.draggable({
        handle:toolBar,
        start: function() {
        },
        stop: function() {
        }
      });

      // Title
      var titleBar = $('<div/>').addClass("dialogTitlebar").appendTo(toolBar).html(myData.title);

      // Close Button
      var closeBtn = $('<div/>').addClass("close").appendTo(toolBar);
      closeBtn.click(function(){
        newWindow.close();
      });

      //break
      $('<div/>').css("clear",'both').appendTo(toolBar);
    }

    var contentArea = $('<div/>').appendTo(newWindow).addClass("dialogContent");
    contentArea.window = newWindow;

    // Position window
    if(myData.center){
      newWindow.center();
    } else {
      newWindow.offset(myData.offset);
    }

    // Handle block for loading.
    if(data.initialLoading){
      var block = $('<div/>').addClass("loading").prependTo(newWindow);
    }
    newWindow.winFocus();
    newWindow.fadeIn('fast');

    return contentArea;
  };
})(jQuery);

jQuery.fn.center = function () {
    this.css("position","absolute");
    this.css("top", Math.max(0, (($(window).height() - this.outerHeight()) / 2) + $(window).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft()) + "px");
    return this;
}

function whenExists(objSelector,callback){
  var guy = $(objSelector);
  if(guy.length <= 0){
    setTimeout(function(){
      whenExists(objSelector,callback)
    },100);
  } else {
    callback(guy);
  }
}

function getVal(name){
  return $(document).data(name);
}
function setVal(name,val){
  return $(document).data(name,val);
}

function waitForFlag(flagname,callback){
  var flag = getVal(flagname);
  if(!flag){
    setTimeout(function(){
      waitForFlag(flagname,callback)
    },100);
  } else {
    callback();
  }
}

function waitForNegativeFlag(flagname, callback) {
  var flag = getVal(flagname);
  if (flag) {
    setTimeout(function() {
      waitForNegativeFlag(flagname,callback);
    }, 100);
  }
  else {
    callback();
  }
}


/*
// Input 0
/*

 uDeferred library

 @author David Mzareulyan
 @copyright 2011 David Mzareulyan
 @license http://creativecommons.org/licenses/by/3.0/
(function () {
    var a = window,
        f;
    f = typeof a.jQuery !== "undefined" && typeof a.jQuery.Deferred !== "undefined" ? a.Deferred = a.jQuery.Deferred : a.Deferred = function () {
        if (!(this instanceof arguments.callee)) return new f;
        var h = [0, [],
                []
            ],
            a = 0,
            o, e = null,
            n, m = this,
            i = function (k, e, n) {
                if (!a) {
                    a = k;
                    o = e;
                    for (k = h[k]; k.length;) k.shift().apply(n, o);
                    h = null;
                    return m
                }
            },
            t = function (k, e) {
                a == k ? e.apply(this, o) : a || h[k].push(e);
                return this
            };
        m.promise = function (k) {
            if (!k && e) return e;
            e = k ? k : e ? e : {};
            for (var a in n) n.hasOwnProperty(a) &&
                (e[a] = n[a]);
            return e
        };
        m.resolve = function () {
            return i(1, arguments, e)
        };
        m.reject = function () {
            return i(2, arguments, e)
        };
        m.resolveWith = function () {
            var k = Array.prototype.slice.call(arguments),
                a = k.shift();
            return i(1, k, a)
        };
        m.rejectWith = function () {
            var a = Array.prototype.slice.call(arguments),
                e = a.shift();
            return i(2, a, e)
        };
        n = {
            done: function (a) {
                return t.call(this, 1, a)
            },
            fail: function (a) {
                return t.call(this, 2, a)
            },
            then: function (a, e) {
                return this.done(a).fail(e)
            },
            always: function (a) {
                return this.then(a, a)
            },
            isResolved: function () {
                return a ==
                    1
            },
            isRejected: function () {
                return a == 2
            },
            promise: function () {
                return this
            }
        }
    };
    var i = function (a, i) {
        return function () {
            return a.apply(i, arguments)
        }
    };
    f.pipeline = function () {
        var a, p = arguments,
            o, e = function () {
                if (o.length) {
                    var n = o.shift().apply(null, arguments);
                    typeof n.promise == "function" ? n.promise().then(e, i(a.reject, a)) : e.apply(null, [n])
                } else a.resolve.apply(a, arguments)
            };
        return function () {
            a = new f;
            o = Array.prototype.slice.call(arguments);
            e.apply(null, p);
            return a.promise()
        }
    }
}).call(window);
// Input 1
/*

 CRC32

 @author David Mzareulyan
 @copyright 2011 David Mzareulyan
 @license http://creativecommons.org/licenses/by/3.0/
(function () {
    for (var a = window, f = Array(256), i = 0; i < 256; i++) {
        for (var h = i, p = 0; p < 8; p++) h = h & 1 ? 3988292384 ^ h >>> 1 : h >>> 1;
        f[i] = h
    }
    a.crc32 = function (a) {
        for (var e = -1, h = 0, m = a.length; h < m; h++) e = e >>> 8 ^ f[(e ^ a.charCodeAt(h)) & 255];
        return e ^ -1
    }
}).call(window);
// Input 2
/*

 APNG-canvas

 @author David Mzareulyan
 @copyright 2011 David Mzareulyan
 @link https://github.com/davidmz/apng-canvas
 @license https://github.com/davidmz/apng-canvas/blob/master/LICENSE (MIT License)
(function () {
    var a = window,
        f = a.jQuery || null,
        i = !!document.getCSSCanvasContext,
        h = a.APNG = {},
        p = null;
    h.checkNativeFeatures = function (b) {
        var d = !p,
            c = d ? p = new Deferred : p;
        b && c.promise().done(b);
        if (!d) return c.promise();
        var a = {
                canvas: !1,
                apng: !1
            },
            e = document.createElement("canvas");
        if (typeof e.getContext == "undefined") c.resolve(a);
        else {
            a.canvas = !0;
            var g = new Image;
            g.onload = function () {
                var b = e.getContext("2d");
                b.drawImage(g, 0, 0);
                if (b.getImageData(0, 0, 1, 1).data[3] === 0) a.apng = !0;
                c.resolve(a)
            };
            g.src =
                "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACGFjVEwAAAABAAAAAcMq2TYAAAANSURBVAiZY2BgYPgPAAEEAQB9ssjfAAAAGmZjVEwAAAAAAAAAAQAAAAEAAAAAAAAAAAD6A+gBAbNU+2sAAAARZmRBVAAAAAEImWNgYGBgAAAABQAB6MzFdgAAAABJRU5ErkJggg=="
        }
        return c.promise()
    };
    var o = null;
    h.ifNeeded = function (b) {
        var a = !o,
            c = a ? o = new Deferred : o;
        b && c.promise().done(b);
        if (!a) return c.promise();
        if (location.protocol != "http:" && location.protocol != "https:") return c.reject("apng-canvas doesn't work on pages loaded by '" + location.protocol +
            "' protocol"), c.promise();
        this.checkNativeFeatures().done(function (b) {
            b.canvas && !b.apng ? c.resolve() : (b.canvas || c.reject("Browser doesn't support canvas"), b.apng && c.reject("Browser has native APNG support"))
        }).done(function () {
            c.reject()
        });
        return c.promise()
    };
    h.createAPNGCanvas = function (b, a) {
        var c = new Deferred;
        a && c.promise().done(a);
        s.createFromUrl(b).done(function () {
            c.resolve(this.addCanvas())
        }).fail(r(c.reject, c));
        return c.promise()
    };
    h.animateImage = function (b) {
        if (i) {
            var d = new Deferred;
            b.hasAttribute("data-is-apng") ?
                d.reject("Image already animated") : (b.setAttribute("data-is-apng", "progress"), s.createFromUrl(b.src).done(function () {
                    var c = this.getCSSCanvasContextName();
                    if (!b.hasAttribute("width") && !b.style.width) b.style.width = a.getComputedStyle(b).width;
                    if (!b.hasAttribute("height") && !b.style.height) b.style.height = a.getComputedStyle(b).height;
                    b.setAttribute("data-is-apng", "yes");
                    b.style.content = "-webkit-canvas(" + c + ")";
                    d.resolve()
                }).fail(function () {
                    b.setAttribute("data-is-apng", "no")
                }).fail(r(d.reject, d)));
            return d.promise()
        } else return this.replaceImage(b)
    };
    h.replaceImage = function (b) {
        if (b.hasAttribute("data-is-apng")) {
            var a = new Deferred;
            a.reject("Image already animated");
            return a.promise()
        } else return b.setAttribute("data-is-apng", "progress"), h.createAPNGCanvas(b.src).done(function (a) {
            for (var d = 0; d < b.attributes.length; d++) {
                var e = b.attributes[d];
                ["alt", "src", "usemap", "ismap"].indexOf(e.nodeName) == -1 && a.setAttributeNode(e.cloneNode())
            }
            a.setAttribute("data-apng-src", b.src);
            if (f && (d = f(b).data("events")))
                for (var g in d)
                    for (var e = 0, h = d[g].length; e < h; e++) {
                        var u =
                            d[g][e];
                        f(a).bind(g + (u.namespace ? "." : "") + u.namespace, u.data, u.handler)
                    }
            g = b.parentNode;
            g.insertBefore(a, b);
            g.removeChild(b)
        }).fail(function () {
            b.setAttribute("data-is-apng", "no")
        })
    };
    var e = String.fromCharCode(137, 80, 78, 71, 13, 10, 26, 10),
        n = 1,
        m = function (b) {
            for (var a = 0, c = 0; c < 4; c++) a += b.charCodeAt(c) << (3 - c) * 8;
            return a
        },
        A = function (b) {
            for (var a = 0, c = 0; c < 2; c++) a += b.charCodeAt(c) << (1 - c) * 8;
            return a
        },
        t = function (b, a) {
            var c = "";
            c += k(a.length);
            c += b;
            c += a;
            c += k(crc32(b + a));
            return c
        },
        k = function (b) {
            return String.fromCharCode(b >>
                24 & 255, b >> 16 & 255, b >> 8 & 255, b & 255)
        },
        x = function () {
            this.parts = []
        };
    x.prototype.append = function (b) {
        this.parts.push(b)
    };
    x.prototype.getUrl = function (b) {
        return a.btoa ? "data:" + b + ";base64," + btoa(this.parts.join("")) : "data:" + b + "," + escape(this.parts.join(""))
    };
    var r = function (b, a) {
        return function () {
            return b.apply(a, arguments)
        }
    };
    typeof XMLHttpRequest.prototype.responseBody != "undefined" && typeof document.addEventListener != "undefined" && document.addEventListener("DOMContentLoaded", function () {
        var b = document.createElement("script");
        b.setAttribute("type", "text/vbscript");
        b.text = "Function APNGIEBinaryToBinStr(Binary)\r\n   APNGIEBinaryToBinStr = CStr(Binary)\r\nEnd Function\r\n";
        document.body.appendChild(b)
    });
    var v = [];
    (function () {
        if (v.length)
            for (var b = v.splice(0, v.length), a = (new Date).getTime(); b.length;) b.shift().call(null, a);
        setTimeout(arguments.callee, 1E3 / 60)
    })();
    var w = a.requestAnimationFrame || a.webkitRequestAnimationFrame || a.mozRequestAnimationFrame || a.oRequestAnimationFrame || function (a) {
            v.push(a)
        },
        B = function (a) {
            typeof a !=
                "number" && (a = a.getTime());
            for (var d = 0; d < y.length; d++)
                for (var c = y[d]; c.isActive && c.nextRenderTime <= a;) c.renderFrame(a);
            w(B)
        };
    w(B);
    var s = function () {
            var a = this;
            this.isActive = !1;
            this.numPlays = this.height = this.width = this.nextRenderTime = 0;
            this.frames = [];
            this.playTime = 0;
            var d = new Deferred;
            this.whenReady = r(d.promise, d);
            this.parsePNGData = function (c) {
                if (c.substr(0, 8) != e) return d.reject("Invalid PNG file signature"), d.promise();
                var g, C = "",
                    h = "",
                    i = !1,
                    l = 8,
                    j = null;
                do {
                    var f = m(c.substr(l, 4)),
                        n = c.substr(l + 4, 4),
                        q;
                    switch (n) {
                    case "IHDR":
                        g =
                            q = c.substr(l + 8, f);
                        this.width = m(q.substr(0, 4));
                        this.height = m(q.substr(4, 4));
                        break;
                    case "acTL":
                        i = !0;
                        this.numPlays = m(c.substr(l + 8 + 4, 4));
                        break;
                    case "fcTL":
                        j && this.frames.push(j);
                        q = c.substr(l + 8, f);
                        j = {};
                        j.width = m(q.substr(4, 4));
                        j.height = m(q.substr(8, 4));
                        j.left = m(q.substr(12, 4));
                        j.top = m(q.substr(16, 4));
                        var o = A(q.substr(20, 2)),
                            p = A(q.substr(22, 2));
                        p == 0 && (p = 100);
                        j.delay = 1E3 * o / p;
                        if (j.delay <= 10) j.delay = 100;
                        this.playTime += j.delay;
                        j.disposeOp = q.charCodeAt(24);
                        j.blendOp = q.charCodeAt(25);
                        j.dataParts = [];
                        break;
                    case "fdAT":
                        j &&
                            j.dataParts.push(c.substr(l + 8 + 4, f - 4));
                        break;
                    case "IDAT":
                        j && j.dataParts.push(c.substr(l + 8, f));
                        break;
                    case "IEND":
                        h = c.substr(l, f + 12);
                        break;
                    default:
                        C += c.substr(l, f + 12)
                    }
                    l += 12 + f
                } while (n != "IEND" && l < c.length);
                j && this.frames.push(j);
                if (!i) return d.reject("Non-animated PNG"), d.promise();
                for (var r = 0, s = this, c = 0; c < this.frames.length; c++) {
                    i = new Image;
                    j = this.frames[c];
                    j.img = i;
                    i.onload = function () {
                        r++;
                        r == s.frames.length && d.resolveWith(a)
                    };
                    i.onerror = function () {
                        d.reject("Image creation error")
                    };
                    l = new x;
                    l.append(e);
                    g = k(j.width) + k(j.height) + g.substr(8);
                    l.append(t("IHDR", g));
                    l.append(C);
                    for (f = 0; f < j.dataParts.length; f++) l.append(t("IDAT", j.dataParts[f]));
                    l.append(h);
                    i.src = l.getUrl("image/png");
                    delete j.dataParts
                }
                return d.promise()
            };
            var c = [];
            this.addCanvas = function () {
                var a = document.createElement("canvas");
                a.width = this.width;
                a.height = this.height;
                var b = a.getContext("2d");
                c.push(b);
                c.length > 1 && w(function () {
                    b.putImageData(c[0].getImageData(0, 0, a.width, a.height), 0, 0)
                });
                this.isActive = !0;
                return a
            };
            var h = null;
            this.getCSSCanvasContextName =
                function () {
                    if (!h) {
                        h = "apng-canvas-css-" + n++;
                        var d = document.getCSSCanvasContext("2d", h, this.width, this.height);
                        c.push(d);
                        c.length > 1 && w(function () {
                            d.putImageData(c[0].getImageData(0, 0, a.width, a.height), 0, 0)
                        });
                        this.isActive = !0
                    }
                    return h
                };
            var i = 0,
                g = null,
                f = function (a, b) {
                    for (var d = 0; d < c.length; d++) c[d][a].apply(c[d], b)
                };
            this.renderFrame = function (a) {
                if (c.length != 0) {
                    var b = i++ % this.frames.length,
                        d = this.frames[b];
                    if (b == 0 && (f("clearRect", [0, 0, this.width, this.height]), g = null, d.disposeOp == 2)) d.disposeOp = 1;
                    g && g.disposeOp ==
                        1 ? f("clearRect", [g.left, g.top, g.width, g.height]) : g && g.disposeOp == 2 && f("putImageData", [g.iData, g.left, g.top]);
                    g = d;
                    g.iData = null;
                    if (g.disposeOp == 2) g.iData = c[0].getImageData(d.left, d.top, d.width, d.height);
                    d.blendOp == 0 && f("clearRect", [d.left, d.top, d.width, d.height]);
                    f("drawImage", [d.img, d.left, d.top]);
                    if (this.numPlays == 0 || i / this.frames.length < this.numPlays) {
                        if (this.nextRenderTime == 0) this.nextRenderTime = a;
                        for (; a > this.nextRenderTime + this.playTime;) this.nextRenderTime += this.playTime;
                        this.nextRenderTime +=
                            d.delay
                    } else this.isActive = !1
                }
            }
        },
        D = function (b) {
            var d = new Deferred,
                c = new XMLHttpRequest,
                e = a.BlobBuilder || a.WebKitBlobBuilder,
                h = typeof c.responseBody != "undefined",
                g = typeof c.responseType != "undefined" && typeof e != "undefined",
                f = typeof c.overrideMimeType != "undefined" && !g;
            c.open("GET", b, !0);
            g ? c.responseType = "arraybuffer" : f && c.overrideMimeType("text/plain; charset=x-user-defined");
            c.onreadystatechange = function () {
                if (this.readyState == 4 && this.status == 200)
                    if (g) {
                        var a = new e;
                        a.append(this.response);
                        var b = new FileReader;
                        b.onload = function () {
                            d.resolve(this.result)
                        };
                        b.readAsBinaryString(a.getBlob())
                    } else {
                        a = "";
                        if (h)
                            for (var b = APNGIEBinaryToBinStr(this.responseBody), f = 0, i = b.length; f < i; f++) {
                                var k = b.charCodeAt(f);
                                a += String.fromCharCode(k & 255, k >> 8 & 255)
                            } else {
                                b = this.responseText;
                                f = 0;
                                for (i = b.length; f < i; ++f) a += String.fromCharCode(b.charCodeAt(f) & 255)
                            }
                        d.resolve(a)
                    } else this.readyState == 4 && d.reject(c)
            };
            c.send();
            return d.promise()
        },
        y = [],
        z = {};
    s.createFromUrl = function (a) {
        var d;
        a in z ? d = z[a] : (d = new s, z[a] = d, y.push(d), Deferred.pipeline(a)(D,
            r(d.parsePNGData, d)));
        console.log("Added", d, y)
        while(y.length > Bem.effectTTL) {
          y.shift();
          console.log("Removing animation")
        }
        return d.whenReady()
    }
    h.animationStack = y;
}).call(window);
*/
`

require('apng-canvas')

window.Bem = (if typeof Bem is "undefined" then {} else Bem)
Bem.jQuery = jQuery
Bem.community = "bt"
berrytube_settings_schema = [
  {
    key: "drunkMode"
    type: "bool"
    default: false
  }
  {
    key: "effectTTL"
    type: "int"
    default: 20
  }
]
Bem.loggingIn = false
Bem.refreshers = [
  "marminator"
  "toastdeib"
  "miggyb"
  "jerick"
]

handleText = (node) ->
  Bem.applyEmotesToTextNode node
  return
Bem.walk = (node) ->
  # return
  child = undefined
  next = undefined
  switch node.nodeType
    when 1, 9, 11
      child = node.firstChild
      while child
        next = child.nextSibling
        Bem.walk child
        child = next
    when 3
      handleText node

applyAnimation = (emote, $emote) ->

    return if $emote.data("emote-applied")
    
    APNG.parseURL(emote.apng_url).then (anim) ->
        $emote.data("emote-applied", true)
        # console.log anim, $emote
        canvas = document.createElement("canvas")
        canvas.width = anim.width
        canvas.height = anim.height

        position = (emote['background-position'] || ['0px', '0px']);
        $canvas = $(canvas);
        $emote.prepend(canvas);
        $canvas.css('position', 'absolute');
        $canvas.css('left', position[0]);
        $canvas.css('top', position[1]);
        anim.addContext(canvas.getContext("2d"))
        anim.numPlays = Math.floor(60000/anim.playTime)
        anim.rewind()
        anim.play()


Bem.berrySiteInit = ->
  Bem.loadSettings berrytube_settings_schema, ->
    invertScript = undefined
    if document.body.style.webkitFilter isnt `undefined`
      invertScript = document.createElement("script")
      invertScript.type = "text/javascript"
      invertScript.src = "http://berrymotes.com/berrymotes.webkit.invert.js"
      document.body.appendChild invertScript
    else
      invertScript = document.createElement("script")
      invertScript.type = "text/javascript"
      invertScript.src = "http://berrymotes.com/berrymotes.invertfilter.js"
      document.body.appendChild invertScript
    # Bem.injectEmoteButton "#chatControls"

    Bem.doneLoading = true

    return

  return


do (postEmoteEffects =  Bem.postEmoteEffects) ->
  Bem.postEmoteEffects = (node, isSearch) ->
    postEmoteEffects(node, isSearch, Bem.effectTTL)

$.fn.bindFirst = (name, fn) ->
  @on name, fn
  @each ->
    handlers = $._data(this, "events")[name.split(".")[0]]
    handler = handlers.pop()
    handlers.splice 0, 0, handler
    return

  return

# Bem.monkeyPatchTabComplete = ->
#   oldTabComplete = tabComplete
#   tabComplete = (elem) ->
#     chat = elem.val()
#     ts = elem.data("tabcycle")
#     i = elem.data("tabindex")
#     hasTS = false
#     hasTS = true  if typeof ts isnt "undefined" and ts isnt false
#     if hasTS is false
#       console.log "New Tab"
#       endword = /\\\\([^ ]+)$/i
#       m = chat.match(endword)
#       if m
#         emoteToComplete = m[1]
#         console.log "Found emote to tab complete: ", emoteToComplete  if Bem.debug
#       else
#         return oldTabComplete(elem)
#       re = new RegExp("^" + emoteToComplete + ".*", "i")
#       ret = []
#       for i of Bem.map
#         if Bem.isEmoteEligible(Bem.emotes[Bem.map[i]])
#           m = i.match(re)
#           ret.push m[0]  if m
#       ret.sort()
#       if ret.length is 1
#         x = chat.replace(endword, "\\\\" + ret[0])
#         elem.val x
#       if ret.length > 1
#         ts = []
#         for i of ret
#           x = chat.replace(endword, "\\\\" + ret[i])
#           ts.push x
#         elem.data "tabcycle", ts
#         elem.data "tabindex", 0
#         hasTS = true
#         console.log elem.data()
#     if hasTS is true
#       console.log "Cycle"
#       ts = elem.data("tabcycle")
#       i = elem.data("tabindex")
#       elem.val ts[i]
#       i = 0  if ++i >= ts.length
#       elem.data "tabindex", i
#     ret

#   return

Bem.siteSettings = (configOps) ->

  #----------------------------------------
  row = $("<div/>").appendTo(configOps)
  $("<span/>").text("Drunk mode (prevents accidental navigation): ").appendTo row
  drunkMode = $("<input/>").attr("type", "checkbox").appendTo(row)
  drunkMode.attr "checked", "checked"  if Bem.drunkMode
  drunkMode.change ->
    enabled = $(this).is(":checked")
    Bem.drunkMode = enabled
    Bem.settings.set "drunkMode", enabled
    return


  #----------------------------------------
  row = $("<div/>").appendTo(configOps)
  $("<span/>").text("Max chat lines to keep effects running on (saves CPU):").appendTo row
  chatTTL = $("<input/>").attr("type", "text").val(Bem.effectTTL).addClass("small").appendTo(row)
  chatTTL.css "text-align", "center"
  chatTTL.css "width", "30px"
  chatTTL.keyup ->
    Bem.effectTTL = chatTTL.val()
    Bem.settings.set "effectTTL", chatTTL.val()
    return


  #----------------------------------------
  row = $("<div/>").appendTo(configOps)
  refresh = $("<button>Refresh Data</button>").appendTo(row)
  refresh.click ->
    Bem.dataRefresh()
    return

  return

Bem.settings =
  get: (key, callback) ->
    val = localStorage.getItem(key)
    callback val
    return

  set: (key, val, callback) ->
    localStorage.setItem key, val
    callback()  if callback
    return

Bem.settings.set "siteWhitelist", [
  "berrytube.tv"
  "www.berrytube.tv"
]

#Bem.emoteRefresh = function() {
#    $.getScript('http://backstage.berrytube.tv/marminator/berrymotes_data.js', function () {
#        Bem.buildEmoteMap();
#    });
#};
Bem.emoteRefresh = (cache) ->
  cache = cache or true
  $.ajax
    cache: cache
    url: "http://berrymotes.com/assets/berrymotes_json_data.json"
    dataType: "json"
    success: (data) ->
      Bem.applyAnimation = applyAnimation
      Bem.emotes = data
      Bem.buildEmoteMap()
      Bem.walk document.body

      Bem.emotes.forEach (em) ->
        img = em["background-image"]
        if img?.indexOf("//") == 0
          em["background-image"] = "http:#{img}"

      scroller = document.getElementById("scroller")
      scroller.scrollTop = scroller.scrollHeight

      return

  return

Bem.apngSupported = true

script = document.createElement("script")
script.type = "text/javascript"
script.src = "http://berrymotes.com/berrymotes.core.js"
document.body.appendChild script

module.exports = Bem;

# `angular.module('ngBerrytubeApp').service("bemSearch", function(){ return function (term) {
#             var searchResults = [];
#             var distances = [];
#             Bem.berryEmoteSearchTerm = term;

#             if (!term) {
#                 var max = Bem.emotes.length;
#                 for (var i = 0; i < max; ++i) {
#                     var emote = Bem.emotes[i];
#                     if (Bem.isEmoteEligible(emote)) {
#                         searchResults.push(i);
#                     }
#                 }
#             }
#             else {
#                 var searchBits = term.split(' ');
#                 var tags = [];
#                 var srs = [];
#                 var terms = [];
#                 var scores = {};
#                 var srRegex = /^([-+]?sr:)|([-+]?[/]?r\/)/i;
#                 var tagRegex = /^[-+]/i;

#                 var sdrify = function (str) {
#                     return new RegExp('^' + str, 'i');
#                 }

#                 for (var i = 0; i < searchBits.length; ++i) {
#                     var bit = $.trim(searchBits[i]);
#                     if (bit.match(srRegex)) {
#                         var trim = bit.match(srRegex)[0].length;
#                         if (bit[0] == '-' || bit[0] == '+') {
#                             srs.push({match: bit[0] != '-', sdr: sdrify(bit.substring(trim))});
#                         } else {
#                             srs.push({match: true, sdr: sdrify(bit.substring(trim))});
#                         }
#                     } else if (bit.match(tagRegex)) {
#                         var trim = bit.match(tagRegex)[0].length;
#                         var tag = bit.substring(trim);
#                         var tagRegex = tag in Bem.tagRegexes ? sdrify(Bem.tagRegexes[tag]) : sdrify(tag);
#                         tags.push({match: bit[0] != '-', sdr: tagRegex});
#                     } else {
#                         terms.push({
#                             any: new RegExp(bit, 'i'),
#                             prefix: sdrify(bit),
#                             exact: new RegExp('^' + bit + '$')
#                         });
#                     }
#                 }

#                 var max = Bem.emotes.length;
#                 for (var i = 0; i < max; ++i) {
#                     var emote = Bem.emotes[i];
#                     if (!Bem.isEmoteEligible(emote)) continue;
#                     var negated = false;
#                     for (var k = 0; k < srs.length; ++k) {
#                         var match = emote.sr.match(srs[k].sdr) || [];
#                         if (match.length != srs[k].match) {
#                             negated = true;
#                         }
#                     }
#                     if (negated) continue;
#                     if (tags.length && (!emote.tags || !emote.tags.length)) continue;
#                     if (emote.tags && tags.length) {
#                         for (var j = 0; j < tags.length; ++j) {
#                             var tagSearch = tags[j];
#                             var match = false;
#                             for (var k = 0; k < emote.tags.length; ++k) {
#                                 var tag = emote.tags[k];
#                                 var tagMatch = tag.match(tagSearch.sdr) || [];
#                                 if (tagMatch.length) {
#                                     match = true;
#                                 }
#                             }
#                             if (match != tagSearch.match) {
#                                 negated = true;
#                                 break;
#                             }
#                         }
#                     }
#                     if (negated) continue;
#                     if (terms.length) {
#                         for (var j = 0; j < terms.length; ++j) {
#                             var term = terms[j];
#                             var match = false;
#                             for (var k = 0; k < emote.names.length; ++k) {
#                                 var name = emote.names[k];
#                                 if (name.match(term.exact)) {
#                                     scores[i] = (scores[i] || 0.0) + 3;
#                                     match = true;
#                                 } else if (name.match(term.prefix)) {
#                                     scores[i] = (scores[i] || 0.0) + 2;
#                                     match = true;
#                                 } else if (name.match(term.any)) {
#                                     scores[i] = (scores[i] || 0.0) + 1;
#                                     match = true;
#                                 }
#                             }
#                             for (var k = 0; k < emote.tags.length; k++) {
#                                 var tag = emote.tags[k];
#                                 if (tag.match(term.exact)) {
#                                     scores[i] = (scores[i] || 0.0) + 0.3;
#                                     match = true;
#                                 } else if (tag.match(term.prefix)) {
#                                     scores[i] = (scores[i] || 0.0) + 0.2;
#                                     match = true;
#                                 } else if (tag.match(term.any)) {
#                                     scores[i] = (scores[i] || 0.0) + 0.1;
#                                     match = true;
#                                 }
#                             }
#                             if (!match) {
#                                 delete scores[i];
#                                 negated = true;
#                                 break;
#                             }
#                         }
#                         if (negated) continue;
#                         //if (Bem.debug) console.log('Matched emote, score: ', emote, scores[i]);
#                     } else {
#                         scores[i] = 0;
#                     }
#                 }
#                 for (var id in scores) {
#                     searchResults.push(id);
#                 }
#                 searchResults.sort(function (a, b) {
#                     return scores[b] - scores[a];
#                 });
#             }

#             return searchResults;
#         }});
# `

# angular.module('ngBerrytubeApp')
#   .directive 'berrymote', ($timeout) ->
#     restrict : 'A',
#     link: (scope, elements, attrs) ->
#       return unless Bem.doneLoading
#       $timeout ->
#         Bem.walk(element) for element in elements
#         Bem.effectStack = $.grep Bem.effectStack, (effectEmote, i) ->
#             effectEmote["ttl"] -= 1;
#             if effectEmote["ttl"] >= 0
#                 return true; # keep the element in the array
#             else
#                 effectEmote["$emote"].css("animation", "none");
#                 return false;

#   .directive 'berrymoteId', ->
#     restrict : 'A',
#     link: (scope, elements, attrs) ->
#       emote = $(elements[0]).html(Bem.getEmoteHtml(Bem.emotes[attrs.berrymoteId]));
#       Bem.postEmoteEffects(emote, true)
