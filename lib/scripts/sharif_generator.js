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

function generateIntegerSet(target, currentSet, currentOps) {
    if (currentSet.length === 6) {
        if (applyOperation(currentSet[4], currentSet[5], currentOps[2]) === target) {
            return { integerSet: currentSet, operations: currentOps };
        }
        return null;
    }

    const operations = ["+", "-", "*", "/"];
    for (const op of operations) {
        const newSet = [...currentSet];
        const newOps = [...currentOps];
        
        newOps.push(op);

        for (let i = 0; i < currentSet.length; i++) {
            for (let j = i + 1; j < currentSet.length; j++) {
                if (currentSet[i] === 0 && op === "/") {
                    continue; // Avoid division by zero
                }
                
                const result = applyOperation(currentSet[i], currentSet[j], op);
                if (result !== null && !currentSet.includes(result) && !newSet.includes(result)) {
                    newSet.push(result);

                    const solution = generateIntegerSet(target, newSet, newOps);
                    if (solution !== null) {
                        return solution;
                    }

                    newSet.pop();
                }
            }
        }
    }

    return null;
}

// Define the target integer
const targetInteger = 50;

const solution = generateIntegerSet(targetInteger, initialSet, initialOps);

if (solution !== null) {
    console.log("Generated Integer Set:", solution.integerSet);
    console.log("Operations:", solution.operations);
} else {
    console.log("Could not generate a valid integer set.");
}
