function randomIntegers(n = 6) {
  let arr = []
  for (let i = 0; i < n; i++) {
    arr.push(Math.floor(Math.random() * 100))
  }
  return arr
}

function validOperations(a, b) {
  let results = []
  results.push({ value: a + b, operation: `${a} + ${b}` })
  results.push({ value: a * b, operation: `${a} * ${b}` })
  if (a - b > 0) results.push({ value: a - b, operation: `${a} - ${b}` })
  else results.push({ value: b - a, operation: `${b} - ${a}` })
  if (b !== 0 && a % b === 0)
    results.push({ value: a / b, operation: `${a} / ${b}` })
  else if (a !== 0 && b % a === 0)
    results.push({ value: b / a, operation: `${b} / ${a}` })
  return results
}

function calculateTarget(
  integers,
  target,
  depth = 0,
  maxDepth = 5,
  history = []
) {
  if (integers.includes(target)) {
    return { success: true, operations: history }
  }

  if (depth === maxDepth) {
    return { success: false, operations: [] }
  }

  for (let i = 0; i < integers.length; i++) {
    for (let j = i + 1; j < integers.length; j++) {
      let a = integers[i]
      let b = integers[j]

      let operations = validOperations(a, b)
      for (let op of operations) {
        if (op.value > 99) continue

        let newIntegers = [...integers]
        newIntegers.splice(i, 1)
        newIntegers.splice(j - 1, 1)
        newIntegers.push(op.value)

        let result = calculateTarget(newIntegers, target, depth + 1, maxDepth, [
          ...history,
          { set: newIntegers, operation: op.operation },
        ])

        if (result.success) {
          return result
        }
      }
    }
  }

  return { success: false, operations: [] }
}

function main() {
  let integers = randomIntegers()
  console.log('Generated integers:', integers)

  let target = Math.floor(Math.random() * 100)
  let result = calculateTarget(integers, target)

  if (!result.success) {
    console.log(`Couldn't find a solution for target: ${target}`)
  } else {
    console.log(`Operations to get to target ${target}:`)
    for (let step of result.operations) {
      console.log(step.operation)
      console.log(`Using numbers: ${step.set}`)
    }
  }
}

main()
