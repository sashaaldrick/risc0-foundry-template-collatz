// Copyright 2024 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.20;

import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ImageID} from "./ImageID.sol"; // auto-generated contract after running `cargo build`.

/// @title A starter application using RISC Zero.
/// @notice This basic application holds a number, guaranteed to satisfy the Collatz conjecture.
/// @notice The number can be set by calling the `set` function.
/// @notice If the new proven number is larger than the currently stored one, the contract will update the number.
/// @dev This contract demonstrates one pattern for offloading the computation of an expensive
///      or difficult to implement function to a RISC Zero guest running on Bonsai.
contract CollatzNumber {
    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;
    /// @notice Image ID of the only zkVM binary to accept verification from.
    bytes32 public constant imageId = ImageID.COLLATZ_ID;

    /// @notice A number that is guaranteed, by the RISC Zero zkVM, to be satisfy the Collatz conjecture.
    ///         It can be set by calling the `set` function.
    uint256 public number;

    /// @notice Initialize the contract, binding it to a specified RISC Zero verifier.
    constructor(IRiscZeroVerifier _verifier) {
        verifier = _verifier;
        number = 0;
    }

    /// @notice Store a new number which is larger than the current stored number.
    /// @notice Requires a RISC Zero proof that the new number satisfies the Collatz conjecture.
    function set(uint256 x, bytes32 postStateDigest, bytes calldata seal) public {
        require(x > 0, "Zero not allowed.");
        require(x > number, "Input number lower than currently stored number.");

        // Construct the expected journal data. Verify will fail if journal does not match.
        bytes memory journal = abi.encode(x);
        require(verifier.verify(seal, imageId, postStateDigest, sha256(journal)));
        number = x;
    }

    /// @notice Returns the number stored.
    function get() public view returns (uint256) {
        return number;
    }
}
