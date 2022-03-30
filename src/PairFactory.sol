/// Good mornin'
/// Look at the valedictorian
/// Scared of the future while I hop in the DeLorean

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

import "./Clones.sol";
import "./Hyperobject.sol";
import "./Exchange.sol";
import "./BondingCurve.sol";

/// @title Pair Factory
/// @author neuroswish
/// @notice Factory to deploy pairs of hyperobject and exchange clones

contract PairFactory {
    // ======== Storage ========
    address public immutable hyperobjectLogic;
    address public immutable exchangeLogic;
    address public immutable bondingCurve;

    // ======== Events ========
    event PairCreated(
        address exchangeAddress,
        address hyperobjectAddress,
        string name,
        string symbol,
        address creator
    );

    // ======== Constructor ========
    constructor(address _bondingCurve) {
        bondingCurve = _bondingCurve;
        Exchange exchangeLogic_ = new Exchange(address(this), _bondingCurve);
        Hyperobject hyperobjectLogic_ = new Hyperobject(address(this));
        exchangeLogic = address(exchangeLogic_);
        hyperobjectLogic = address(hyperobjectLogic_);
        exchangeLogic_.initialize("Verse", "VERSE", 242424, 724223089680545, 0, hyperobjectLogic, address(this));
        hyperobjectLogic_.initialize("Verse", "VERSE", "verse.xyz", exchangeLogic);
    }

    // ======== Create Hyperobject Clone ========
    function create(
        string calldata _name,
        string calldata _symbol,
        uint256 _reserveRatio,
        uint256 _slopeInit,
        uint256 _transactionShare,
        string calldata _baseURI
    ) external returns (address exchange, address hyperobject) {
        require(_transactionShare <= 10000, "INVALID_PERCENTAGE");
        require(_reserveRatio <= 1000000, "INVALID_RESERVE_RATIO");
        exchange = Clones.clone(exchangeLogic);
        hyperobject = Clones.clone(hyperobjectLogic);
        Exchange(exchange).initialize(_name, _symbol, _reserveRatio, _slopeInit, _transactionShare, hyperobject, msg.sender);
        Hyperobject(hyperobject).initialize(_name, _symbol, _baseURI, exchange);
        emit PairCreated(exchange, hyperobject, _name, _symbol, msg.sender);
    }
}