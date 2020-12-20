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
  
builder.build((err, tokenizer) => {
    if (err) return;

    var tf: { [word: string]: number } = {};
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
    for (var id in tf) {
        tf[id] = tf[id] / word_num;
    }
    console.log(tf)
})
