console.log("Welcome to Alibi Chrome Extension!")
// url
var url = location.href;
console.log(url)
console.log(url.length)

var textList = document.body.innerText.split('\n')

textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')
// console.log(res)

var xhr = new XMLHttpRequest();
var baseurl = "https://alibi-api.herokuapp.com/" 
// var url = baseurl+'update/1';

// xhr.open('POST', url, true);
// xhr.setRequestHeader("Content-Type", "application/json");

// var request = { event: document.title, location: "自室"};
// xhr.send(JSON.stringify(request));

/// 文字列をUint8Arrayに変換
function strToUint8Arr(str) {
  var str = btoa(unescape(encodeURIComponent(str))),
      charList = str.split(''), uintArray = [];
  for (var i = 0; i < charList.length; i++) {
    uintArray.push(charList[i].charCodeAt(0));
  }
  return new Uint8Array(uintArray);
}

function uint8ArrToStr(uint8Arr) {
    var encodedStr = String.fromCharCode.apply(null, uint8Arr),
        decodedStr = decodeURIComponent(escape(atob(encodedStr)));
    return decodedStr;
  }