import deques, parseutils, tables, strutils, math

type
  RPNKind = enum
    rpnkNum,
    rpnkOp
  RPNVal = ref object
    case kind: RPNKind
    of rpnkNum: num: float
    of rpnkOp: op: string

proc tokenize(expr : string) : seq[string] =
  var currentTok : string
  for c in expr:
    if c in Whitespace:
      if currentTok.len > 0:
        result = result & currentTok
      currentTok = ""
      continue

    if c == '(' or c == ')':
      if currentTok.len > 0:
        result = result & currentTok
      currentTok = ""

      result = result & $c

    if c in Digits:
      currentTok = currentTok & c

    if c in "+-*/^":
      currentTok = ""
      result = result & $c

  if currentTok.len > 0:
    result = result & currentTok

proc toRPN(expr : string) : seq[RPNVal] =
  let prec = {
    "^" : 0,
    "+" : 2,
    "-" : 2,
    "*" : 1,
    "/" : 1
  }.toTable

  let assoc = {
    "+" : "left",
    "-" : "left",
    "*" : "left",
    "/" : "left",
    "^" : "right"
  }.toTable

  var stack : seq[string]
  var q = initDeque[string]()
  
  var tokens = expr.tokenize

  while tokens.len > 0:
    let tok = tokens[0]

    if tok[0] in Digits:
      q.addLast(tok)

    if not (tok[0] in Digits):
      if tok == ")":
        # Drain the stack onto the queue
        while stack.len > 0:
          let op = stack[0]
          stack = stack[1..^1]
          if op == "(":
            break
          q.addLast(op)
        tokens = tokens[1..^1]
        continue

      if stack.len > 0 and (stack[0] in prec) and (tok in prec):
              # there are ops   the op on the stack has higher prec
              #                 or the op on the stack is left assoc and == prec
        while (stack.len > 0 and 
              ((prec[stack[0]] < prec[tok]) or
              (assoc[stack[0]] == "left" and prec[stack[0]] == prec[tok]))):
          # We want to evaluate higher precedence sub-expressions first
          # This should also check the associativity
          # If we have 3 ^ 2 + 4, it should be 3 2 ^ 4 +, not 3 2 4 + ^
          # If the operator is right-associative, that means we will leave it
          q.addLast(stack[0])
          stack = stack[1..^1]

      stack = @[tok] & stack
    tokens = tokens[1..^1]

  while stack.len > 0:
    q.addLast(stack[0])
    stack = stack[1..^1]

  while q.len > 0:
    var numRes : float
    let tok = q.popFirst
    let num = tok.parseBiggestFloat(numRes)
    if numRes == 0:
      # It's an operator
      result = result & RPNVal(kind: rpnkOp, op: $tok)
    else:
      # It's a number
      result = result & RPNVal(kind: rpnkNum, num: numRes)

proc operate(stack : seq[float], op : RPNVal) : seq[float] =
  let a : float = stack[1]
  let b : float = stack[0]

  var res : float

  if op.op == "+":
    res = a + b
  if op.op == "-":
    res = a - b
  if op.op == "*":
    res = a * b
  if op.op == "/":
    res = a / b
  if op.op == "^":
    res = a.pow(b)

  result = stack[2..^1]
  result = @[res] & result

proc calculate(expr : string) : float =
  let tokens = expr.toRPN
  var stack : seq[float]

  for token in tokens:
    if token.kind == rpnkNum:
      # If it's a number, push it onto the stack
      stack = @[token.num] & stack
    if token.kind == rpnkOp:
      # If it's an operator, pop two elements off
      # Then push the result back on
      stack = stack.operate(token)

  assert(stack.len == 1)
  stack[0]

echo "7 / (2 ^ 3) ^ (4 * 2) + 10".calculate
echo "2 ^ 3 ^ 4".calculate
echo "3 ^ 2 + 4".calculate
for tok in "2 ^ 3 ^ 4".toRPN:
  echo tok.repr
