pub type Var {
  Var(name: String, id: Int)
}

pub type Term {
  V(Var)
  T(String, List(Term))
}

pub type Subst =
  List(#(Var, Term))

fn any(l, f) {
  case l {
    [] -> False
    [el, ..rest] -> f(el) || any(rest, f)
  }
}

fn map(l, f) {
  case l {
    [] -> []
    [el, ..rest] -> [f(el), ..map(rest, f)]
  }
}

fn apply(v, subst) {
  case subst {
    [] -> V(v)
    [#(x, t), ..] if x == v -> t
    [_, ..rest] -> apply(v, rest)
  }
}

fn lift(t, subst) {
  case t {
    V(v) -> apply(v, subst)
    T(f, ts) -> T(f, map(ts, lift(_, subst)))
  }
}

fn occurs(v, t) {
  case t {
    V(v2) -> v == v2
    T(_f, ts) -> any(ts, occurs(v, _))
  }
}

fn zip(l1, l2) {
  case l1, l2 {
    [], [] -> Ok([])
    [el1, ..rest1], [el2, ..rest2] ->
      case zip(rest1, rest2) {
        Error(Nil) -> Error(Nil)
        Ok(z) -> Ok([#(el1, el2), ..z])
      }
    _, _ -> Error(Nil)
  }
}

fn append(l1, l2) {
  case l1 {
    [] -> l2
    [el, ..rest] -> [el, ..append(rest, l2)]
  }
}

pub fn solve(eqns: List(#(Term, Term)), so_far: Subst) -> Result(Subst, String) {
  case eqns {
    [] -> Ok(so_far)
    [#(V(v1), V(v2)), ..rest] if v1 == v2 -> solve(rest, so_far)
    [#(V(v), t), ..rest] | [#(t, V(v)), ..rest] -> elim(v, t, rest, so_far)
    [#(T(f, ts), T(g, us)), ..rest] if f == g ->
      case zip(ts, us) {
        Error(Nil) -> Error("arity mismatch")
        Ok(z) -> solve(append(z, rest), so_far)
      }
    [#(T(f, _), T(g, _)), ..] ->
      Error("incompatible operators " <> f <> " and " <> g)
  }
}

pub fn elim(v, t, eqns, so_far: Subst) -> Result(Subst, String) {
  case occurs(v, t) {
    True -> Error("occurs check")
    False -> {
      let vt = lift(_, [#(v, t)])
      solve(map(eqns, fn(eqn: #(Term, Term)) { #(vt(eqn.0), vt(eqn.1)) }), [
        #(v, t),
        ..map(so_far, fn(subst) { #(subst.0, vt(subst.1)) })
      ])
    }
  }
}

pub fn var(name, id) -> Term {
  V(Var(name, id))
}

pub fn term(name, args) -> Term {
  T(name, args)
}

pub fn constant(name) -> Term {
  T(name, [])
}