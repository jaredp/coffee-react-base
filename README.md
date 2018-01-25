# Coffeescript + JSX in the browser, server, CLI, and Repl

This is a crummy starter CRA-like base for Jared's projects.  It's based on a super old version of Create-React-App (1.5.1).  I'm not sure what's the delta on CRA since then, but it's probably worth having.  I couldn't get the current CRA to play with Coffeescript and/or node.js, and this was already working for me, having accumulated it over time for Pagedraw.

You probably shouldn't use this; it's just what Jared likes for himself.


### Features
- browser support via webpack (`yarn start`, `yarn build`), based on CRA
- node.js CLIs and server support, sharing  CJSX code with the browser. Invoke with `yarn coffee my/cli.cjsx`, where `my/cli.cjsx` starts with
```
require 'coffee-react/register'
```
- Coffeescript REPL importing CJSX code.  Just
```
yarn coffee
coffee> require 'coffee-react/register'
```
- `await` in the REPL
- lodash installed by default
- Coffeescript
- React
- async/await
- JSX ([https://jsdf.github.io/coffee-react-transform/]())


### Choices

- `coffee-react` instead of `coffee -t`

This seems faster and like it's a better experience.  I could never get `.babelrc` right, and babel seemed slower than `coffee-react` last time I tried.

- tests are not supported

I've haven't touched jest since ejecting from CRA.  It should be possible to extend coffee-react support to jest, I just haven't done it.

- avoid `require()`ing CSS and other non-JS file types

When you want to want to import a JS file from node.js (for REPL or CLI purposes), if that JS file recursively requires a CSS file, node.js will barf.  For safety, don't `require()` files that aren't CJSX/JS.

- use `require()` instead of `import`

This was key to getting node.js to accept the same files as webpack.  This is why I'm based off such an old version of CRA: I think the latest ones use a version of Webpack that treats `require()` like `import` (using ESM semantics), which differ from what node.js is doing.  I think.

- this should be a `react-scripts` implementation

Create-React-App has a really, really good path for extension that I'm not taking here.  I absolutely should be; I'm just lazy.

- `.cjsx` instead of `.coffee`

The `cjsx` command from `coffee-react` expects `.cjsx` files and I didn't fight it.  As long as they're all `.cjsx`, I don't see why it's any worse than naming them all `.coffee`.  If you switch to `coffee -t` instead of `coffee-react`, you'll want to rename all your files, but that should be doable with one (complicated) bash command.

- `await` can't be used in the toplevel of a node.js script

I think node.js doesn't support this, somehow.  Wrap your main in  a `do` block, like
```
require 'coffee-react/register'

require './more/requires'

do ->
  # main work
  scrape = async wait fetch('http://google.com')
  # more work
  await wait 1000
  # you get the idea
```
