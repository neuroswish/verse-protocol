// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.10;

import "./Clones.sol";
import "./Cryptomedia.sol";
import "./Exchange.sol";
import "./BondingCurve.sol";

contract CryptomediaFactory {
    // ======== Storage ========
    address public cryptomediaLogic;
    address public exchangeLogic;
    address public bondingCurve;

    // ======== Constructor ========
    constructor(address _bondingCurve) {
        bondingCurve = _bondingCurve;

        Cryptomedia cryptomediaLogic_ = new Cryptomedia(address(this));
        Exchange exchangeLogic_ = new Exchange(address(this), _bondingCurve);

        cryptomediaLogic = address(cryptomediaLogic_);
        exchangeLogic = address(exchangeLogic_);

        exchangeLogic_.initialize("Verse", "VERSE", 242424, cryptomediaLogic);
        cryptomediaLogic_.initialize("Verse", "VERSE", "verse.xyz", exchangeLogic);
        
    }

    // ======== Create Cryptomedia Clone ========
    function create(
        string calldata _exchangeName,
        string calldata _exchangeSymbol,
        uint32 _reserveRatio,
        string calldata _cryptomediaName,
        string calldata _cryptomediaSymbol,
        string calldata _baseURI
    ) external returns (address exchange, address cryptomedia) {
        exchange = Clones.clone(exchangeLogic);
        bytes32 salt = keccak256(abi.encodePacked(exchange,msg.sender));
        address predictCryptomedia = Clones.predictDeterministicAddress(cryptomediaLogic, salt);
        Exchange(exchange).initialize(_exchangeName, _exchangeSymbol, _reserveRatio, predictCryptomedia);
        cryptomedia = Clones.cloneDeterministic(cryptomediaLogic, salt);
        Cryptomedia(cryptomedia).initialize(_cryptomediaName, _cryptomediaSymbol, _baseURI, exchange);
    }
}