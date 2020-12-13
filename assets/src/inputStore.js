import { writable } from 'svelte/store'
import Phoenix from 'phoenix'

const socket = new Phoenix.Socket("/socket")

export default function createInputStore() {
  let data
  let store = writable({
    userId: "josh",
    fields: {
      title: "Dank Hoodie",
      description: "It's extremely dank",
      price: "$75"
    },
    cursors: {
      josh: { title: 0 },
      susan: { title: 4 },
      tom: { description: 5, price: 1 }
    },
    users: {
      josh: {name: "Josh", textColor: "black", primaryColor: "turquoise"},
      susan: {name: "Susan", textColor: "black", primaryColor: "plum"},
      tom: {name: "Tom", textColor: "white", primaryColor: "red"}
    },
    selections: {}
  })

  socket.connect()
  let id = prompt("name")
  let channel = socket.channel("session:lobby", {id, name, textColor: "black", primaryColor: "turquoise"})
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

  store.setPosition = (field, pos) => {
    const value = store.getValue(field)
    const userId = data.userId

    if (typeof(value) == "undefined") {
      store.setValue(field, "")

      store.update($store => {
        $store.cursors = {[userId]: {[field]: pos}}
        return $store
      })
    } else {
      store.update($store => {
        $store.cursors[userId][field] = pos
        return $store
      })
    }
  }

  store.getValue = (name) => {
    return data.fields[name]
  }

  store.setValue = (name, value) => {
    store.update($store => {
      $store.fields[name] = value
      return $store
    })
  }

  store.backspace = (field) => {
    const selection = store.getSelection(field)
    const position = store.getPosition(field)
    let text = store.getValue(field)

    if (selection) {
      text = text.slice(0, selection.start) + text.substring(selection.end+1)

      store.setValue(field, text)
      store.setPosition(field, selection.start)
      store.setSelection(field, null)
    } else if (position > 0) {
      text = text.slice(0, position-1) + text.substring(position)

      store.setValue(field, text)
      store.setPosition(field, position-1 > text.length ? text.length : position-1)
    }
  }

  store.delete = (field) => {
    const selection = store.getSelection(field)
    const position = store.getPosition(field)
    let text = store.getValue(field)

    if (selection) {
      text = text.slice(0, selection.start) + text.substring(selection.end+1)

      store.setValue(field, text)
      store.setPosition(field, selection.start)
      store.setSelection(field, null)
    } else if (position < text.length) {
      text = text.slice(0, position) + text.substring(position+1)

      store.setValue(field, text)
    }
  }

  store.insert = (field, key) => {
    const selection = store.getSelection(field)
    const position = store.getPosition(field)
    let text = store.getValue(field)

    if (selection) {
      text = text.slice(0, selection.start) + text.substring(selection.end+1)
      store.setPosition(field, selection.start)
      store.setSelection(field, null)
    }

    text = text.slice(0, position) + key + text.substring(position)

    store.setValue(field, text)
    store.setPosition(field, position + 1)
  }

  store.moveLeft = (field) => {
    const position = store.getPosition(field)

    if (position > 0) {
      store.setPosition(field, position - 1)
    }

    store.setSelection(field, null)
  }

  store.moveRight = (field) => {
    const position = store.getPosition(field)
    const text = store.getValue(field)

    if (position < text.length) {
      store.setPosition(field, position + 1)
    }

    store.setSelection(field, null)
  }

  store.selectRight = (field) => {
    const position = store.getPosition(field)
    const text = store.getValue(field)

    store.select(field, +1)

    if (position < text.length) {
      store.setPosition(field, position+1)
    }
  }

  store.selectLeft = (field) => {
    const position = store.getPosition(field)
    const text = store.getValue(field)

    store.select(field, -1)

    if (position > 0) {
      store.setPosition(field, position-1)
    }
  }

  store.select = (field, n) => {
    const position = store.getPosition(field)
    const text = store.getValue(field)
    let selection = store.getSelection(field)

    if (n < 0) {
      if (!selection)
        selection = {field, start: position-1, end: position-1}
      else if (position == selection.start) {
        selection = {...selection, start: position + n}
      } else if (position-1 == selection.end) {
        selection = {...selection, end: position + n - 1}
      }
    } else if (n > 0) {
      if (!selection)
        selection = {field, start: position, end: position}
      else if (position-1 == selection.end) {
        selection = {...selection, end: position + n - 1}
      } else if (position == selection.start) {
        selection = {...selection, start: position + n}
      }
    }

    if (selection.start < 0)
      selection.start = 0
    if (selection.end > text.length)
      selection.end = text.length

    store.setSelection(field, selection)
  }

  return store
}
