<!-- @hmr:keep-all -->
<script>
  import { writable } from 'svelte/store'
  import MultiInput from './MultiInput.svelte'

  let id = "josh"
  const store = writable({
    userId: "josh",
    fields: {
      title: "Dank Hoodie",
      description: "It's extremely dank",
      price: "$75"
    },
    cursors: {
      josh: { title: 0 },
      susan: { title: 4 },
      tom: { description: 5 }
    },
    users: {
      josh: {name: "Josh", textColor: "black", primaryColor: "turquoise"},
      susan: {name: "Susan", textColor: "black", primaryColor: "plum"},
      tom: {name: "Tom", textColor: "white", primaryColor: "red"}
    },
    selections: {}
  })

  export let title = $store.fields.title
  export let description = $store.fields.description
  export let price = $store.fields.price

  $: { $store.fields.title = title }
  $: { $store.fields.description = description }
  $: { $store.fields.price = price }
</script>

<pre>{JSON.stringify($store, null, 2)}</pre>
<div>
  <h1>Edit product</h1>
  <label>
    <span>Title</span>
    <MultiInput name="title" bind:text={title} multiline={false} {id} {store}/>
  </label>

  <label>
    <span>Description</span>
    <MultiInput name="description" bind:text={description} multiline={true} lines=3 {id} {store}/>
  </label>

  <label>
    <span>Price</span>
    <MultiInput name="price" bind:text={price} multiline={false} {id} {store}/>
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
