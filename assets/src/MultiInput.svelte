<script>
  export let text = ""
  export let multiline = true
  export let store
  export let name
  export let id = "josh"
  export let userName = "me"
  export let lines = 1

  let showCursor = false

  $: position = $store.cursors[id][name]
  $: selection = $store.selections[id] && $store.selections[id].field == name ? $store.selections[id] : null

  function handleFocus() {
    showCursor = true

    if (typeof(position) == "undefined")
      setPosition(text.length)
  }

  function handleKeydown(e) {
    switch (e.key) {
      case "Backspace":
        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          setPosition(selection.start)
          setSelection(null)
        } else if (position > 0) {
          text = text.slice(0, position-1) + text.substring(position)
          setPosition(position-1 > text.length ? text.length : position-1)
        }

        e.preventDefault()
        break;
      case "Enter":
        if (multiline) {
          text += "\n"
          setPosition(text.length)
          e.preventDefault()
        }

        break;
      case 'Delete':
        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          setPosition(selection.start)
          setSelection(null)
        }  if (position < text.length) {
          text = text.slice(0, position) + text.substring(position+1)
        }
        e.preventDefault()
        break
      case 'ArrowLeft':
        if (e.shiftKey) {
          select(-1)
        } else {
          setSelection(null)
        }

        if (position > 0) {
          setPosition(position-1)
        }

        e.preventDefault()
        break;
      case 'ArrowRight':
        if (e.shiftKey) {
          select(+1)
        } else {
          setSelection(null)
        }

        if (position < text.length) {
          setPosition(position+1)
        }

        e.preventDefault()
        break;
      case 'Home':
        setPosition(0)
        setSelection(null)
        e.preventDefault()
        break;
      case 'End':
        setPosition(text.length)
        setSelection(null)
        e.preventDefault()
        break;
      case "ContextMenu":
      case "Shift":
      case "Insert":
      case "Alt":
      case "Control":
      case "Escape":
      case "Tab":
        break
      default:
        if (e.ctrlKey) return

        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          setPosition(selection.start)
          setSelection(null)
        }

        text = text.slice(0, position) + e.key + text.substring(position)
        setPosition(position + 1)

        e.preventDefault()
        break;
    }
  }

  function select(n) {
    if (n < 0) {
      if (!selection)
        setSelection({start: position-1, end: position-1})
      else if (position == selection.start) {
        setSelection({...selection, start: position + n})
      } else if (position-1 == selection.end) {
        setSelection({...selection, end: position + n - 1})
      }
    } else if (n > 0) {
      if (!selection)
        setSelection({start: position, end: position})
      else if (position-1 == selection.end) {
        setSelection({...selection, end: position + n - 1})
      } else if (position == selection.start) {
        setSelection({...selection, start: position + n})
      }
    }
  }

  function setSelection(change) {
    if (change == null)
      $store.selections[id] = null
    else
      $store.selections[id] = {field: name, ...change}
  }

  function setPosition(pos) {
    $store.cursors[id][name] = pos
  }

  function inSelection(selection, index) {
    return selection && index >= selection.start && index <= selection.end
  }

  function handleCharClicked(e, index) {
    e.preventDefault()
    setPosition(index)
    setSelection(null)
  }
</script>

<div class="editor" tabindex=0 on:keydown={handleKeydown} on:focus={handleFocus} on:focusout={() => showCursor = false} style="--lines: {lines}">
  {#key [...Object.values($store.cursors), ...Object.values($store.selections)]}
  {#each text.split("") as char, index}{#if showCursor && index == position}<span class="cursor local" style="--background-color: turquoise; text-color: black"><span class="name">{userName}</span></span>{/if}{#each Object.entries($store.cursors) as [userId, cursor]}{#if cursor[name] == index && userId !== $store.userId}<span class="cursor" style="--background-color: {$store.users[userId].primaryColor}; --text-color: {$store.users[userId].textColor}; --index: {index}px"><span class="name">{$store.users[userId].name}</span></span>{/if}{/each}{#if char == "\n"}<br/>{:else}<span class="char" on:click={e => handleCharClicked(e, index)} style="--background-color: {$store.users[$store.userId].primaryColor}" class:selected={inSelection(selection, index)}>{#if char == " "}&nbsp;{:else}{char}{/if}</span>{/if}{/each}{#if showCursor && text.length == position}<span class="cursor local" style="--background-color: turquoise; --text-color: black;"><span class="name">{userName}</span></span>{/if}
  {/key}
</div>

<style>
  .editor {
    border: solid 1px #bbb;
    min-height: calc((1rem + 2px) * var(--lines));
    border-radius: 1px;
    padding: 5px 6px;
  }

  .editor:focus {
    border: solid 1px #444;
  }

  .cursor {
    display: inline-block;
    position: absolute;
    width: 1px;
    background: var(--background-color);
    height: 1rem;
    margin: 2px 0 0 0;
  }

  .cursor .name {
    display: block;
    position: absolute;
    margin-top: -15px;
    background: var(--background-color);
    color: var(--text-color);
    font-size: 10px;
    padding: 2px 4px;
    border-radius: 2px 2px 2px 0;
    box-shadow: 1px 1px #ccc3;
    white-space: nowrap;
  }

  .cursor.local .name {
    z-index: 5;
  }

  .selected {
    background: var(--background-color);
  }

  .editor:focus .cursor {
    display: inline-block;
  }
</style>
