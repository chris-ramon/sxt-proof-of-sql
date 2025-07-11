// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

import "../base/Constants.sol";
import "../base/Errors.sol";
import {VerificationBuilder} from "../builder/VerificationBuilder.pre.sol";

/// @title PlaceholderExpr
/// @dev Library for handling placeholder expressions
library PlaceholderExpr {
    /// @notice Evaluates a placeholder expression
    /// @custom:as-yul-wrapper
    /// #### Wrapped Yul Function
    /// ##### Signature
    /// ```yul
    /// placeholder_expr_evaluate(expr_ptr, builder_ptr, chi_eval) -> expr_ptr_out, eval
    /// ```
    /// ##### Parameters
    /// * `expr_ptr` - the calldata pointer to the beginning of the expression data
    /// * `builder_ptr` - memory pointer to the verification builder
    /// * `chi_eval` - the chi value for evaluation
    /// ##### Return Values
    /// * `expr_ptr_out` - pointer to the remaining expression after consuming the placeholder expression
    /// * `eval` - the evaluation of the placeholder parameter multiplied by chi_eval
    /// ##### Proof Plan Encoding
    /// The placeholder expression is encoded as follows:
    /// 1. The placeholder index (as a uint64)
    /// 2. The placeholder column type (using standard data type encoding)
    /// @dev Retrieves the placeholder parameter value from the builder and multiplies by chi_eval
    /// @param __expr The input placeholder expression
    /// @param __builder The verification builder containing placeholder parameters
    /// @param __chiEval The chi value for evaluation
    /// @return __exprOut The remaining expression after consuming the placeholder expression
    /// @return __builderOut The verification builder result
    /// @return __eval The evaluation result
    function __placeholderExprEvaluate( // solhint-disable-line gas-calldata-parameters
    bytes calldata __expr, VerificationBuilder.Builder memory __builder, uint256 __chiEval)
        external
        pure
        returns (bytes calldata __exprOut, VerificationBuilder.Builder memory __builderOut, uint256 __eval)
    {
        assembly {
            // IMPORT-YUL ../base/Errors.sol
            function err(code) {
                revert(0, 0)
            }
            // IMPORT-YUL ../base/Array.pre.sol
            function get_array_element(arr_ptr, index) -> value {
                revert(0, 0)
            }
            // IMPORT-YUL ../base/SwitchUtil.pre.sol
            function case_const(lhs, rhs) {
                revert(0, 0)
            }
            // IMPORT-YUL ../base/DataType.pre.sol
            function read_data_type(ptr) -> ptr_out, data_type {
                revert(0, 0)
            }
            // IMPORT-YUL ../base/MathUtil.pre.sol
            function mulmod_bn254(lhs, rhs) -> product {
                revert(0, 0)
            }
            // IMPORT-YUL ../builder/VerificationBuilder.pre.sol
            function builder_get_placeholder_parameter(builder_ptr, index) -> value {
                revert(0, 0)
            }

            function placeholder_expr_evaluate(expr_ptr, builder_ptr, chi_eval) -> expr_ptr_out, eval {
                let placeholder_index := shr(UINT64_PADDING_BITS, calldataload(expr_ptr))
                expr_ptr := add(expr_ptr, UINT64_SIZE)

                // Read column type using read_data_type
                let column_type
                expr_ptr, column_type := read_data_type(expr_ptr)

                // Get the placeholder parameter value from the builder
                let parameter_value := builder_get_placeholder_parameter(builder_ptr, placeholder_index)

                // Multiply by chi_eval (similar to how literals work)
                eval := mulmod_bn254(parameter_value, chi_eval)

                expr_ptr_out := expr_ptr
            }

            let __exprOutOffset
            __exprOutOffset, __eval := placeholder_expr_evaluate(__expr.offset, __builder, __chiEval)
            __exprOut.offset := __exprOutOffset
            // slither-disable-next-line write-after-write
            __exprOut.length := sub(__expr.length, sub(__exprOutOffset, __expr.offset))
        }
        __builderOut = __builder;
    }
}
