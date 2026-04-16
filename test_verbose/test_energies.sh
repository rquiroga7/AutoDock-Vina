#!/bin/bash

# Test script to compare vina and vinav energies
# Both should return identical energies for the same input

VINA="../build/linux/release/vina"
VINAV="../build/linux/release/vinav"
RECEPTOR="receptor.pdbqt"
LIGANDS=("ligand1.pdbqt")

echo "========================================"
echo "Comparing vina vs vinav energies"
echo "========================================"
echo ""

PASS=0
FAIL=0

for ligand in "${LIGANDS[@]}"; do
    echo "Testing ${ligand}..."
    
    # Run vina
    VINA_OUT=$($VINA --receptor $RECEPTOR --ligand ${ligand} --score_only --autobox 2>&1)
    VINA_ENERGY=$(echo "$VINA_OUT" | grep "Estimated Free Energy" | awk '{print $7}')
    
    # Run vinav
    VINAV_OUT=$($VINAV --receptor $RECEPTOR --ligand ${ligand} --score_only --autobox 2>&1)
    VINAV_ENERGY=$(echo "$VINAV_OUT" | grep "Estimated Free Energy" | awk '{print $7}')
    
    # Compare
    if [ "$VINA_ENERGY" == "$VINAV_ENERGY" ]; then
        echo "  PASS: vina=$VINA_ENERGY, vinav=$VINAV_ENERGY"
        ((PASS++))
    else
        echo "  FAIL: vina=$VINA_ENERGY, vinav=$VINAV_ENERGY"
        ((FAIL++))
    fi
done

echo ""
echo "========================================"
echo "Results: $PASS passed, $FAIL failed"
echo "========================================"

if [ $FAIL -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed!"
    exit 1
fi
