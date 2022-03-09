/// Listen to the kids, bro

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.11;

/// @title Bonding Curve
/// @author neuroswish
/// @notice Bonding curve functions governing the exchange of continuous tokens

import "./Power.sol";

contract BondingCurve is Power {
    uint256 public constant maxRatio = 1000000;
    /**
     * @dev given total supply, pool balance, reserve ratio and a price, calculates the number of tokens returned
     *
     * Formula:
     * return = _supply * ((1 + _price / _poolBalance) ^ (_reserveRatio / maxRatio) - 1)
     *
     * @param _supply          liquid token supply
     * @param _poolBalance     pool balance
     * @param _reserveRatio    reserve weight, represented in ppm (1-1000000)
     * @param _price           ETH
     *
     * @return tokens
     */

    function calculatePurchaseReturn(
        uint256 _supply,
        uint256 _poolBalance,
        uint256 _reserveRatio,
        uint256 _price
    ) public view returns (uint256) {
        require(_supply > 0, "INVALID_SUPPLY");
        require(_poolBalance > 0, "INVALID_POOL_BALANCE");
        (uint256 result, uint8 precision) = power(
            (_price + _poolBalance),
            _poolBalance,
            _reserveRatio,
            maxRatio
        );
        uint256 temp = (_supply * result) >> precision;
        return (temp - _supply);
    }

    function calculatePurchasePrice(
        uint256 _supply,
        uint256 _poolBalance,
        uint256 _reserveRatio,
        uint256 _tokens
    ) public view returns (uint256) {
        require(_supply > 0, "INVALID_SUPPLY");
        require(_poolBalance > 0, "INVALID_POOL_BALANCE");
        (uint256 result, uint8 precision) = power(
            (_tokens + _supply),
            _supply,
            _reserveRatio,
            maxRatio
        );
        uint256 temp = (_poolBalance * result) >> precision;
        return (temp - _poolBalance);
    }

    /**
     * @dev given total supply, pool balance, reserve ratio and a token amount, calculates the amount of ETH returned
     *
     * Formula:
     * return = _poolBalance * (1 - (1 - _tokens / _supply) ^ (maxRatio / _reserveRatio))
     *
     * @param _supply          liquid token supply
     * @param _poolBalance     reserve balance
     * @param _reserveRatio    reserve weight, represented in ppm (1-1000000)
     * @param _tokens          amount of liquid tokens to get the target amount for
     *
     * @return ETH
     */

    function calculateSaleReturn(
        uint256 _supply,
        uint256 _poolBalance,
        uint256 _reserveRatio,
        uint256 _tokens
    ) public view returns (uint256) {
        require(_supply > 0, "INVALID_SUPPLY");
        require(_poolBalance > 0, "INVALID_POOL_BALANCE");
        if (_tokens == _supply) {
            return _poolBalance;
        }
        (uint256 result, uint8 precision) = power(
            _supply,
            (_supply - _tokens),
            maxRatio,
            _reserveRatio
        );
        return ((_poolBalance * result) - (_poolBalance << precision)) / result;
        
    }

    function calculateSalePrice(
        uint256 _supply,
        uint256 _poolBalance,
        uint256 _reserveRatio,
        uint256 _price
    ) public view returns (uint256) {
        require(_supply > 0, "INVALID_SUPPLY");
        require(_poolBalance > 0, "INVALID_POOL_BALANCE");
        if (_price == _poolBalance) {
            return _supply;
        }
        (uint256 result, uint8 precision) = power(
            _poolBalance,
            (_poolBalance - _price),
            maxRatio,
            _reserveRatio
        );

        return ((_supply * result) - (_supply << precision)) / result;

    }

    /**
     * @dev given a price, reserve ratio, and initialization slope factor, calculates the number of tokens returned when initializing the bonding curve supply
     *
     * Formula:
     * return = (_price / (_reserveRatio * _slopeInit)) ** _reserveRatio
     *
     * @param _price          liquid token supply
     * @param _reserveRatio   reserve weight, represented in ppm (1-1000000)
     * @param _slopeInit      slope value to initialize supply
     *
     * @return initial token amount
     */

    function calculateInitializationReturn(uint256 _price, uint256 _reserveRatio, uint256 _slopeInit)
        public
        view
        returns (uint256)
    {
        if (_reserveRatio == maxRatio) {
            return (_price * _slopeInit);
        }
        (uint256 temp, uint256 precision) = powerInitial(
            (_price * _slopeInit),
            _reserveRatio,
            maxRatio,
            _reserveRatio,
            maxRatio
        );
        return (temp >> precision);
    }

    function calculateInitializationPrice(uint256 _reserveRatio, uint256 _slopeInit)
        public
        pure
        returns (uint256)
    {
        if (_reserveRatio == maxRatio) {
            return (_slopeInit);
        }
        return ((_reserveRatio * _slopeInit) / maxRatio);
    }
}