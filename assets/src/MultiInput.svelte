<script>
  export let multiline = true
  export let store
  export let name
  export let id = "josh"
  export let userName = "me"
  export let lines = 1

  let showCursor = false
  let chars = []
  let charMap = {}
  let endCursors = []

  $: text = $store.fields[name] || ""
  $: position = $store.cursors[id] ? $store.cursors[id][name] : undefined

  $: cursorMap = Object.entries($store.cursors).map(([id, cursors]) => ([id, cursors[name]])).filter(([id, cursor]) => cursor != null)
  $: {
    charMap = {}
    endCursors = []
    chars = text.split('').map(value => ({cursors: [], selections: [], value}))
    chars.forEach((char, index) => charMap[index] = char)
    cursorMap.forEach(([userId, cursor]) => {

      if (typeof(charMap[cursor]) == "undefined") {
        endCursors = [...endCursors, userId]
      }
      else {
        const cursors = charMap[cursor].cursors
        charMap[cursor].cursors = [...cursors, userId]
      }
    })

    Object.entries($store.selections).forEach(([userId, selection]) => {
      if (!(selection && selection.field == name)) return

      for (let i=selection.start; i<=selection.end; i++) {
        if (typeof charMap[i] == "undefined") continue

        const selections = charMap[i].selections
        charMap[i].selections = [...selections, userId]
      }
    })
  }

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

      case "Pause":
      case "ScrollLock":
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

  function handleCharClicked(e, index) {
    e.preventDefault()

    store.setPosition(name, index)
    store.setSelection(name, null)
  }
</script>

<div class="editor" tabindex=0 on:keydown={handleKeydown} on:focus={handleFocus} on:focusout={() => showCursor = false} style="--lines: {lines}">
  {#key [...Object.values($store.cursors), ...Object.values($store.selections)]}
  {#each chars as char, index}
    {#if showCursor && index == position}
      <span class="cursor local" style="--background-color: {$store.users[$store.userId].primaryColor}; text-color: {$store.users[$store.userId].primaryColor};">
        <span class="name">{userName}</span>
      </span>
    {/if}
    {#each char.cursors as userId}
      {#if userId !== $store.userId}
        <span class="cursor" style="--background-color: {$store.users[userId].primaryColor}; --text-color: {$store.users[userId].textColor}; --index: {index}px">
          <span class="name">{$store.users[userId].name}</span>
        </span>
      {/if}
    {/each}

    {#if char.value == "\n"}
      <br/>
    {:else}
      <span class="char" on:click={e => handleCharClicked(e, index)}>
        <span class:selected={char.selections.length > 0} style="--background-color: {$store.users[char.selections.includes($store.userId) || char.selections.length == 0 ? $store.userId : char.selections[char.selections.length-1]].primaryColor}">
          {#if char.value == " "}&nbsp;{:else}{char.value}{/if}
        </span>
      </span>
    {/if}

  {/each}

  {#each endCursors as userId}
    <span class="cursor" class:local={userId == $store.userId} style="--background-color: {$store.users[userId].primaryColor}; --text-color: {$store.users[userId].textColor};">
      <span class="name">{userId == $store.userId ? userName : $store.users[userId].name}</span>
    </span>
  {/each}

  {/key}
</div>

<style>
  .editor {
    border: solid 1px #bbb;
    min-height: calc((1rem + 2px) * var(--lines));
    border-radius: 1px;
    padding: 5px 6px;
    font-size: 0;
  }

  .editor span {
    font-size: 1rem;
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
