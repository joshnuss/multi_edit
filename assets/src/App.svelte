<!-- @hmr:keep-all -->
<script>
  import MultiInput from './MultiInput.svelte'

  export let title = "Dank Hoodie"
  export let description = "It's extremely dank"
  export let price = "$75"
</script>

<div>
  <h1>Edit product</h1>
  <label>
    <span>Title</span>
    <MultiInput bind:text={title} multiline={false}/>
  </label>

  <label>
    <span>Description</span>
    <MultiInput bind:text={description} multiline={true} lines=3/>
  </label>

  <label>
    <span>Price</span>
    <MultiInput bind:text={price} multiline={false}/>
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
