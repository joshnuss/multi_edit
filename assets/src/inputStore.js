import { writable } from 'svelte/store'
import Phoenix from 'phoenix'

const socket = new Phoenix.Socket("/socket")

export default function createInputStore() {
  let data
  let store = writable({
    fields: {},
    cursors: {},
    users: {},
    selections: {}
  })

  socket.connect()
  let id = prompt("name")
  let channel = socket.channel("session:lobby", {id, name: id, textColor: "black", primaryColor: "turquoise"})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.error("Unable to join", resp) })

  channel.on("update", data => store.set(data))

  store.subscribe(update => { data = update })

  store.getSelection = (field) => {
    const userId = data.userId
    const selection = data.selections[userId]

    if (selection && selection.field == field)
      return selection
  }

  store.moveToStart = (field) => {
    store.setPosition(field, 0)
    store.setSelection(field, null)
  }

  store.moveToEnd = (field) => {
    const text = store.getValue(field)

    store.setPosition(field, text.length)
    store.setSelection(field, null)
  }

  store.setSelection = (field, change) => {
    const userId = data.userId

    store.update($store => {
      $store.selections[userId] = change
      return $store
    })
  }

  store.getPosition = (field) => {
    const userId = data.userId

    return data.cursors[userId][field]
  }

  store.setPosition = (field, position) => {
    channel.push("move_to", {field, position})
  }

  store.getValue = (name) => {
    return data.fields[name]
  }

  store.backspace = (field) => {
    channel.push("backspace", {field})
  }

  store.delete = (field) => {
    channel.push("delete", {field})
  }

  store.insert = (field, text) => {
    channel.push("insert", {field, text})
  }

  store.moveRight = (field) => {
    channel.push("move_x", {field, delta: 1})
  }

  store.moveLeft = (field) => {
    channel.push("move_x", {field, delta: -1})
  }

  store.moveDown = (field) => {
    channel.push("move_y", {field, delta: 1})
  }

  store.moveUp = (field) => {
    channel.push("move_y", {field, delta: -1})
  }

  store.selectRight = (field) => {
    channel.push("select_x", {field, delta: 1})
  }

  store.selectLeft = (field) => {
    channel.push("select_x", {field, delta: -1})
  }

  store.selectAll = (field) => {
    channel.push("select_all", {field})
  }

  return store
}
