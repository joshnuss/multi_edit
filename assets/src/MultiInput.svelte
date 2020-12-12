<script>
  export let multiline = true
  export let store
  export let name
  export let id = "josh"
  export let userName = "me"
  export let lines = 1

  let showCursor = false

  $: text = $store.fields[name]
  $: position = $store.cursors[id][name]
  $: selection = $store.selections[id] && $store.selections[id].field == name ? $store.selections[id] : null

  function handleFocus() {
    showCursor = true

    if (typeof(position) == "undefined")
      store.setPosition(name, text.length)
  }

  function handleKeydown(e) {
    switch (e.key) {
      case "Backspace":
        store.backspace(name)
        e.preventDefault()
        break;

      case "Enter":
        if (multiline) {
          store.insert(name, "\n")
          e.preventDefault()
        }
        break;

      case 'Delete':
        store.delete(name)
        e.preventDefault()
        break

      case 'ArrowLeft':
        if (e.shiftKey) {
          store.selectLeft(name)
        } else {
          store.moveLeft(name)
        }

        e.preventDefault()
        break;

      case 'ArrowRight':
        if (e.shiftKey) {
          store.selectRight(name)
        } else {
          store.moveRight(name)
        }

        e.preventDefault()
        break;

      case 'Home':
        store.moveToStart(name)
        e.preventDefault()
        break;

      case 'End':
        store.moveToEnd(name)
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

        store.insert(name, e.key)
        e.preventDefault()
        break;
    }
  }

  function inSelection(selection, index) {
    return selection && index >= selection.start && index <= selection.end
  }

  function handleCharClicked(e, index) {
    e.preventDefault()

    store.setPosition(name, index)
    store.setSelection(name, null)
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
