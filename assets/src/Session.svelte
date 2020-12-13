<!-- @hmr:keep-all -->
<script>
  import { router } from 'tinro'
  import createInputStore from './inputStore'
  import MultiInput from './MultiInput.svelte'

  export let user

  let store, debug = false

  if (!user.name) {
    router.goto('/')
  } else {
    store = createInputStore(user)
  }

  $: id = $store?.userId
</script>

{#if user.name}
  {#if debug}
    <pre>{JSON.stringify($store, null, 2)}</pre>
  {/if}
  <div class="container">
    <div class="title">
      <h1>Edit product</h1>
      <button on:click={()=> debug = !debug}>
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16l2.879-2.879m0 0a3 3 0 104.243-4.242 3 3 0 00-4.243 4.242zM21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </button>
    </div>

    <label>
      <span>Title</span>
      <MultiInput name="title" multiline={false} {id} {store}/>
    </label>

    <label>
      <span>Description</span>
      <MultiInput name="description" multiline={true} lines=3 {id} {store}/>
    </label>

    <label>
      <span>Price</span>
      <MultiInput name="price" multiline={false} {id} {store}/>
    </label>
  </div>
{/if}

<style>
  :global(body) {
    font-family: sans;
    display: flex;
    justify-content: center;
    padding: 0;
    place-items: center;
  }
  pre, .container {
    flex: 1
  }
  pre {
    background: #ddd;
    padding: 2rem;
    margin: 2rem;
  }
  .container {
    display: flex;
    flex-direction: column;
    min-width: 50vw;
    max-width: 600px;
    margin: 1rem;
    align-self: flex-start;
  }

  label {
    margin-top: 20px;
  }

  label span {
    display: block;
    font-size: 0.8rem;
    font-weight: bold;
    margin-bottom: 5px;
  }

  .title {
    display: flex;
    place-items: center;
  }

  button {
    border: none;
    background: none;
    color: #666;
    cursor: pointer;
  }

  button:focus {
    outline: none;
  }

  button svg {
    height: 20px;
  }
</style>

