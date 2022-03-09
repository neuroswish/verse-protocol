/// Good mornin'
/// Look at the valedictorian
/// Scared of the future while I hop in the DeLorean

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

import "./Clones.sol";
import "./Cryptomedia.sol";
import "./Exchange.sol";
import "./BondingCurve.sol";

/// @title Pair Factory
/// @author neuroswish
/// @notice Factory to deploy pairs of cryptomedia and exchange clones

contract PairFactory {
    // ======== Storage ========
    address public immutable cryptomediaLogic;
    address public immutable exchangeLogic;
    address public immutable bondingCurve;

    // ======== Events ========
    event PairCreated(
        address exchangeAddress,
        address cryptomediaAddress,
        string name,
        string symbol,
        address creator
    );

    // ======== Constructor ========
    constructor(address _bondingCurve) {
        bondingCurve = _bondingCurve;
        Exchange exchangeLogic_ = new Exchange(address(this), _bondingCurve);
        Cryptomedia cryptomediaLogic_ = new Cryptomedia(address(this));
        exchangeLogic = address(exchangeLogic_);
        cryptomediaLogic = address(cryptomediaLogic_);
        exchangeLogic_.initialize("Verse", "VERSE", 242424, 724223089680545, 0, cryptomediaLogic, address(this));
        cryptomediaLogic_.initialize("Verse", "VERSE", "verse.xyz", exchangeLogic);
    }

    // ======== Create Cryptomedia Clone ========
    function create(
        string calldata _name,
        string calldata _symbol,
        uint256 _reserveRatio,
        uint256 _slopeInit,
        uint256 _transactionShare,
        string calldata _baseURI
    ) external returns (address exchange, address cryptomedia) {
        require(_transactionShare <= 10000, "INVALID_PERCENTAGE");
        require(_reserveRatio <= 1000000, "INVALID_RESERVE_RATIO");
        exchange = Clones.clone(exchangeLogic);
        cryptomedia = Clones.clone(cryptomediaLogic);
        Exchange(exchange).initialize(_name, _symbol, _reserveRatio, _slopeInit, _transactionShare, cryptomedia, msg.sender);
        Cryptomedia(cryptomedia).initialize(_name, _symbol, _baseURI, exchange);
        emit PairCreated(exchange, cryptomedia, _name, _symbol, msg.sender);
    }
}