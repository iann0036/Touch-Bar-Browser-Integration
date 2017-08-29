var native_port = null;

function sendNativeMessage(msg) {
  message = {"text": msg};
  native_port.postMessage(message);
}

function onNativeMessage(message) {
  
}

function onDisconnected() {
  native_port = null;
}

function connect() {
  var hostName = "com.ian.touchbar";
  native_port = chrome.runtime.connectNative(hostName);
  native_port.onMessage.addListener(onNativeMessage);
  native_port.onDisconnect.addListener(onDisconnected);
}

connect();

chrome.runtime.onMessageExternal.addListener(
  function(request, sender, sendResponse) {
    sendNativeMessage(request.youtubeStatus);
  }
);