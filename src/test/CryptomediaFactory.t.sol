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
    address exchange;
    address cryptomedia;

    function setUp() public {
        bondingCurve = new BondingCurve();
        cryptomediaFactory = new CryptomediaFactory(address(bondingCurve));
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
        if (_reserveRatio <= 1000000 && _transactionShare <= 10000 ) {
            (exchange, cryptomedia) = cryptomediaFactory.create(_exchangeName, _exchangeSymbol, _reserveRatio, _transactionShare, _cryptomediaName, _cryptomediaSymbol, _baseURI);
            require(exchange != address(0));
            require(cryptomedia != address(0));
        }
    }

    function testFailCreate(
        string memory _exchangeName,
        string memory _exchangeSymbol,
        uint256 _reserveRatio,
        uint256 _transactionShare,
        string memory _cryptomediaName,
        string memory _cryptomediaSymbol,
        string memory _baseURI
    ) public {
        if (_reserveRatio > 1000000 && _transactionShare > 10000 ) {
            (exchange, cryptomedia) = cryptomediaFactory.create(_exchangeName, _exchangeSymbol, _reserveRatio, _transactionShare, _cryptomediaName, _cryptomediaSymbol, _baseURI);
        }
    }
}