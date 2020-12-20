// Enable chromereload by uncommenting this line:
// import 'chromereload/devonly'

console.log(`'Allo 'Allo! Content script`);

var textList = document.body.innerText.split('\n')

textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')
// console.log(res)

import * as kuromoji from 'kuromoji';

const builder = kuromoji.builder({
    dicPath: chrome.extension.getURL("resources/dict")
})
  
var tf: { [word: string]: number } = {};

builder.build((err, tokenizer) => {
    if (err) return;

    var word_num = 0;
    var tokens = tokenizer.tokenize(res);
    // console.dir(tokens);
    for (var token in tokens) {
        var word = tokens[token].basic_form
        // console.log(tokens[token].basic_form)
        if (word != "*") {
            word_num++;
            if (tf[word]) {
                tf[word]++;
            } else {
                tf[word] = 1;
            }
        }
    }
    for (var word in tf) {
        tf[word] = tf[word] / word_num;
    }
    // console.log(tf)
})

var idf_URL = chrome.extension.getURL("resources/words_idf.json")

const axios = require('axios')

var idf: { [word: string]: number } = {};

axios.get(idf_URL)
    .then(function (response: any) {
        idf = response.data;      
    })
    .catch(function (error:any) {
        console.log("*** error ***")
        console.log(error)
        })
    .then(function () {
        var tfidf = [];

        for (var word in tf) {
            const word_idf = idf[word] || 0;
            tfidf.push({key: word, value: tf[word] * word_idf})
        }

        tfidf.sort(function(a,b){
            if(a.value < b.value) return 1;
            if(a.value > b.value) return -1;
            return 0;
        });
        console.log("tf-idf list")
        console.log(tfidf)
        console.log ("Keyword: "+tfidf[0].key)
    })
