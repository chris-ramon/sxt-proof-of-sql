// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "../../src/base/Constants.sol";
import {VerificationBuilder} from "../../src/builder/VerificationBuilder.pre.sol";
import {TableExec} from "../../src/proof_plans/TableExec.pre.sol";

contract TableExecTest is Test {
    function testSimpleTableExec() public pure {
        // Create a simple table execution plan with table_ref = 0 and 3 column fields
        bytes memory plan = abi.encodePacked(
            uint64(0), // table_ref
            uint64(3), // column_count
            uint64(0), // column1_index
            uint64(1), // column2_index
            uint64(2), // column3_index
            hex"abcdef"
        );

        // Prepare the builder with test values
        VerificationBuilder.Builder memory builder;
        builder.tableChiEvaluations = new uint256[](1);
        builder.tableChiEvaluations[0] = 801; // chi evaluation for table_ref = 0
        builder.columnEvaluations = new uint256[](3);
        builder.columnEvaluations[0] = 101; // column1 evaluation
        builder.columnEvaluations[1] = 102; // column2 evaluation
        builder.columnEvaluations[2] = 103; // column3 evaluation

        // Execute table_exec_evaluate
        uint256[] memory evals;
        uint256 length;
        uint256 chiEval;
        (plan, builder, evals, length, chiEval) = TableExec.__tableExecEvaluate(plan, builder);

        // Verify the expected results
        assert(evals.length == 3);
        assert(evals[0] == 101);
        assert(evals[1] == 102);
        assert(evals[2] == 103);

        // Verify remaining plan data
        bytes memory expectedPlanOut = hex"abcdef";
        assert(plan.length == expectedPlanOut.length);
        uint256 planOutLength = plan.length;
        for (uint256 i = 0; i < planOutLength; ++i) {
            assert(plan[i] == expectedPlanOut[i]);
        }
    }

    function testFuzzTableExec(
        VerificationBuilder.Builder memory builder,
        uint64 tableRef,
        uint8[10] memory columnIndices,
        bytes memory trailingExpr
    ) public pure {
        // Create the plan with table_ref and column indices
        bytes memory plan = abi.encodePacked(tableRef, uint64(columnIndices.length));
        uint256 columnIndicesLength = columnIndices.length;
        for (uint256 i = 0; i < columnIndicesLength; ++i) {
            plan = abi.encodePacked(plan, uint64(columnIndices[i]));
        }
        plan = abi.encodePacked(plan, trailingExpr);
        uint256 maxColumnIndex = 0;
        for (uint256 i = 0; i < columnIndicesLength; ++i) {
            if (columnIndices[i] > maxColumnIndex) {
                maxColumnIndex = columnIndices[i];
            }
        }
        // Setup builder with required test values
        vm.assume(builder.tableChiEvaluations.length > tableRef);
        vm.assume(builder.columnEvaluations.length > maxColumnIndex);
        vm.assume(maxColumnIndex > 0);

        // Execute the function under test
        uint256[] memory evals;
        uint256 length;
        uint256 chiEval;
        (plan, builder, evals, length, chiEval) = TableExec.__tableExecEvaluate(plan, builder);

        // Verify results
        assert(evals.length == columnIndicesLength);
        for (uint256 i = 0; i < columnIndicesLength; ++i) {
            assert(evals[i] == builder.columnEvaluations[columnIndices[i]]);
        }

        // Verify remaining plan data
        assert(plan.length == trailingExpr.length);
        uint256 planOutLength = plan.length;
        for (uint256 i = 0; i < planOutLength; ++i) {
            assert(plan[i] == trailingExpr[i]);
        }
    }
}
