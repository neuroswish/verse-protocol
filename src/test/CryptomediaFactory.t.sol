// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "ds-test/test.sol";
import "../BondingCurve.sol";
import "../CryptomediaFactory.sol";
import "../Exchange.sol";
import "../Cryptomedia.sol";

contract CryptomediaFactoryTest is DSTest {
    BondingCurve bondingCurve;
    CryptomediaFactory cryptomediaFactory;
    Exchange exchange;
    Cryptomedia cryptomedia;

    function setUp() public {
        bondingCurve = new BondingCurve();
        cryptomediaFactory = new CryptomediaFactory(address(bondingCurve));
    }

    function testExample() public {
        assertTrue(true);
    }

    function testCreate(
        string memory _exchangeName,
        string memory _exchangeSymbol,
        uint256 _reserveRatio,
        uint256 _transactionShare,
        string memory _cryptomediaName,
        string memory _cryptomediaSymbol,
        string memory _baseURI
        ) public {

    }
}