<!-- @hmr:keep-all -->
<script>
  import { router, Route } from 'tinro'
  import LoginForm from './LoginForm.svelte'
  import Session from './Session.svelte'

  router.useHashNavigation()

  let user = {}

  function handleLogin(e) {
    user = e.detail
    router.goto("/session")
  }
</script>

<Route path="/">
  <LoginForm on:login={handleLogin}/>
</Route>

<Route path="/session">
  <Session {user}/>
</Route>
