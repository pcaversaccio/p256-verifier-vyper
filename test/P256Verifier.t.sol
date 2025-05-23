// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {VyperDeployer} from "vyper-deployer/VyperDeployer.sol";

contract P256Verifier is Test {
    using stdJson for string;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    VyperDeployer private vyperDeployer = new VyperDeployer();
    address private p256Verifier;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Checks a single test vector: signature rs, pubkey Q = (x,y).
     */
    function evaluate(bytes32 hash, uint256 r, uint256 s, uint256 x, uint256 y)
        private
        view
        returns (bool valid, uint256 gasUsed)
    {
        bytes memory input = abi.encodePacked(hash, r, s, x, y);

        uint256 gasBefore = gasleft();
        (bool success, bytes memory res) = p256Verifier.staticcall(input);
        gasUsed = gasBefore - gasleft();

        assertEq(success, true, "call failed");
        assertEq(res.length, 32, "invalid result length");
        uint256 result = abi.decode(res, (uint256));
        assertTrue(result == 1 || result == 0, "invalid result");

        return (result == 1, gasUsed);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            SETUP                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public {
        p256Verifier = vyperDeployer.deployContract("src/", "P256Verifier");
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Sanity check. Demonstrate input and output handling.
     */
    function testBasic() public view {
        // Zero inputs.
        bytes32 hash = bytes32(0);
        (uint256 r, uint256 s, uint256 x, uint256 y) = (0, 0, 0, 0);
        (bool res, uint256 gasUsed) = evaluate(hash, r, s, x, y);
        console.log("Zero inputs, gasUsed ", gasUsed);
        assertEq(res, false);

        // First valid Wycheproof vector.
        hash = 0xbb5a52f42f9c9261ed4361f59422a1e30036e7c32b270c8807a419feca605023;
        r = 19738613187745101558623338726804762177711919211234071563652772152683725073944;
        s = 34753961278895633991577816754222591531863837041401341770838584739693604822390;
        x = 18614955573315897657680976650685450080931919913269223958732452353593824192568;
        y = 90223116347859880166570198725387569567414254547569925327988539833150573990206;
        (res, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("Valid signature, gasUsed ", gasUsed);
        assertEq(res, true);

        // Same as above, but off by 1.
        (res, gasUsed) = evaluate(hash, r, s, x + 1, y);
        console.log("Invalid signature, gasUsed ", gasUsed);
        assertEq(res, false);
    }

    /**
     * @dev This is the most comprehensive test, covering many edge cases. See vector
     * generation and validation in Daimo's test-vectors directory: https://github.com/daimo-eth/p256-verifier/tree/master/test-vectors.
     */
    function testWycheproof() public view {
        string memory file = "./lib/p256-verifier/test-vectors/vectors_wycheproof.jsonl";
        while (true) {
            string memory vector = vm.readLine(file);
            if (bytes(vector).length == 0) {
                break;
            }

            uint256 x = uint256(vector.readBytes32(".x"));
            uint256 y = uint256(vector.readBytes32(".y"));
            uint256 r = uint256(vector.readBytes32(".r"));
            uint256 s = uint256(vector.readBytes32(".s"));
            bytes32 hash = vector.readBytes32(".hash");
            bool expected = vector.readBool(".valid");
            string memory comment = vector.readString(".comment");

            (bool result,) = evaluate(hash, r, s, x, y);

            string memory err = string(
                abi.encodePacked("exp ", expected ? "1" : "0", ", we return ", result ? "1" : "0", ": ", comment)
            );
            assertTrue(result == expected, err);
        }
    }

    function testWrongInputLength() public {
        // First valid Wycheproof vector.
        bytes32 hash = 0xbb5a52f42f9c9261ed4361f59422a1e30036e7c32b270c8807a419feca605023;
        uint256 r = 19738613187745101558623338726804762177711919211234071563652772152683725073944;
        uint256 s = 34753961278895633991577816754222591531863837041401341770838584739693604822390;
        uint256 x = 18614955573315897657680976650685450080931919913269223958732452353593824192568;
        uint256 y = 90223116347859880166570198725387569567414254547569925327988539833150573990206;
        bytes memory input = abi.encodePacked(hash, r, s, x, y);
        (bool success, bytes memory result) = p256Verifier.call(input);
        bytes32 res = abi.decode(result, (bytes32));
        assertTrue(success && res == bytes32(uint256(1)), "expected valid");

        // Append a trailing byte.
        input = abi.encodePacked(input, uint8(0));
        (success, result) = p256Verifier.call(input);
        res = abi.decode(result, (bytes32));
        assertTrue(success && res == bytes32(uint256(0)), "expected invalid");
    }

    function testOutOfBounds() public view {
        // Curve prime field modulus.
        uint256 p = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF;

        bytes32 hash = bytes32(0);
        (uint256 r, uint256 s, uint256 x, uint256 y) = (1, 1, 1, 1);

        // In-bounds dummy key (1, 1).
        // Calls modexp, which takes gas.
        (bool result, uint256 gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
        assertGt(gasUsed, 2500);

        // Out-of-bounds public key. Fails fast, takes less gas.
        (x, y) = (0, 1);
        (result, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
        assertLt(gasUsed, 2500);

        (x, y) = (1, 0);
        (result, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
        assertLt(gasUsed, 2500);

        (x, y) = (1, p);
        (result, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
        assertLt(gasUsed, 2500);

        (x, y) = (p, 1);
        (result, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
        assertLt(gasUsed, 2500);

        // p-1 is in-bounds but point is not on curve.
        (x, y) = (p - 1, 1);
        (result, gasUsed) = evaluate(hash, r, s, x, y);
        console.log("gasUsed ", gasUsed);
        assertEq(result, false);
    }
}
