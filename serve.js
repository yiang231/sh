// import {createRequire} from 'module'

// const require = createRequire(import.meta.url)
const http = require('http')
const url = require('url')
const queryString = require('querystring')

const server = http.createServer((req, resp) => {
    const {pathname, query} = url.parse(req.url)
    if (req.method === 'GET') {
        if (pathname === '/get') {
            console.log(queryString.parse(query))
            resp.setHeader('Content-Type', 'text/plain;charset=utf-8')
            resp.end('响应GET请求')
        }
        if (pathname === '/exit') {
            resp.end('bye')
            server.close()
            console.log('bye')
        }
    } else if (req.method === 'POST' && pathname === '/post') {
        let data = ''
        req.on('data', temp => {
            data += temp
        })
        req.on('end', () => {
            resp.setHeader('Content-Type', 'text/plain;charset=utf-8')
            resp.end('响应POST请求')
            console.log(queryString.parse(data))
        })
    } else {
        resp.statusCode = 404
        resp.end('Not Found')
    }
})

server.listen(4567, () => {
    console.log('server is running on 4567 post')
})

process.on('SIGINT', () => {
    console.log('接收到 ctrl + c')
    server.close()
    process.exit()
})
process.on('beforeExit', () => {
    console.log('退出前')
})
process.on('exit', () => {
    console.log('退出')
})