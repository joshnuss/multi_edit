<script>
  export let text = ""
  export let position = text.length
  export let multiline = true
  export let name = "Josh #1"
  export let lines = 1

  let showCursor = false
  let selection = null

  let selections = [
    {start: 2, end: 2, name: "Josh #2", color: 'pink'},
    {start: 4, end: 5, name: "Josh #3", color: 'orange'}
  ]

  function handleKeydown(e) {
    switch (e.key) {
      case "Backspace":
        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          position = selection.start
          selection = null
        } else if (position > 0) {
          text = text.slice(0, position-1) + text.substring(position)
          position = position-1 > text.length ? text.length : position-1
        }

        break;
      case "Enter":
        if (multiline) {
          text += "\n"
          position = text.length
        }
        break;
      case 'Delete':
        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          position = selection.start
          selection = null
        }  if (position < text.length) {
          text = text.slice(0, position) + text.substring(position+1)
        }
        break
      case 'ArrowLeft':
        if (e.shiftKey) {
          selection = select(-1)
        } else {
          selection = null
        }

        if (position > 0) {
          position--
        }
        break;
      case 'ArrowRight':
        if (e.shiftKey) {
          selection = select(+1)
        } else {
          selection = null
        }

        if (position < text.length) {
          position++
        }
        break;
      case 'Home':
        position = 0
        selection = null
        break;
      case 'End':
        position = text.length
        selection = null
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
        if (selection) {
          text = text.slice(0, selection.start) + text.substring(selection.end)
          position = selection.start
          selection = null
        }

        text = text.slice(0, position) + e.key + text.substring(position)
        position++

        break;
    }
  }

  function select(n) {
    if (n < 0) {
      if (!selection)
        return {start: position-1, end: position}
      else
        return {...selection, start: selection.start + n}
    } else if (n > 0) {
      if (!selection)
        return {start: position, end: position}
      else
        return {...selection, end: selection.end + n}
    }
  }

  function inSelection(selection, index) {
    return selection && index >= selection.start && index <= selection.end
  }

  function handleCharClicked(e, index) {
    e.preventDefault()
    position = index
    selection = null
  }
</script>

<div class="editor" tabindex=0 on:keydown={handleKeydown} on:focus={() => showCursor = true} on:focusout={() => showCursor = false} style="--lines: {lines}">
  {#key [selections, selection]}
    {#each text.split("") as char, index}{#if showCursor && index == position}<span class="cursor" style="--color: turquoise"><span class="name">{name}</span></span>{/if}{#each selections as selection}{#if selection && selection.end == index}<span class="cursor" style="--color: {selection.color}; --index: {index}px"><span class="name">{selection.name}</span></span>{/if}{/each}{#if char == "\n"}<br/>{:else}<span class="char" on:click={e => handleCharClicked(e, index)} class:selected={inSelection(selection, index)}>{char}</span>{/if}{/each}{#if showCursor && text.length == position}<span class="cursor" style="--color: turquoise"><span class="name">{name}</span></span>{/if}
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
    width: 1px;
    background: var(--color);
    height: 1rem;
    margin: 2px 0 0 0;
  }

  .cursor .name {
    display: block;
    position: absolute;
    margin-top: -15px;
    background: var(--color);
    font-size: 10px;
    padding: 2px 4px;
    border-radius: 2px 2px 2px 0;
    box-shadow: 1px 1px #ccc3;
  }
  .selected {
     background: #acf3ec;
  }

  .editor:focus .cursor {
    display: inline-block;
  }
</style>
