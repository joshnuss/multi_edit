<!-- @hmr:keep-all -->
<script>
  import { router, Route } from 'tinro'
  import SignupForm from './SignupForm.svelte'
  import Session from './Session.svelte'

  router.useHashNavigation()

  let user = {}

  function handleLogin(e) {
    user = e.detail
    router.goto("/session")
  }
</script>

<Route path="/">
  <SignupForm on:login={handleLogin}/>
</Route>

<Route path="/session">
  <Session {user}/>
</Route>
