// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "ds-test/test.sol";
import "../BondingCurve.sol";
import "../PairFactory.sol";
import "../Exchange.sol";
import "../Cryptomedia.sol";
import {VM} from "./Utils/VM.sol";

contract BondingCurveTest is DSTest {
    VM vm;
    BondingCurve bondingCurve;
    PairFactory pairFactory;
    Exchange exchange;
    Cryptomedia cryptomedia;
    address exchangeAddress;
    address cryptomediaAddress;


    function setUp() public {
        // Cheat codes
        vm = VM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Deploy exchange and cryptomedia
        bondingCurve = new BondingCurve();
    }
    // make sure exchange can call mint function
    function test_getInitialPrice() public {
        uint256 price = bondingCurve.calculateInitializationPrice(30120, 242424, 724223089680545);
        emit log_uint(price);

    }

    receive() external payable {}

}