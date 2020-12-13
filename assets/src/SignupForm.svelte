<script>
  import { createEventDispatcher } from 'svelte'

  const colors = [
    { primary: "turquoise", text: "#444" },
    { primary: "plum", text: "#444" },
    { primary: "red", text: "pink" },
    { primary: "aqua", text: "#444" },
    { primary: "mediumslateblue", text: "#ddd" },
    { primary: "#ccc", text: "#444" },
  ]

  let name = ""
  let color = colors[0]
  const dispatch = createEventDispatcher()

  function handleSubmit() {
    dispatch('login', {name, color})
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h1>Login</h1>

  <label>
    <span>Name</span>
    <input autofocus name="name" bind:value={name} autocomplete="off"/>
  </label>

  <label>
    <ul>
      {#each colors as c}
        <li tabindex=0 class:selected={c==color} style="--background-color: {c.primary}; --text-color: {c.text}" on:click={() => color = c}></li>
      {/each}
    </ul>
  </label>

  <button disabled={!name}>Go &gt;</button>
</form>

<style>
  form {
    background: #eee;
    border-radius: 0.3rem;
    margin-top: 40px;
    border: solid 3px #ccc;
    padding: 2rem 5rem 4rem;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }
  ul {
    margin: 0;
    padding: 0;
    display: flex;
  }
  li {
    background: var(--background-color);
    color: var(--text-color);
    padding: 1rem;
    cursor: pointer;
    list-style: none;
    border: solid 3px transparent;
    opacity: 0.3;
  }

  li:hover {
    opacity: 1;
  }

  li.selected {
    opacity: 1;
    border: solid 3px var(--text-color);
  }

  label span {
    display: block;
    font-size: 0.9rem;
    margin-bottom: 4px;
    font-weight: 500;
  }

  input {
    font-size: 1.5rem;
    padding: 5px 4px;
  }

  button {
    margin-top: 60px;
    font-size: 1.5rem;
    padding: 5px 4px;
  }
</style>
