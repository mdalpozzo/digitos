// Function to apply the specified operation on two integers
function applyOperation(a, b, operation) {
    if (operation === "+") {
        return a + b;
    } else if (operation === "-") {
        return a - b;
    } else if (operation === "*") {
        return a * b;
    } else if (operation === "/") {
        return b !== 0 ? a / b : null;
    }
}

// Function to generate a set of integers and operations
function generateIntegerSet(target) {
    const maxAttempts = 10000;
    let attempts = 0;

    while (attempts < maxAttempts) {
        // Generate an array of 6 unique integers
        const integers = Array.from({ length: 6 }, (_, i) => i + 1);
        integers.sort(() => Math.random() - 0.5); // Shuffle the array
        const operations = ["+", "-", "*", "/"];
        
        // Generate all possible combinations of 2 integers from the array
        const intCombinations = [];
        for (let i = 0; i < integers.length; i++) {
            for (let j = i + 1; j < integers.length; j++) {
                intCombinations.push([integers[i], integers[j]]);
            }
        }

        // Iterate through the combinations and operations to find a valid solution
        for (const comb of intCombinations) {
            for (const op1 of operations) {
                for (const op2 of operations) {
                    // Apply the first operation on the two integers
                    const newInteger = applyOperation(comb[0], comb[1], op1);
                    if (newInteger !== null && !integers.includes(newInteger)) {
                        const newIntegers = [...integers];
                        newIntegers.splice(newIntegers.indexOf(comb[0]), 1);
                        newIntegers.splice(newIntegers.indexOf(comb[1]), 1);
                        newIntegers.push(newInteger);

                        // Apply the second operation on the new integer and another integer
                        const newInteger2 = applyOperation(newInteger, comb[2], op2);
                        if (newInteger2 !== null && !newIntegers.includes(newInteger2)) {
                            newIntegers.push(comb[2]);
                            newIntegers.push(newInteger2);

                            // Check if applying the third operation reaches the target
                            if (applyOperation(newInteger2, comb[3], op2) === target) {
                                return { integerSet: newIntegers, operations: [op1, op2, op2] };
                            }
                        }
                    }
                }
            }
        }

        attempts++;
    }

    return { integerSet: null, operations: null };
}

// Define the target integer
const targetInteger = 42;

// Generate the integer set and operations
const { integerSet, operations } = generateIntegerSet(targetInteger);

// Display the results
if (integerSet !== null) {
    console.log("Generated Integer Set:", integerSet);
    console.log("Operations:", operations);
} else {
    console.log("Could not generate a valid integer set.");
}
