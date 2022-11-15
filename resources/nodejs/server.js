const express = require('express')
const app = express()
const http = require('http');

const BACKEND_URL=process.env.BACKEND_URL || 'http://localhost'
const BACKEND_PORT=process.env.BACKEND_PORT || '18080'

app.set('view engine', 'ejs')

app.listen(8080, () => {
    console.log("server running...");
});

app.get("/", (req0, res0) => {
    req0.setTimeout(30000);
    http.get(BACKEND_URL + ':' + BACKEND_PORT + '/api', res => {

	if(res.statusCode >= 400) {
	    let chunks = [];
	    res.on('data', c => chunks.push(c))
		.on('end', () => {
		    console.log('error', Buffer.concat(chunks).toString());
		    res0.render("index", {message: '申し訳ございません。' + res.statusCode + 'エラーが、発生しています。'});
		});	    
	}

	
	let data = [];
	const headerDate = res.headers && res.headers.date ? res.headers.date : 'no response date';
	console.log('Status Code:', res.statusCode);
	console.log('Date in Response header:', headerDate);

	res.on('data', chunk => {
	    data.push(chunk);
	});

	res.on('end', () => {
	    console.log('Response ended: ');
	    const resp = Buffer.concat(data).toString();
	    
	    res0.render("index", { message: resp });
	});
    }).on('error', err => {
	console.log('Error: ', err.message);
	res0.render("index", { message: "只今、通信障害発生中です。少し時間を置いてから実行して下さい。" });	
    });
});






