// Enable chromereload by uncommenting this line:
// import 'chromereload/devonly'
const axios = require('axios')
import * as tfjs from '@tensorflow/tfjs';
const MAX_LENGTH = 3000;


var word_index_URL = chrome.extension.getURL("resources/word_index.json")
var word_index_json = []
var word_index: { [word: string]: number } = {};

async function predict(word_list: number[]) { 
    const model_path = chrome.extension.getURL("resources/jsmodel/model.json");
    const model = await tfjs.loadLayersModel(model_path);

    // predict
    // let word_list = []

    // for (var i = 0; i < MAX_LENGTH; i++) {
    //     word_list.push(1)
    // }

    console.log(word_list)

    const xs = tfjs.tensor2d(word_list, [1, MAX_LENGTH]);
    const y_pred = await model.predict(xs);
    console.dir(y_pred)
    console.log(JSON.stringify(y_pred))
    // // // y_pred.print();
    // for (var val in y_pred) {
    //     console.log(val)
    // }

    // convert to array
    // const values = await y_pred.data();
    // const arr = await Array.from(values);
    // console.log(arr);
}


console.log(`'Allo 'Allo! Content script`);

var textList = document.body.innerText.split('\n')

textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')
// console.log(res)

import * as kuromoji from 'kuromoji';

const builder = kuromoji.builder({
    dicPath: chrome.extension.getURL("resources/dict")
})

// CNN
let word_list: number[] = [];

// TFIDF
var tf: { [word: string]: number } = {};

// word index
axios.get(word_index_URL)
    .then(function (response: any) {
        word_index_json = response.data;
        for (var id in word_index_json) {
            const elm = word_index_json[id];
            word_index[elm.word] = Number(elm.id);
        }
    })
    .catch(function (error:any) {
        console.log("*** error ***")
        console.log(error)
    })
    .then(function () {
        // Morph
        builder.build((err, tokenizer) => {
            if (err) return;
            
            var word_num = 0;
            var tokens = tokenizer.tokenize(res);

            for (var token in tokens) {
                var word = tokens[token].basic_form
                if (word_list.length < MAX_LENGTH) {
                    if (word != "*") {
                        word_list.push(word_index[word]);
                    } else {
                        word_list.push(0);
                    }
                }
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
            
            if (word_list.length < MAX_LENGTH) {
                while (word_list.length < MAX_LENGTH) {
                    word_list.push(0)
                }
            }
            
            // CNN
            predict(word_list);
        })

    })



// TFIDF
var idf_URL = chrome.extension.getURL("resources/words_idf.json")


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
