/** @type {import("snowpack").SnowpackUserConfig } */
module.exports = {
  mount: {
    public: '/',
    src: '/_dist_',
  },
  plugins: [
    '@snowpack/plugin-svelte',
    '@snowpack/plugin-dotenv',
  ],
  install: [
    /* ... */
  ],
  installOptions: {
    /* ... */
  },
  devOptions: {
    port: 4001,
    open: 'none',
    output: 'stream'
  },
  buildOptions: {
    out: '../priv/static'
  },
  proxy: {
    /* ... */
  },
  alias: {
    /* ... */
  },
};
