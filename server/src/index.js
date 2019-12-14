const WebSocket = require('ws')
const { GdBuffer } = require('@gd-com/utils')
const packets = require("./packets")


const wss = new WebSocket.Server({ port: 8080 })

// we assume game is always client 0! Not so beatifull but works for demo proposes.
let ws_clients = [];

function sendMoveUp() {
  let packet = new GdBuffer()
  packet.putU16(packets.OK_GO_UP)

  ws_clients[0].send(packet.getBuffer())
}

function sendMoveDown() {
  let packet = new GdBuffer()
  packet.putU16(packets.OK_GO_DOWN)

  ws_clients[0].send(packet.getBuffer())
}

wss.on('connection', ws => {

  let id = ws_clients.length;
  ws_clients.push(ws);

  console.log(`[${id}] Connected`)

  ws.on('message', (message) => {
    if(id > 0) {
        if(message == packets.HAPPY) {
          sendMoveUp();
        }
        else if(message == packets.ANGRY) {
          sendMoveDown();
        }
    }
  })

})
