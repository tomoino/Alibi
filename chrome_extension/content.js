console.log("Welcome to Alibi Chrome Extension!")
console.log(document.title)

var xhr = new XMLHttpRequest();
var baseurl = "https://alibi-api.herokuapp.com/" 
var url = baseurl+'update/1';

xhr.open('POST', url, true);
xhr.setRequestHeader("Content-Type", "application/json");

var request = { event: document.title, location: "自室"};
xhr.send(JSON.stringify(request));