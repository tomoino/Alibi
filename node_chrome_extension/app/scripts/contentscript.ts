// Enable chromereload by uncommenting this line:
// import 'chromereload/devonly'

console.log(`'Allo 'Allo! Content script`);

var textList = document.body.innerText.split('\n')

textList = textList.filter(text => text.replace(" ", "").replace("　", ""))
var res = textList.join('\n')
console.log(res)

import * as kuromoji from 'kuromoji';

console.log(chrome.extension.getURL("resources/dict"))

const builder = kuromoji.builder({
    dicPath: chrome.extension.getURL("resources/dict")
})
  
builder.build((err, tokenizer) => {
    if (err) return;

    var tokens = tokenizer.tokenize(res);
    console.dir(tokens);
    for (var token in tokens) {
        console.log(tokens[token].basic_form)
    }
})
