// parameter
const MAX_LENGTH = 3000;
const categories = ["プロ研", "回路理論", "多変量解析", "ビジネス", "電生実験", "OS", "論文読み", "開発環境構築", "語学"]

console.log("--- ALIBI CHROME EXTENSION ---");

const axios = require('axios')
import * as tfjs from '@tensorflow/tfjs';
import * as kuromoji from 'kuromoji';

var word_index_URL = chrome.extension.getURL("resources/word_index.json")
var word_index_json = []
var word_index: { [word: string]: number } = {};

// CNN predict
async function predict(word_list: number[]) { 
    const model_path = chrome.extension.getURL("resources/jsmodel/model.json");
    const model = await tfjs.loadLayersModel(model_path);
    
    console.log("CNN input word list")
    console.log(word_list)
    
    const xs = tfjs.tensor2d(word_list, [1, MAX_LENGTH]);
    const y_pred = await model.predict(xs);
    
    console.log("CNN predict result");
    console.log(categories);
    (y_pred as tfjs.Tensor<tfjs.Rank>).print();
    
    const values = (y_pred as tfjs.Tensor<tfjs.Rank>).data().then(value => {
        let max_val = -Infinity
        let index = 0
        for (let i = 0, l = value.length; i < l; i++) {
            if (max_val < value[i]) {
                max_val = value[i]
                index = i
            }
        }
        console.log("CNN Result: " + categories[index])
        update_database(categories[index])
    });
}

async function update_database(pred: String) {
    axios.get("https://alibi-api.herokuapp.com/event/current/")
    .then(function (response: any) {
        const ev = response.data;
        console.log(ev)
        if (ev.Event) {
            ev.Event = ev.Event + "," + pred
        } else {
            ev.Event = pred
        }
        console.log(ev)
        axios.post("https://alibi-api.herokuapp.com/update/" + ev.Id, ev)
        .then(function (response: any) {
            console.log(response.data);
        })
    })
    .catch(function (error:any) {
        console.log("*** error ***")
        console.log(error)
    })
}

// get text
var textList = document.body.innerText.split('\n')
textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')

// setup kuromoji
const builder = kuromoji.builder({
    dicPath: chrome.extension.getURL("resources/dict")
})

// for CNN
let word_list: number[] = [];

// for TFIDF
var tf: { [word: string]: number } = {};
var idf: { [word: string]: number } = {};
const idf_URL = chrome.extension.getURL("resources/words_idf.json")

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
    console.log("TF-IDF list")
    console.log(tfidf)
    
    let top_keywords: string[] = [];
    for (var i = 0; i < 10; i++) {
        top_keywords.push(tfidf[i].key)
    }

    console.log("TF-IDF Result (Top 10):")
    console.log(top_keywords)
})
