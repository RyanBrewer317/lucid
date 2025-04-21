# lucid

[![Package Version](https://img.shields.io/hexpm/v/lucid)](https://hex.pm/packages/lucid)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lucid/)

A little logic programming library for gleam! Currently only supports unification of algebraic terms; more to come!

```sh
gleam add lucid@1
```
```gleam
import gleeunit
import gleeunit/should
import lucid/logic.{var, Var, term, constant}

...

pub fn unify_test() {
  logic.solve(
    [
      // f(x, z) == f(x, y)
      #(
        term("f", [var("x", 0), var("z", 2)]),
        term("f", [var("x", 0), var("y", 1)]),
      ),
      // z == x
      #(var("z", 2), var("x", 0)),
      // y == c
      #(var("y", 1), constant("c")),
    ],
    [],
  )
  |> should.equal(
    Ok([
      #(Var("x", 0), constant("c")),
      #(Var("y", 1), constant("c")),
      #(Var("z", 2), constant("c")),
    ]),
  )
}

```

Further documentation can be found at <https://hexdocs.pm/lucid>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
