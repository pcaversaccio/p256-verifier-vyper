// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {VyperDeployer} from "vyper-deployer/VyperDeployer.sol";

contract P256Verifier is Test {
    using stdJson for string;

    VyperDeployer private vyperDeployer = new VyperDeployer();
    address private p256Verifier;

    function setUp() public {
        console2.log(address(vyperDeployer));
        // p256Verifier = vyperDeployer.deployContract("src/", "P256Verifier");
    }

    function testHello() public {
        assertEq(uint256(1), uint256(1));
    }
}
