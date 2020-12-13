<!-- @hmr:keep-all -->
<script>
  import createInputStore from './inputStore'
  import MultiInput from './MultiInput.svelte'

  export let user

  const store = createInputStore(user)

  $: id = $store.userId
</script>

<pre>{JSON.stringify($store, null, 2)}</pre>
<div>
  <h1>Edit product</h1>
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

<style>
  :global(body) {
    font-family: sans;
    display: flex;
    justify-content: center;
    padding: 0;
    place-items: center;
    background: white;
  }
  pre, div {
    flex: 1
  }
  pre {
    background: #ddd;
    padding: 2rem;
  }
  div {
    margin: auto 10vw;
    display: flex;
    flex-direction: column;
    width: 100%;
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
</style>

