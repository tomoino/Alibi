console.log("Welcome to Alibi Chrome Extension!")
var textList = document.body.innerText.split('\n')

textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')
console.log(res)

var xhr = new XMLHttpRequest();
var baseurl = "https://alibi-api.herokuapp.com/" 
var url = baseurl+'update/1';

// xhr.open('POST', url, true);
// xhr.setRequestHeader("Content-Type", "application/json");

// var request = { event: document.title, location: "自室"};
// xhr.send(JSON.stringify(request));