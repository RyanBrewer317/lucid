import gleeunit
import gleeunit/should
import lucid/logic.{var, Var, term, constant}

pub fn main() {
  gleeunit.main()
}

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
