// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "ds-test/test.sol";
import "../BondingCurve.sol";
import "../CryptomediaFactory.sol";
import "../Exchange.sol";
import "../Cryptomedia.sol";
import {VM} from "./Utils/VM.sol";

contract ExchangeTest is DSTest {
    VM vm;
    BondingCurve bondingCurve;
    CryptomediaFactory cryptomediaFactory;
    Exchange exchange;
    Cryptomedia cryptomedia;
    address exchangeAddress;
    address cryptomediaAddress;


    function setUp() public {
        // Cheat codes
        vm = VM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Deploy exchange and cryptomedia
        bondingCurve = new BondingCurve();
        cryptomediaFactory = new CryptomediaFactory(address(bondingCurve));
        (exchangeAddress, cryptomediaAddress) = cryptomediaFactory.create("Verse", "VERSE", 242424, 0, "verse.xyz");
        exchange = Exchange(exchangeAddress);
        cryptomedia = Cryptomedia(cryptomediaAddress);

        // Set user balances
        vm.deal(address(1), 100 ether);
        vm.deal(address(2), 100 ether);
    }

    // Non-factory address cannot call initialize function
    function testFail_Initialize(string memory _name, string memory _symbol, uint256 _reserveRatio, uint256 _transactionShare, address _cryptomedia, address _creator) public {
        vm.prank(address(0));
        exchange.initialize(_name, _symbol, _reserveRatio, _transactionShare, _cryptomedia, _creator);
    }
    
    // User can buy tokens and initialize token supply
    function test_BuyInitial() public {
        vm.prank(address(1));
        exchange.buy{value: 1 ether}(1);
        emit log_uint(exchange.balanceOf(address(1)));
    }

    // User can buy tokens after supply has been initialized
    function test_Buy() public {
        vm.prank(address(2));   
        exchange.buy{value: 8 ether}(1);
        emit log_uint(exchange.balanceOf(address(2)));
    }

    // User cannot send 0 ether to buy tokens
    function test_BuyZeroValue() public {
        vm.prank(address(1));
        vm.expectRevert("INVALID_VALUE");
        exchange.buy{value: 0 ether}(1);
    }

    // User cannot specify an invalid slippage value
    function test_BuyInvalidSlippage() public {
        vm.prank(address(1));
        vm.expectRevert("INVALID_SLIPPAGE");
        exchange.buy{value: 0.1 ether}(0);
    }

    // Buy reverts if tokens returned are less than minimum return specified
    function test_BuySlippage() public {
        vm.prank(address(1));
        vm.expectRevert("SLIPPAGE");
        exchange.buy{value: 1 ether}(50 * (10**18));
    }


    // initialize DONE
    // buy initial DONE
    // buy DONE
    // invalid price DONE
    // invalid buy slippage
    // buy slippage occurs
    
    // sell
    // invalid sell amount
    // invalid sell slippage
    // sell slippage occurs
    // redeem
    // redeem invalid balance

    receive() external payable {}

}