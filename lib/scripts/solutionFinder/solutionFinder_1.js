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

function findAllSolutions(integers, target, depth = 0, history = []) {
  let solutions = []

  if (integers.includes(target)) {
    solutions.push({ depth, history })
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

        let newHistory = [
          ...history,
          { operation: op.operation, set: newIntegers },
        ]
        let result = findAllSolutions(
          newIntegers,
          target,
          depth + 1,
          newHistory
        )

        solutions.push(...result)
      }
    }
  }

  return solutions
}

function main() {
  let integers = randomIntegers()
  console.log('Generated integers:', integers)

  let target = Math.floor(Math.random() * 100)
  console.log('Target integer:', target)

  let solutions = findAllSolutions(integers, target)

  let groupedSolutions = solutions.reduce((acc, curr) => {
    if (!acc[curr.depth]) acc[curr.depth] = []
    acc[curr.depth].push(curr)
    return acc
  }, {})

  console.log('Solutions grouped by number of operations:')
  for (let [operations, solutionList] of Object.entries(groupedSolutions)) {
    console.log(`\nOperations: ${operations}, Count: ${solutionList.length}`)
    for (let i = 0; i < Math.min(solutionList.length, 10); i++) {
      console.log(`Solution ${i + 1}:`)
      solutionList[i].history.forEach((item) => {
        console.log(`Using numbers: ${item.set}`)
        console.log(item.operation)
      })
      console.log('-----')
    }
  }
}

main()
