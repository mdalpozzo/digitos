// Generates a set of random integers
function randomIntegers(n = 6) {
  let arr = []
  for (let i = 0; i < n; i++) {
    // Each number is between 0 and 99 (inclusive)
    arr.push(Math.floor(Math.random() * 100))
  }
  return arr
}

// Determines the valid arithmetic operations between two integers
function validOperations(a, b) {
  let results = []
  results.push({ value: a + b, operation: `${a} + ${b}` })
  results.push({ value: a * b, operation: `${a} * ${b}` })
  // Check which number is larger for subtraction
  if (a - b > 0) results.push({ value: a - b, operation: `${a} - ${b}` })
  else results.push({ value: b - a, operation: `${b} - ${a}` })
  // Ensure divisions result in integers
  if (b !== 0 && a % b === 0)
    results.push({ value: a / b, operation: `${a} / ${b}` })
  else if (a !== 0 && b % a === 0)
    results.push({ value: b / a, operation: `${b} / ${a}` })
  return results
}

// Recursive function to find all solutions to reach the target
function findAllSolutions(integers, target, depth = 0) {
  let solutions = []

  // If the current set of integers contains the target, a solution is found
  if (integers.includes(target)) {
    solutions.push(depth)
  }

  // Try combinations of integers in the current set
  for (let i = 0; i < integers.length; i++) {
    for (let j = i + 1; j < integers.length; j++) {
      let a = integers[i]
      let b = integers[j]

      // Check all valid operations between the chosen integers
      let operations = validOperations(a, b)
      for (let op of operations) {
        if (op.value > 99) continue // Skip numbers that exceed 2 digits

        // Create a new set of integers for the next recursive step
        let newIntegers = [...integers]
        newIntegers.splice(i, 1)
        newIntegers.splice(j - 1, 1)
        newIntegers.push(op.value)

        // Recursive call
        let result = findAllSolutions(newIntegers, target, depth + 1)
        solutions.push(...result)
      }
    }
  }

  return solutions
}

function main() {
  let integers = [38, 4, 5, 35, 9, 91]
  console.log('Starting integers:', integers)

  // Randomly select a target integer
  let target = 86
  console.log('Target integer:', target)

  // Get all possible solutions
  let solutions = findAllSolutions(integers, target)

  // Group solutions by the number of operations
  let groupedSolutions = solutions.reduce((acc, curr) => {
    if (!acc[curr]) acc[curr] = 0
    acc[curr]++
    return acc
  }, {})

  // Display the grouped solutions
  console.log('Solutions grouped by number of operations:')
  for (let [operations, count] of Object.entries(groupedSolutions)) {
    console.log(`Operations: ${operations}, Count: ${count}`)
  }
}

main()
