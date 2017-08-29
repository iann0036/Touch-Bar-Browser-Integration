function str_pad_left(string,pad,length) {
  return (new Array(length+1).join(pad)+string).slice(-length);
}

setInterval(function(){
  var ytplayer = document.getElementById("movie_player");
  var title = document.title.replace(" - YouTube","");

  if (!ytplayer) return;
  if (ytplayer.getPlayerState() < 0 || ytplayer.getPlayerState() > 4) return;

  var currTime = parseInt(ytplayer.getCurrentTime());
  var duration = parseInt(ytplayer.getDuration());

  var prettyCurrTime = String(Math.floor(currTime / 60)+':'+str_pad_left((currTime - Math.floor(currTime / 60) * 60),'0',2));
  var prettyDuration = String(Math.floor(duration / 60)+':'+str_pad_left((duration - Math.floor(duration / 60) * 60),'0',2));

  chrome.runtime.sendMessage("knldjmfmopnpolahpmmgbagdohdnhkik", {
    youtubeStatus: String(title + "   " + prettyCurrTime + " / " + prettyDuration)
  });
},200);
